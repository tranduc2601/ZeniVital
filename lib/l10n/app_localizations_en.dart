// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Trenx';

  @override
  String get slideOne => 'Slide 1';

  @override
  String get slideTwo => 'Slide 2';

  @override
  String get slideThree => 'Slide 3';

  @override
  String get getStarted => 'Get Started';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get goToRegister => 'Go to Register';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get name => 'Name';

  @override
  String get register => 'Register';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get searchExercises => 'Search Exercises';

  @override
  String get noExercisesFound => 'No exercises found';

  @override
  String get socialFeed => 'Social Feed';

  @override
  String get userProfile => 'User Profile';

  @override
  String get likedTab => 'Liked Tab';

  @override
  String get settings => 'Settings';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabFeed => 'Feed';

  @override
  String get tabProfile => 'Profile';

  @override
  String get like => 'Like';

  @override
  String get back => 'Back';

  @override
  String get startWorkout => 'Start Workout';

  @override
  String exerciseSet(int index) {
    return 'Exercise Set $index';
  }

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get closeSummary => 'Close Summary';

  @override
  String get selectGoal => 'Select Goal';

  @override
  String get goalWeightLoss => 'Weight Loss';

  @override
  String get goalConditioning => 'General Conditioning';

  @override
  String get goalBodybuilding => 'Advanced Bodybuilding';

  @override
  String get save => 'Save';

  @override
  String get logout => 'Logout';

  @override
  String unlike(String exercise) {
    return 'Unlike $exercise';
  }

  @override
  String currentPlan(String goal) {
    return '$goal Plan';
  }

  @override
  String get workoutOne => 'Workout 1';
}
