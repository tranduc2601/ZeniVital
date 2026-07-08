import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/localization.dart';
import 'package:flutter/services.dart';
import '../../data/api/local_database.dart';
import '../../domain/models/workout_log.dart';
import '../../domain/models/user.dart';
import '../../domain/models/feed_post.dart';
import '../../domain/models/routine.dart';
import '../../data/api/static_data.dart';
import 'dart:math';

// _ExerciseSlot is now basically RoutineSlot, but let's keep it here if we want to map it, or just use RoutineSlot directly.
// To minimize changes and ponytail philosophy, we'll map our hardcoded circuits to RoutineSlots.

List<RoutineSlot> _circuitFor(User? user) {
  final goal = user?.goal ?? GoalType.conditioning;
  final durationMins = user?.preferredDuration ?? 30;
  final level = (user?.level ?? 'beginner').toLowerCase();
  
  // 1. Filter by level
  var pool = StaticData.exercises.where((e) => e.difficulty.toLowerCase() == level).toList();
  if (pool.isEmpty) pool = StaticData.exercises; // Fallback

  // 2. Sort/filter by goal (simplified ponytail logic)
  if (goal == GoalType.weightLoss) {
    pool = pool.where((e) => e.equipment.toLowerCase().contains('body') || e.targetMuscle.toLowerCase() == 'full body').toList();
  } else if (goal == GoalType.bodybuilding) {
    pool = pool.where((e) => !e.equipment.toLowerCase().contains('body')).toList();
  }
  if (pool.isEmpty) pool = StaticData.exercises;
  
  pool.shuffle(Random(DateTime.now().millisecondsSinceEpoch));

  // 3. Generate budget
  // Assume each slot (3 sets * (reps time + rest time)) takes ~ 3 mins
  final numExercises = (durationMins / 3).clamp(3, 8).toInt();
  
  return pool.take(numExercises).map((e) {
    final sets = goal == GoalType.bodybuilding ? 4 : 3;
    final reps = goal == GoalType.weightLoss ? 15 : (goal == GoalType.bodybuilding ? 8 : 12);
    final rest = goal == GoalType.bodybuilding ? 90 : (goal == GoalType.weightLoss ? 45 : 60);
    return RoutineSlot(
      exerciseId: e.id,
      exerciseName: e.name,
      muscle: e.targetMuscle,
      sets: sets,
      reps: reps,
      restSeconds: rest,
    );
  }).toList();
}

class WorkoutDetailScreen extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const WorkoutDetailScreen({super.key, required this.onStartWorkout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: ElevatedButton(
          key: const Key('start_workout_btn'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94560),
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onStartWorkout,
          child: Text(AppLocalizations.get('start_workout'), style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

class WorkoutPlayerScreen extends StatefulWidget {
  final GoalType goalType;
  final Routine? customRoutine;
  final VoidCallback onComplete;
  final VoidCallback onExitRequest;

  const WorkoutPlayerScreen({
    super.key,
    required this.goalType,
    this.customRoutine,
    required this.onComplete,
    required this.onExitRequest,
  });

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

enum _Phase { performing, resting }

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final List<RoutineSlot> _circuit;
  late final AnimationController _progressController;

  int _exerciseIndex = 0;
  int _currentSet = 1;
  _Phase _phase = _Phase.performing;
  bool _showExitDialog = false;
  Timer? _restTimer;
  int _restSecondsLeft = 0;
  late DateTime _startTime;
  bool _flash = false;
  double _totalWorkoutVolume = 0.0;

  @override
  void initState() {
    super.initState();
    _circuit = widget.customRoutine?.slots ?? _circuitFor(LocalDatabase.instance.getUser());
    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..forward();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  RoutineSlot get _currentExercise => _circuit[_exerciseIndex];

  bool get _isLastExercise => _exerciseIndex == _circuit.length - 1;

  bool get _isLastSet => _currentSet == _currentExercise.sets;

  void _startRestCountdown() {
    setState(() {
      _phase = _Phase.resting;
      _restSecondsLeft = _currentExercise.restSeconds;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSecondsLeft <= 4 && _restSecondsLeft > 1) {
        HapticFeedback.heavyImpact();
      }
      if (_restSecondsLeft <= 1) {
        t.cancel();
        _advanceToNext();
      } else {
        setState(() => _restSecondsLeft--);
      }
    });
  }

  void _advanceToNext() {
    if (_isLastSet) {
      if (_isLastExercise) {
        _finish();
        return;
      }
      setState(() {
        _exerciseIndex++;
        _currentSet = 1;
        _phase = _Phase.performing;
      });
    } else {
      setState(() {
        _currentSet++;
        _phase = _Phase.performing;
      });
    }
    _triggerFlash();
    _progressController
      ..reset()
      ..forward();
  }

  void _triggerFlash() {
    setState(() => _flash = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _flash = false);
    });
  }

  void _completeSet(double volume) {
    _totalWorkoutVolume += volume;
    if (_isLastSet && _isLastExercise) {
      _finish();
    } else {
      _startRestCountdown();
    }
  }

  void _finish() {
    _restTimer?.cancel();
    final duration = DateTime.now().difference(_startTime).inSeconds;
    LocalDatabase.instance.addWorkoutLog(WorkoutLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      completedAt: DateTime.now(),
      durationSeconds: duration,
      goalType: widget.goalType,
      totalVolume: _totalWorkoutVolume,
    ));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final totalSets = _circuit.fold(0, (sum, e) => sum + e.sets);
    final completedSets = _circuit.take(_exerciseIndex).fold(0, (sum, e) => sum + e.sets) +
        (_currentSet - 1);
    final overallProgress = completedSets / totalSets;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _showExitDialog = true);
      },
      child: Scaffold(
        key: const Key('workout_player_screen'),
        backgroundColor: const Color(0xFF1A1A2E),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _ProgressHeader(
                    overallProgress: overallProgress,
                    exerciseIndex: _exerciseIndex,
                    totalExercises: _circuit.length,
                    onExit: () => setState(() => _showExitDialog = true),
                  ),
                  Expanded(
                    child: _phase == _Phase.resting
                        ? _RestView(
                            secondsLeft: _restSecondsLeft,
                            totalSeconds: _currentExercise.restSeconds,
                            nextIsFinish: _isLastSet && _isLastExercise,
                            onSkip: () {
                              _restTimer?.cancel();
                              _advanceToNext();
                            },
                          )
                        : _ExerciseView(
                            exercise: _currentExercise,
                            currentSet: _currentSet,
                            isLastSetOfWorkout: _isLastExercise && _isLastSet,
                            onCompleteSet: _completeSet,
                          ),
                  ),
                ],
              ),
            ),
            if (_showExitDialog) _ExitDialog(
              onConfirm: widget.onExitRequest,
              onDismiss: () => setState(() => _showExitDialog = false),
            ),
            if (_flash)
              IgnorePointer(
                child: Container(
                  color: const Color(0xFFE94560).withOpacity(0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final double overallProgress;
  final int exerciseIndex;
  final int totalExercises;
  final VoidCallback onExit;

  const _ProgressHeader({
    required this.overallProgress,
    required this.exerciseIndex,
    required this.totalExercises,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: onExit,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    backgroundColor: const Color(0xFF16213E),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${exerciseIndex + 1}/$totalExercises',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseView extends StatefulWidget {
  final RoutineSlot exercise;
  final int currentSet;
  final bool isLastSetOfWorkout;
  final void Function(double volume) onCompleteSet;

  const _ExerciseView({
    required this.exercise,
    required this.currentSet,
    required this.isLastSetOfWorkout,
    required this.onCompleteSet,
  });

  @override
  State<_ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<_ExerciseView> {
  double _weight = 20.0;

  @override
  Widget build(BuildContext context) {
    final isLast = widget.isLastSetOfWorkout;
    final exercise = widget.exercise;
    final currentSet = widget.currentSet;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
              .animate(anim),
          child: child,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          key: ValueKey('${exercise.exerciseName}_$currentSet'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE94560), width: 3),
            ),
            child: const Icon(Icons.fitness_center, color: Color(0xFFE94560), size: 54),
          ),
          const SizedBox(height: 32),
          Text(
            exercise.exerciseName,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            exercise.muscle,
            style: const TextStyle(color: Color(0xFFE94560), fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatBadge(label: 'Set', value: '$currentSet of ${exercise.sets}'),
              const SizedBox(width: 24),
              _StatBadge(
                label: exercise.reps == 1 ? 'Duration' : 'Reps',
                value: exercise.reps == 1 ? '30 sec' : '${exercise.reps}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (exercise.reps > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() => _weight = (_weight - 2.5).clamp(0, 300)),
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 32),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      '${_weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(AppLocalizations.get('weight'), style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => setState(() => _weight = (_weight + 2.5).clamp(0, 300)),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white54, size: 32),
                ),
              ],
            ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                key: isLast
                    ? const Key('player_finish_btn')
                    : const Key('player_next_btn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast
                      ? const Color(0xFFE94560)
                      : const Color(0xFF16213E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  widget.onCompleteSet(exercise.reps * _weight);
                },
                child: Text(
                  isLast ? 'Finish Workout' : 'Set Complete ✓',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;

  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RestView extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;
  final bool nextIsFinish;
  final VoidCallback onSkip;

  const _RestView({
    required this.secondsLeft,
    required this.totalSeconds,
    required this.nextIsFinish,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsLeft / totalSeconds;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'REST',
          style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 4),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFF16213E),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
                ),
              ),
              Text(
                '$secondsLeft',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: nextIsFinish
                  ? const Key('player_finish_btn')
                  : const Key('player_next_btn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: nextIsFinish
                    ? const Color(0xFFE94560)
                    : const Color(0xFF16213E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onSkip,
              child: Text(
                nextIsFinish ? 'Finish Workout' : 'Skip Rest →',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExitDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const _ExitDialog({required this.onConfirm, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: AlertDialog(
          key: const Key('exit_confirm_dialog'),
          backgroundColor: const Color(0xFF16213E),
          title: Text(AppLocalizations.get('exit_workout'), style: TextStyle(color: Colors.white)),
          content: const Text(
            'Your progress will not be saved.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              key: const Key('exit_confirm_no'),
              onPressed: onDismiss,
              child: Text(AppLocalizations.get('keep_going'), style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              key: const Key('exit_confirm_yes'),
              onPressed: onConfirm,
              child: Text(AppLocalizations.get('exit'), style: TextStyle(color: Color(0xFFE94560))),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutSummaryScreen extends StatelessWidget {
  final VoidCallback onClose;

  const WorkoutSummaryScreen({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final last = LocalDatabase.instance.getWorkoutLogs().lastOrNull;
    final minutes = last != null ? last.durationSeconds ~/ 60 : 0;

    return Scaffold(
      key: const Key('workout_summary_screen'),
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFE94560), size: 72),
              const SizedBox(height: 24),
              const Text(
                'Workout Complete!',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Duration: $minutes minutes',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Volume Lifted: ${last?.totalVolume.toStringAsFixed(1) ?? "0"} kg',
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  key: const Key('share_to_feed_btn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16213E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final user = LocalDatabase.instance.getUser();
                    await LocalDatabase.instance.addFeedPost(FeedPost(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userName: user?.name ?? 'Guest',
                      avatarUrl: 'https://i.pravatar.cc/150?u=${user?.id ?? "guest"}',
                      content: 'Completed a ${minutes == 0 ? 30 : minutes}-minute ${user?.goal.name.replaceAll('Type.', '') ?? "conditioning"} workout!',
                      timestamp: DateTime.now(),
                    ));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.get('workout_shared'))),
                      );
                    }
                  },
                  icon: const Icon(Icons.share),
                  label: Text(AppLocalizations.get('share_to_feed')),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  key: const Key('summary_close_btn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onClose,
                  child: Text(AppLocalizations.get('close_summary')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
