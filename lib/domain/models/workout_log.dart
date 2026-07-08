import 'user.dart';

class WorkoutLog {
  final String id;
  final DateTime completedAt;
  final int durationSeconds;
  final GoalType goalType;
  final double totalVolume;

  const WorkoutLog({
    required this.id,
    required this.completedAt,
    required this.durationSeconds,
    required this.goalType,
    this.totalVolume = 0.0,
  });
}
