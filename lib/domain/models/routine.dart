import 'exercise.dart';

class RoutineSlot {
  final String exerciseId;
  final String exerciseName;
  final String muscle;
  final int sets;
  final int reps;
  final int restSeconds;

  const RoutineSlot({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscle,
    required this.sets,
    required this.reps,
    required this.restSeconds,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'muscle': muscle,
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
      };

  factory RoutineSlot.fromJson(Map<String, dynamic> json) => RoutineSlot(
        exerciseId: json['exerciseId'] as String,
        exerciseName: json['exerciseName'] as String,
        muscle: json['muscle'] as String,
        sets: json['sets'] as int,
        reps: json['reps'] as int,
        restSeconds: json['restSeconds'] as int,
      );
}

class Routine {
  final String id;
  final String name;
  final List<RoutineSlot> slots;
  final bool isCustom;

  const Routine({
    required this.id,
    required this.name,
    required this.slots,
    this.isCustom = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slots': slots.map((s) => s.toJson()).toList(),
        'isCustom': isCustom,
      };

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'] as String,
        name: json['name'] as String,
        slots: (json['slots'] as List).map((s) => RoutineSlot.fromJson(s as Map<String, dynamic>)).toList(),
        isCustom: json['isCustom'] as bool? ?? true,
      );
}
