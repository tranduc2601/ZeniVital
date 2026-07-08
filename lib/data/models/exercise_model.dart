import '../../domain/models/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.targetMuscle,
    required super.difficulty,
    required super.equipment,
    required super.imageUrl,
    required super.description,
    required super.isPremium,
    super.steps,
    super.images,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    final ex = Exercise.fromJson(json);
    return ExerciseModel(
      id: ex.id,
      name: ex.name,
      targetMuscle: ex.targetMuscle,
      difficulty: ex.difficulty,
      equipment: ex.equipment,
      imageUrl: ex.imageUrl,
      description: ex.description,
      isPremium: ex.isPremium,
      steps: ex.steps,
      images: ex.images,
    );
  }
}
