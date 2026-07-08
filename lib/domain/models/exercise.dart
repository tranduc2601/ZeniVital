class Exercise {
  final String id;
  final String name;
  final String targetMuscle;
  final String difficulty;
  final String equipment;
  final String imageUrl;
  final String? gifUrl;
  final String description;
  final bool isPremium;
  final List<String> steps;
  final List<String> images;

  const Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.difficulty,
    required this.equipment,
    required this.imageUrl,
    this.gifUrl,
    required this.description,
    required this.isPremium,
    this.steps = const [],
    this.images = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final primaryMuscles = (json['primaryMuscles'] as List<dynamic>?) ?? [];
    final instructions = (json['instructions'] as List<dynamic>? ?? []).cast<String>();
    final imagesList = (json['images'] as List<dynamic>? ?? []).cast<String>();

    // ponytail: build real image URL from relative path in API via CDN to avoid 429 Too Many Requests
    const baseUrl = 'https://cdn.jsdelivr.net/gh/yuhonas/free-exercise-db@main/exercises/';
    final firstImage = imagesList.isNotEmpty ? '$baseUrl${imagesList[0]}' : '';

    return Exercise(
      id: (json['id'] as String?) ?? json['name'] as String,
      name: json['name'] as String,
      targetMuscle: primaryMuscles.isNotEmpty ? primaryMuscles[0] as String : 'unknown',
      difficulty: (json['level'] as String?) ?? 'beginner',
      equipment: (json['equipment'] as String?) ?? 'body only',
      imageUrl: firstImage,
      description: instructions.isNotEmpty ? instructions.first : '',
      isPremium: false,
      steps: instructions,
      images: imagesList.map((img) => '$baseUrl$img').toList(),
    );
  }
}
