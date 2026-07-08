enum GoalType { weightLoss, conditioning, bodybuilding }

class User {
  final String id;
  final String name;
  final String email;
  final GoalType goal;
  
  // Health Profile Fields
  final double? height;
  final double? weight;
  final int? age;
  final String? level;
  final int? preferredDuration;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.goal,
    this.height,
    this.weight,
    this.age,
    this.level,
    this.preferredDuration,
  });

  bool get hasCompletedProfile => height != null && weight != null && age != null;

  User copyWith({
    String? id,
    String? name,
    String? email,
    GoalType? goal,
    double? height,
    double? weight,
    int? age,
    String? level,
    int? preferredDuration,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    goal: goal ?? this.goal,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    age: age ?? this.age,
    level: level ?? this.level,
    preferredDuration: preferredDuration ?? this.preferredDuration,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'goal': goal.index,
    'height': height,
    'weight': weight,
    'age': age,
    'level': level,
    'preferredDuration': preferredDuration,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      goal: GoalType.values[json['goal'] as int? ?? 0],
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      age: json['age'] as int?,
      level: json['level'] as String?,
      preferredDuration: json['preferredDuration'] as int?,
    );
  }
}

extension GoalTypeX on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.weightLoss:
        return 'Weight Loss Plan';
      case GoalType.conditioning:
        return 'Conditioning Plan';
      case GoalType.bodybuilding:
        return 'Advanced Bodybuilding Plan';
    }
  }
}
