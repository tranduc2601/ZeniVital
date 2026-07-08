import 'package:flutter/material.dart';
import '../../core/localization.dart';
import '../../domain/models/user.dart';
import '../../domain/models/routine.dart';
import '../../domain/models/exercise.dart';
import '../../data/api/static_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';

class SmartConditioningPlan extends StatefulWidget {
  final User user;
  final void Function(Routine?) onWorkoutTap;
  final VoidCallback onCustomWorkout;

  const SmartConditioningPlan({
    super.key,
    required this.user,
    required this.onWorkoutTap,
    required this.onCustomWorkout,
  });

  @override
  State<SmartConditioningPlan> createState() => _SmartConditioningPlanState();
}

class _SmartConditioningPlanState extends State<SmartConditioningPlan> {
  List<Exercise> _pool = [];
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _generatePool();
  }

  void _generatePool() {
    final goal = widget.user.goal;
    final durationMins = widget.user.preferredDuration ?? 30;
    final level = (widget.user.level ?? 'beginner').toLowerCase();

    var pool = StaticData.exercises.where((e) => e.difficulty.toLowerCase() == level).toList();
    if (pool.isEmpty) pool = StaticData.exercises;

    if (goal == GoalType.weightLoss) {
      pool = pool.where((e) => e.equipment.toLowerCase().contains('body') || e.targetMuscle.toLowerCase() == 'full body').toList();
    } else if (goal == GoalType.bodybuilding) {
      pool = pool.where((e) => !e.equipment.toLowerCase().contains('body')).toList();
    }
    if (pool.isEmpty) pool = StaticData.exercises;

    pool.shuffle(Random(DateTime.now().millisecondsSinceEpoch));

    final numExercises = (durationMins / 3).clamp(3, 8).toInt();
    _pool = pool.take(numExercises).toList();
    _selectedIds.addAll(_pool.map((e) => e.id));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Workout',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ..._pool.map((ex) {
          final isSelected = _selectedIds.contains(ex.id);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedIds.remove(ex.id);
                } else {
                  _selectedIds.add(ex.id);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? const Color(0xFFE94560) : Colors.white12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: ex.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.white12),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(ex.targetMuscle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIds.add(ex.id);
                        } else {
                          _selectedIds.remove(ex.id);
                        }
                      });
                    },
                    activeColor: const Color(0xFFE94560),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIds.isEmpty ? Colors.grey : const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () {
                        final goal = widget.user.goal;
                        final sets = goal == GoalType.bodybuilding ? 4 : 3;
                        final reps = goal == GoalType.weightLoss ? 15 : (goal == GoalType.bodybuilding ? 8 : 12);
                        final rest = goal == GoalType.bodybuilding ? 90 : (goal == GoalType.weightLoss ? 45 : 60);

                        final selectedEx = _pool.where((e) => _selectedIds.contains(e.id)).toList();
                        final slots = selectedEx.map((e) => RoutineSlot(
                          exerciseId: e.id,
                          exerciseName: e.name,
                          muscle: e.targetMuscle,
                          sets: sets,
                          reps: reps,
                          restSeconds: rest,
                        )).toList();

                        final routine = Routine(
                          id: 'smart_${DateTime.now().millisecondsSinceEpoch}',
                          name: 'Smart Recommended Routine',
                          slots: slots,
                        );
                        widget.onWorkoutTap(routine);
                      },
                child: Text(AppLocalizations.get('start_workout'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE94560),
                  side: const BorderSide(color: Color(0xFFE94560)),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: widget.onCustomWorkout,
                child: const Text('Custom Routine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
