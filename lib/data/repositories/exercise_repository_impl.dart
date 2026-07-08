import '../../domain/models/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/exercise_remote_datasource.dart';
import '../models/exercise_model.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseRemoteDataSource remoteDataSource;
  List<ExerciseModel>? _cachedExercises;

  ExerciseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Exercise>> getExercises({int limit = 50, int offset = 0}) async {
    if (_cachedExercises == null || _cachedExercises!.isEmpty) {
      try {
        _cachedExercises = await remoteDataSource.getAllExercises();
      } catch (e) {
        throw Exception('Failed to load exercises from remote: $e');
      }
    }

    final exercises = _cachedExercises!;
    if (offset >= exercises.length) {
      return [];
    }

    final end = (offset + limit < exercises.length) ? offset + limit : exercises.length;
    return exercises.sublist(offset, end);
  }
}
