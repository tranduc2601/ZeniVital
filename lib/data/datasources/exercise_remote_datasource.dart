import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise_model.dart';

abstract class ExerciseRemoteDataSource {
  Future<List<ExerciseModel>> getAllExercises();
}

class ExerciseRemoteDataSourceImpl implements ExerciseRemoteDataSource {
  final http.Client client;

  ExerciseRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ExerciseModel>> getAllExercises() async {
    // We will use the free-exercise-db raw JSON file from github.
    final response = await client.get(
      Uri.parse('https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ExerciseModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load exercises');
    }
  }
}
