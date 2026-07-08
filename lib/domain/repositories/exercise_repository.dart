import '../models/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getExercises({int limit = 50, int offset = 0});
}
