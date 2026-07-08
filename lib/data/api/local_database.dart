import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user.dart';
import '../../domain/models/routine.dart';
import '../../domain/models/workout_log.dart';
import '../../domain/models/feed_post.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._();
  LocalDatabase._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Locale
  String getLocale() => _prefs.getString('locale') ?? 'en';
  Future<void> setLocale(String lang) async => await _prefs.setString('locale', lang);

  // User & Profile
  User? getUser() {
    final str = _prefs.getString('current_user');
    if (str == null) return null;
    try {
      final map = jsonDecode(str) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    await _prefs.setString('current_user', jsonEncode(user.toJson()));
  }

  Future<void> deleteUser() async {
    await _prefs.remove('current_user');
  }

  Future<void> logout() async {
    await deleteUser();
  }

  Future<void> updateGoal(GoalType goal) async {
    var user = getUser();
    if (user != null) {
      await saveUser(user.copyWith(goal: goal));
    }
  }

  // Liked Exercises
  Set<String> getLikedExercises() {
    final list = _prefs.getStringList('liked_exercises') ?? [];
    return list.toSet();
  }

  Future<void> saveLikedExercises(Set<String> ids) async {
    await _prefs.setStringList('liked_exercises', ids.toList());
  }

  bool isLiked(String id) => getLikedExercises().contains(id);

  Future<void> toggleLike(String id) async {
    final likes = getLikedExercises();
    if (likes.contains(id)) {
      likes.remove(id);
    } else {
      likes.add(id);
    }
    await saveLikedExercises(likes);
  }

  // Kudoed Posts
  Set<String> getKudoedPosts() {
    final list = _prefs.getStringList('kudoed_posts') ?? [];
    return list.toSet();
  }

  Future<void> saveKudoedPosts(Set<String> ids) async {
    await _prefs.setStringList('kudoed_posts', ids.toList());
  }

  bool isKudoed(String id) => getKudoedPosts().contains(id);

  Future<void> toggleKudo(String id) async {
    final kudos = getKudoedPosts();
    if (kudos.contains(id)) {
      kudos.remove(id);
    } else {
      kudos.add(id);
    }
    await saveKudoedPosts(kudos);
  }

  // Custom Routines
  List<Routine> getRoutines() {
    final list = _prefs.getStringList('routines') ?? [];
    return list.map((s) => Routine.fromJson(jsonDecode(s))).toList();
  }

  Future<void> saveRoutines(List<Routine> routines) async {
    final list = routines.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList('routines', list);
  }

  Future<void> saveCustomRoutine(Routine routine) async {
    final routines = getRoutines();
    routines.add(routine);
    await saveRoutines(routines);
  }

  // Workout Logs
  List<WorkoutLog> getWorkoutLogs() {
    final str = _prefs.getString('workout_logs');
    if (str == null) return [];
    try {
      final list = jsonDecode(str) as List;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        return WorkoutLog(
          id: map['id'],
          completedAt: DateTime.parse(map['completedAt']),
          durationSeconds: map['durationSeconds'],
          goalType: GoalType.values.firstWhere(
            (gt) => gt.name == map['goalType'],
            orElse: () => GoalType.conditioning,
          ),
          totalVolume: (map['totalVolume'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addWorkoutLog(WorkoutLog log) async {
    final logs = getWorkoutLogs();
    logs.add(log);
    final listMap = logs.map((l) => {
      'id': l.id,
      'completedAt': l.completedAt.toIso8601String(),
      'durationSeconds': l.durationSeconds,
      'goalType': l.goalType.name,
      'totalVolume': l.totalVolume,
    }).toList();
    await _prefs.setString('workout_logs', jsonEncode(listMap));
  }
  
  int get workoutCount {
    final str = _prefs.getString('workout_logs');
    if (str == null) return 0;
    try {
      final list = jsonDecode(str) as List;
      return list.length;
    } catch (_) {
      return 0;
    }
  }

  // Feed Posts
  List<FeedPost> getFeedPosts() {
    final str = _prefs.getString('feed_posts');
    if (str == null) return [];
    try {
      final list = jsonDecode(str) as List;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        return FeedPost(
          id: map['id'],
          userName: map['userName'],
          avatarUrl: map['avatarUrl'],
          content: map['content'],
          timestamp: DateTime.parse(map['timestamp']),
          initialKudos: map['initialKudos'] ?? 0,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addFeedPost(FeedPost post) async {
    final posts = getFeedPosts();
    posts.add(post);
    final listMap = posts.map((p) => {
      'id': p.id,
      'userName': p.userName,
      'avatarUrl': p.avatarUrl,
      'content': p.content,
      'timestamp': p.timestamp.toIso8601String(),
      'initialKudos': p.initialKudos,
    }).toList();
    await _prefs.setString('feed_posts', jsonEncode(listMap));
  }
}
