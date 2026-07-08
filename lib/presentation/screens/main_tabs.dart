import 'package:flutter/material.dart';
import '../../core/localization.dart';
import '../../domain/models/routine.dart';
import '../../domain/models/user.dart';
import '../../data/api/static_data.dart';
import '../../data/api/local_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import '../widgets/smart_conditioning_plan.dart';
import '../../domain/models/user.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/routine.dart';
import '../../data/api/local_database.dart';
import '../../data/api/static_data.dart';
import '../../core/localization.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExploreScreen extends StatefulWidget {
  final void Function(String exerciseName) onExerciseTap;
  final VoidCallback onCreateRoutineTap;

  const ExploreScreen({
    super.key,
    required this.onExerciseTap,
    required this.onCreateRoutineTap,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selectedMuscle;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Exercise> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    var list = StaticData.exercises;
    if (q.isNotEmpty) {
      list = list.where((e) => e.name.toLowerCase().contains(q)).toList();
    }
    if (_selectedMuscle != null) {
      list = list.where((e) => e.targetMuscle == _selectedMuscle).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    final query = _searchCtrl.text.trim();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        key: const Key('explore_screen'),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                key: const Key('exercise_search_field'),
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: AppLocalizations.get('search_exercises'),
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF16213E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(
                    label: AppLocalizations.get('all'),
                    isSelected: _selectedMuscle == null,
                    onTap: () => setState(() => _selectedMuscle = null),
                  ),
                  ...StaticData.exercises
                      .map((e) => e.targetMuscle)
                      .toSet()
                      .map((m) {
                        return _FilterChip(
                          label: m,
                          isSelected: _selectedMuscle == m,
                          onTap: () => setState(() => _selectedMuscle = m),
                        );
                      }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.get('no_exercises_found'),
                        key: const Key('empty_search_state'),
                        style: const TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (ctx, i) {
                        final ex = results[i];
                        final liked = LocalDatabase.instance.isLiked(ex.id);
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ex.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: ex.imageUrl,
                                    width: 50,
                                    height: 50,
                                    memCacheWidth: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Image.asset(
                                      'assets/exercise_placeholder.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      cacheWidth: 100,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                          'assets/exercise_placeholder.png',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          cacheWidth: 100,
                                        ),
                                  )
                                : Image.asset(
                                    'assets/exercise_placeholder.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    cacheWidth: 100,
                                  ),
                          ),
                          title: Text(
                            ex.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${ex.targetMuscle} · ${ex.difficulty}',
                            style: const TextStyle(color: Colors.white54),
                          ),
                          trailing: liked
                              ? Icon(
                                  Icons.favorite,
                                  key: Key(
                                    'exercise_liked_icon_${ex.name}_active',
                                  ),
                                  color: const Color(0xFFE94560),
                                )
                              : null,
                          onTap: () => widget.onExerciseTap(ex.name),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onCreateRoutineTap,
        backgroundColor: const Color(0xFFE94560),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppLocalizations.get('new_routine'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.white70),
        ),
        backgroundColor: isSelected
            ? const Color(0xFFE94560)
            : const Color(0xFF16213E),
        onPressed: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFFE94560) : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final localPosts = LocalDatabase.instance.getFeedPosts();
    final posts = [
      ...StaticData.personalFeed,
      ...StaticData.communityFeed,
      ...localPosts,
    ];
    posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (posts.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.get('no_posts_yet'),
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      key: const Key('feed_screen'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: posts.length,
      itemBuilder: (ctx, i) {
        final p = posts[i];
        return Card(
          color: const Color(0xFF16213E),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: p.avatarUrl.isNotEmpty
                      ? NetworkImage(p.avatarUrl)
                      : null,
                  child: p.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.content,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                // Kudos button
                StatefulBuilder(
                  builder: (ctx, setStateInner) {
                    final isKudoed = LocalDatabase.instance.isKudoed(p.id);
                    final kudosCount = p.initialKudos + (isKudoed ? 1 : 0);
                    return InkWell(
                      onTap: () async {
                        await LocalDatabase.instance.toggleKudo(p.id);
                        setStateInner(() {});
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isKudoed
                              ? const Color(0xFFE94560).withOpacity(0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isKudoed
                                ? const Color(0xFFE94560)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pan_tool,
                              size: 16,
                              color: isKudoed
                                  ? const Color(0xFFE94560)
                                  : Colors.white54,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$kudosCount',
                              style: TextStyle(
                                color: isKudoed
                                    ? const Color(0xFFE94560)
                                    : Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final VoidCallback onGoToSettings;
  final VoidCallback onGoToOnboarding;
  final VoidCallback onUnlikeDone;

  const ProfileScreen({
    super.key,
    required this.onGoToSettings,
    required this.onGoToOnboarding,
    required this.onUnlikeDone,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = LocalDatabase.instance.getUser();
    final logs = LocalDatabase.instance.getWorkoutLogs();

    // Streak Calculation (Ponytail way)
    int streak = 0;
    if (logs.isNotEmpty) {
      DateTime today = DateTime.now();
      DateTime todayDate = DateTime(today.year, today.month, today.day);
      DateTime lastDate = todayDate;
      streak = 0;

      final uniqueDates =
          logs
              .map((l) {
                return DateTime(
                  l.completedAt.year,
                  l.completedAt.month,
                  l.completedAt.day,
                );
              })
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));

      if (uniqueDates.isNotEmpty) {
        // If the most recent workout was today or yesterday
        if (uniqueDates.first.isAtSameMomentAs(todayDate) ||
            uniqueDates.first.isAtSameMomentAs(
              todayDate.subtract(const Duration(days: 1)),
            )) {
          streak = 1;
          for (int i = 0; i < uniqueDates.length - 1; i++) {
            if (uniqueDates[i].difference(uniqueDates[i + 1]).inDays == 1) {
              streak++;
            } else {
              break;
            }
          }
        }
      }
    }

    final totalWorkouts = logs.length;
    final totalSeconds = logs.fold(0, (sum, log) => sum + log.durationSeconds);
    final totalMinutes = totalSeconds ~/ 60;
    final avgMinutes = totalWorkouts > 0 ? (totalMinutes ~/ totalWorkouts) : 0;

    return SingleChildScrollView(
      key: const Key('profile_screen'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE94560),
              child: Text(
                'A',
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Guest',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.goal.displayName ?? 'Conditioning Plan',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onGoToOnboarding,
                  child: const Icon(Icons.edit, color: Colors.white54, size: 16),
                ),
              ],
            ),
            // Gamification: Streak & Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orangeAccent,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '$streak ${AppLocalizations.get('day_streak')}',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _BadgeIcon(
                    Icons.emoji_events,
                    AppLocalizations.get('first_step'),
                    isActive: totalWorkouts >= 1,
                  ),
                  _BadgeIcon(
                    Icons.directions_run,
                    AppLocalizations.get('consistency'),
                    isActive: streak >= 3,
                  ),
                  _BadgeIcon(
                    Icons.fitness_center,
                    AppLocalizations.get('power'),
                    isActive: totalMinutes >= 60,
                  ),
                  _BadgeIcon(
                    Icons.nightlight_round,
                    AppLocalizations.get('night_owl'),
                    isActive: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    AppLocalizations.get('workouts'),
                    totalWorkouts.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    AppLocalizations.get('minutes'),
                    totalMinutes.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    AppLocalizations.get('avg_mins'),
                    avgMinutes.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Native Chart
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.get('recent_activity'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: _BarChartPainter(
                        logs.map((l) => l.durationSeconds / 60).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('profile_settings_btn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16213E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: widget.onGoToSettings,
                child: Text(AppLocalizations.get('settings')),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('profile_liked_tab'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16213E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(AppLocalizations.get('liked_exercises')),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: LocalDatabase.instance
                            .getLikedExercises()
                            .map((e) {
                              final exName = StaticData.exercises
                                  .firstWhere(
                                    (x) => x.id == e,
                                    orElse: () => StaticData.exercises.first,
                                  )
                                  .name;
                              return Row(
                                children: [
                                  Text(exName),
                                  IconButton(
                                    key: Key('liked_item_unlike_$exName'),
                                    icon: const Icon(Icons.favorite),
                                    onPressed: () {
                                      LocalDatabase.instance.toggleLike(e);
                                      Navigator.pop(context);
                                      widget.onUnlikeDone();
                                    },
                                  ),
                                ],
                              );
                            })
                            .toList(),
                      ),
                    ),
                  );
                },
                child: Text(AppLocalizations.get('liked_exercises')),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('profile_fitness_test_btn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16213E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(AppLocalizations.get('fitness_test')),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const TextField(key: Key('test_heart_rate')),
                          const TextField(key: Key('test_weight')),
                          ElevatedButton(
                            key: const Key('test_perform_workout_btn'),
                            onPressed: () {},
                            child: Text(AppLocalizations.get('perform')),
                          ),
                          ElevatedButton(
                            key: const Key('test_submit_btn'),
                            onPressed: () {
                              LocalDatabase.instance.updateGoal(
                                GoalType.bodybuilding,
                              );
                              Navigator.pop(context);
                              setState(
                                () {},
                              ); // trigger rebuild to show Advanced Bodybuilding Plan
                            },
                            child: Text(AppLocalizations.get('submit')),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Text(AppLocalizations.get('fitness_diagnostic')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _BadgeIcon(this.icon, this.label, {required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFFE94560).withOpacity(0.2)
                  : Colors.white10,
              border: Border.all(
                color: isActive ? const Color(0xFFE94560) : Colors.transparent,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFFE94560) : Colors.white24,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white38,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  _BarChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;

    final paint = Paint()
      ..color = const Color(0xFFE94560)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final recent = values.length > 7
        ? values.sublist(values.length - 7)
        : values;
    final barWidth = (size.width / 7) * 0.5;
    final spacing =
        (size.width - (barWidth * recent.length)) / (recent.length + 1);

    for (int i = 0; i < recent.length; i++) {
      final h = (recent[i] / maxVal) * size.height;
      final x = spacing + (i * (barWidth + spacing));
      final y = size.height - h;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, h),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DashboardScreen extends StatelessWidget {
  final void Function(String exerciseName) onExerciseTap;
  final void Function(Routine?) onWorkoutTap;
  final VoidCallback onGoToSettings;
  final VoidCallback onTabChanged;
  final VoidCallback onRoutineBuilderTap;

  const DashboardScreen({
    super.key,
    required this.onExerciseTap,
    required this.onWorkoutTap,
    required this.onGoToSettings,
    required this.onTabChanged,
    required this.onRoutineBuilderTap,
  });

  String _goalLabel(GoalType goal) {
    switch (goal) {
      case GoalType.weightLoss:
        return AppLocalizations.get('weight_loss');
      case GoalType.conditioning:
        return AppLocalizations.get('conditioning');
      case GoalType.bodybuilding:
        return AppLocalizations.get('bodybuilding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = LocalDatabase.instance.getUser();
    final goal = user?.goal ?? GoalType.conditioning;
    final workoutCount = LocalDatabase.instance.workoutCount;
    final customRoutines = LocalDatabase.instance.getRoutines();
    final exercises = StaticData.exercises;
    return CustomScrollView(
      key: const Key('dashboard_screen'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.get('hello')}, ${user?.name ?? AppLocalizations.get('guest')} 👋',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 16),
                if (user == null || !user.hasCompletedProfile)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.assignment_ind,
                          color: Colors.white54,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.get('incomplete_profile'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560),
                            foregroundColor: Colors.white,
                          ),
                          onPressed:
                              onTabChanged, // Calls onTabChange('profile')
                          child: Text(AppLocalizations.get('complete_now')),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text(
                    _goalLabel(goal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SmartConditioningPlan(
                    user: user!,
                    onWorkoutTap: onWorkoutTap, onCustomWorkout: onRoutineBuilderTap,
                  ),
                ],
                const SizedBox(height: 28),
                if (customRoutines.isNotEmpty) ...[
                  Text(
                    AppLocalizations.get('custom_routines'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...customRoutines.map((routine) {
                    return GestureDetector(
                      onTap: () => onWorkoutTap(routine),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.fitness_center,
                              color: Color(0xFFE94560),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    routine.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${routine.slots.length} ${AppLocalizations.get('exercises')}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.play_circle_fill,
                              color: Color(0xFFE94560),
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 28),
                ],
                Text(
                  AppLocalizations.get('all_exercises'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            delegate: SliverChildBuilderDelegate((ctx, i) {
              final ex = exercises[i];
              return GestureDetector(
                onTap: () => onExerciseTap(ex.name),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (ex.imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: ex.imageUrl,
                          memCacheWidth: 400,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            'assets/exercise_placeholder.png',
                            fit: BoxFit.cover,
                            cacheWidth: 400,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/exercise_placeholder.png',
                            fit: BoxFit.cover,
                            cacheWidth: 400,
                          ),
                        )
                      else
                        Image.asset(
                          'assets/exercise_placeholder.png',
                          fit: BoxFit.cover,
                          cacheWidth: 400,
                        ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              ex.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ex.targetMuscle} • ${ex.difficulty}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: exercises.length > 12 ? 12 : exercises.length),
          ),
        ),
      ],
    );
  }
}
