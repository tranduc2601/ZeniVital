import 'dart:io';
import 'dart:convert';

void main() {
  final List<String> pathsEn = [
    '../Trenx/app/src/main/res/raw/exercises_en.json',
    'd:/Trenx/app/src/main/res/raw/exercises_en.json',
    'd:\\Trenx\\app\\src\\main\\res\\raw\\exercises_en.json',
    'app/src/main/res/raw/exercises_en.json',
  ];

  final List<String> pathsVi = [
    '../Trenx/app/src/main/res/raw/exercises_vi.json',
    'd:/Trenx/app/src/main/res/raw/exercises_vi.json',
    'd:\\Trenx\\app\\src\\main\\res\\raw\\exercises_vi.json',
    'app/src/main/res/raw/exercises_vi.json',
  ];

  File? fileEn;
  File? fileVi;

  for (final path in pathsEn) {
    final file = File(path);
    if (file.existsSync()) {
      fileEn = file;
      break;
    }
  }

  for (final path in pathsVi) {
    final file = File(path);
    if (file.existsSync()) {
      fileVi = file;
      break;
    }
  }

  if (fileEn == null || fileVi == null) {
    stderr.writeln('Error: Could not locate exercise JSON files in any searched path.');
    exit(1);
  }

  try {
    final String contentEn = fileEn.readAsStringSync();
    final String contentVi = fileVi.readAsStringSync();

    final List<dynamic> dataEn = json.decode(contentEn) as List<dynamic>;
    final List<dynamic> dataVi = json.decode(contentVi) as List<dynamic>;

    if (dataEn.length < 15) {
      throw Exception(
        'English exercise database must have at least 15 exercises',
      );
    }
    if (dataVi.length < 15) {
      throw Exception(
        'Vietnamese exercise database must have at least 15 exercises',
      );
    }
    if (dataEn.length != dataVi.length) {
      throw Exception(
        'Size mismatch: English database has ${dataEn.length} items, Vietnamese has ${dataVi.length} items',
      );
    }

    final Set<String> validDifficulties = {
      'Beginner',
      'Intermediate',
      'Advanced',
    };
    final Set<String> validMusclesEn = {
      'Chest',
      'Shoulders',
      'Back',
      'Legs',
      'Abs',
    };
    final Set<String> validMusclesVi = {
      'Cơ ngực',
      'Cơ vai',
      'Cơ lưng',
      'Cơ chân',
      'Cơ bụng (Core)',
      'Toàn thân',
    };

    final Map<String, Map<String, dynamic>> enMap = {};

    for (final item in dataEn) {
      final map = item as Map<String, dynamic>;
      final String id = map['id'] ?? '';
      final String name = map['name'] ?? '';
      final String difficulty = map['difficulty'] ?? '';
      final String targetMuscle = map['targetMuscle'] ?? '';
      final String equipment = map['equipment'] ?? '';
      final String imageUrl = map['imageUrl'] ?? '';
      final String description = map['description'] ?? '';
      final dynamic isPremium = map['isPremium'];

      if (id.isEmpty) {
        throw Exception('Found exercise with empty ID');
      }
      if (name.isEmpty) {
        throw Exception('Exercise $id has empty name');
      }
      if (!validDifficulties.contains(difficulty)) {
        throw Exception('Exercise $id has invalid difficulty: $difficulty');
      }
      if (!validMusclesEn.contains(targetMuscle)) {
        throw Exception(
          'Exercise $id has invalid English targetMuscle: $targetMuscle',
        );
      }
      if (equipment.isEmpty) {
        throw Exception('Exercise $id has empty equipment');
      }
      if (imageUrl.isEmpty ||
          (!imageUrl.startsWith('https://') &&
              !imageUrl.startsWith('android.resource://'))) {
        throw Exception('Exercise $id has invalid imageUrl: $imageUrl');
      }
      if (description.isEmpty) {
        throw Exception('Exercise $id has empty description');
      }
      if (isPremium is! bool) {
        throw Exception('Exercise $id has non-boolean isPremium');
      }

      enMap[id] = map;
    }

    for (final item in dataVi) {
      final map = item as Map<String, dynamic>;
      final String id = map['id'] ?? '';
      final String name = map['name'] ?? '';
      final String difficulty = map['difficulty'] ?? '';
      final String targetMuscle = map['targetMuscle'] ?? '';
      final String equipment = map['equipment'] ?? '';
      final String imageUrl = map['imageUrl'] ?? '';
      final String description = map['description'] ?? '';
      final dynamic isPremium = map['isPremium'];

      if (id.isEmpty) {
        throw Exception('Found exercise with empty ID in Vietnamese DB');
      }
      if (!enMap.containsKey(id)) {
        throw Exception('Vietnamese ID $id not found in English DB');
      }
      if (name.isEmpty) {
        throw Exception('Exercise $id in VI has empty name');
      }
      if (!validDifficulties.contains(difficulty)) {
        throw Exception(
          'Exercise $id in VI has invalid difficulty: $difficulty',
        );
      }
      if (!validMusclesVi.contains(targetMuscle)) {
        throw Exception(
          'Exercise $id in VI has invalid Vietnamese targetMuscle: $targetMuscle',
        );
      }
      if (equipment.isEmpty) {
        throw Exception('Exercise $id in VI has empty equipment');
      }
      if (imageUrl.isEmpty ||
          (!imageUrl.startsWith('https://') &&
              !imageUrl.startsWith('android.resource://'))) {
        throw Exception('Exercise $id in VI has invalid imageUrl: $imageUrl');
      }
      if (description.isEmpty) {
        throw Exception('Exercise $id in VI has empty description');
      }
      if (isPremium is! bool) {
        throw Exception('Exercise $id in VI has non-boolean isPremium');
      }
    }

    stdout.writeln(
      'DATABASE VALIDATION SUCCESSFUL: Verified ${dataEn.length} exercises across languages.',
    );
  } catch (e) {
    stderr.writeln('DATABASE VALIDATION FAILED: $e');
    exit(1);
  }
}
