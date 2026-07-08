import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trenx/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  Future<void> skipSplashAndOnboarding(WidgetTester tester) async {
    await tester.pumpAndSettle();
    if (find.byKey(const Key('splash_screen')).evaluate().isNotEmpty) {
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    if (find.byKey(const Key('onboarding_pageview')).evaluate().isNotEmpty) {
      await tester.drag(find.byKey(const Key('onboarding_pageview')), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key('onboarding_pageview')), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('get_started_btn')));
      await tester.pumpAndSettle();
    }
  }

  Future<void> loginUser(WidgetTester tester, String email, String password) async {
    await skipSplashAndOnboarding(tester);
    if (find.byKey(const Key('login_btn')).evaluate().isNotEmpty) {
      await tester.enterText(find.byKey(const Key('login_email_field')), email);
      await tester.enterText(find.byKey(const Key('login_password_field')), password);
      await tester.tap(find.byKey(const Key('login_btn')));
      await tester.pumpAndSettle();
    }
  }

  group('Trenx E2E Integration Suite', () {
    testWidgets('TC-101: Application Launch and Splash Screen', (WidgetTester tester) async {
      app.main();
      await tester.pump();
      expect(find.byKey(const Key('splash_screen')), findsOneWidget);
    });

    testWidgets('TC-102: Onboarding Flow Navigation', (WidgetTester tester) async {
      app.main();
      await skipSplashAndOnboarding(tester);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    });

    testWidgets('TC-103: User Registration', (WidgetTester tester) async {
      app.main();
      await skipSplashAndOnboarding(tester);
      await tester.tap(find.byKey(const Key('go_to_register_btn')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('register_name_field')), TestData.testName);
      await tester.enterText(find.byKey(const Key('register_email_field')), TestData.testEmail);
      await tester.enterText(find.byKey(const Key('register_password_field')), TestData.testPassword);
      await tester.tap(find.byKey(const Key('register_submit_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dashboard_screen')), findsOneWidget);
    });

    testWidgets('TC-104: User Authentication (Login)', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      expect(find.byKey(const Key('dashboard_screen')), findsOneWidget);
    });

    testWidgets('TC-105: Bottom Navigation Panel Tab Navigation', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('tab_explore')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('explore_screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('tab_feed')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('feed_screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('tab_profile')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile_screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('tab_dashboard')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dashboard_screen')), findsOneWidget);
    });

    testWidgets('TC-106: Exercise Library Browsing and Search', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('tab_explore')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('exercise_search_field')), TestData.exerciseSquat);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, TestData.exerciseSquat), findsOneWidget);
    });

    testWidgets('TC-107: Exercise Detail and Liking', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('tab_explore')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TestData.exerciseSquat));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('exercise_detail_screen')), findsOneWidget);
      await tester.tap(find.byKey(const Key('exercise_like_btn')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail_back_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('explore_screen')), findsOneWidget);
    });

    testWidgets('TC-108: Workout Player Playback Session', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('workout_card_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('start_workout_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('workout_player_screen')), findsOneWidget);

      final nextBtn = find.byKey(const Key('player_next_btn'));
      while (tester.any(nextBtn)) {
        await tester.ensureVisible(nextBtn); await tester.tap(nextBtn);
        await tester.pumpAndSettle();
      }

      final finishBtn = find.byKey(const Key('player_finish_btn')); await tester.ensureVisible(finishBtn); await tester.tap(finishBtn);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('workout_summary_screen')), findsOneWidget);
      await tester.tap(find.byKey(const Key('summary_close_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dashboard_screen')), findsOneWidget);
    });

    testWidgets('TC-109: Community and Personal Feed Viewing', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('tab_feed')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('feed_screen')), findsOneWidget);
      expect(find.text('Maria Chen'), findsOneWidget);
    });

    testWidgets('TC-201: Authentication with Mismatched Credentials', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.wrongPassword);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('TC-202: Registration Form Field Validations', (WidgetTester tester) async {
      app.main();
      await skipSplashAndOnboarding(tester);
      await tester.tap(find.byKey(const Key('go_to_register_btn')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('register_submit_btn')));
      await tester.pumpAndSettle();
      expect(find.text('Name is required'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('register_name_field')), TestData.testName);
      await tester.enterText(find.byKey(const Key('register_email_field')), TestData.invalidEmail);
      await tester.enterText(find.byKey(const Key('register_password_field')), TestData.weakPassword);
      await tester.tap(find.byKey(const Key('register_submit_btn')));
      await tester.pumpAndSettle();
      expect(find.text('Invalid email format'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('TC-203: Search Empty State Response', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('tab_explore')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('exercise_search_field')), TestData.searchNonexistent);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('empty_search_state')), findsOneWidget);
    });

    testWidgets('TC-204: Workout Playback Navigation Guard', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('workout_card_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('start_workout_btn')));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('exit_confirm_dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('exit_confirm_no')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('exit_confirm_dialog')), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('exit_confirm_yes')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dashboard_screen')), findsOneWidget);
    });

    testWidgets('TC-206: Initial Database Empty State', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      expect(find.byKey(const Key('setup_instructions')), findsOneWidget);
    });

    testWidgets('TC-207: Rapid Interaction Input Throttle', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('tab_explore')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TestData.exerciseSquat));
      await tester.pumpAndSettle();

      final likeBtn = find.byKey(const Key('exercise_like_btn'));
      for (int i = 0; i < 10; i++) {
        await tester.tap(likeBtn);
      }
      await tester.pumpAndSettle();
      expect(find.text('Like'), findsOneWidget);
    });

    testWidgets('TC-301: Like Sync Between Explore and Liked List', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('tab_explore')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TestData.exerciseDeadlift));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('exercise_like_btn')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail_back_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tab_profile')));
      await tester.pumpAndSettle();
      final likedTab = find.byKey(const Key('profile_liked_tab')); await tester.ensureVisible(likedTab); await tester.tap(likedTab);
      await tester.pumpAndSettle();
      expect(find.text('Deadlift'), findsOneWidget);

      await tester.tap(find.byKey(const Key('liked_item_unlike_Deadlift')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tab_explore')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('exercise_liked_icon_Deadlift_active')), findsNothing);
    });

    testWidgets('TC-302: Workout Completion Sync with Dashboard Metrics', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      expect(find.text('0 completed · Tap to start'), findsOneWidget);

      await tester.tap(find.byKey(const Key('workout_card_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('start_workout_btn')));
      await tester.pumpAndSettle();

      final nextBtn = find.byKey(const Key('player_next_btn'));
      while (tester.any(nextBtn)) {
        await tester.ensureVisible(nextBtn); await tester.tap(nextBtn);
        await tester.pumpAndSettle();
      }
      final finishBtn = find.byKey(const Key('player_finish_btn')); await tester.ensureVisible(finishBtn); await tester.tap(finishBtn);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summary_close_btn')));
      await tester.pumpAndSettle();

      expect(find.text('1 completed · Tap to start'), findsOneWidget);
    });

    testWidgets('TC-303: Session Token Persistence', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      expect(find.byKey(const Key('dashboard_screen')), findsOneWidget);

      app.main();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dashboard_screen')), findsOneWidget);
    });

    testWidgets('TC-304: Profile Goal Change Exercises Recommendation Updates', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('tab_profile')));
      await tester.pumpAndSettle();
      final settingsBtn = find.byKey(const Key('profile_settings_btn')); await tester.ensureVisible(settingsBtn); await tester.tap(settingsBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('goal_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced Bodybuilding').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_save_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Advanced Bodybuilding Plan'), findsWidgets);
    });

    testWidgets('TC-305: Workout Share to Feed', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('workout_card_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('start_workout_btn')));
      await tester.pumpAndSettle();

      final nextBtn = find.byKey(const Key('player_next_btn'));
      while (tester.any(nextBtn)) {
        await tester.ensureVisible(nextBtn); await tester.tap(nextBtn);
        await tester.pumpAndSettle();
      }
      final finishBtn = find.byKey(const Key('player_finish_btn')); await tester.ensureVisible(finishBtn); await tester.tap(finishBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('share_to_feed_btn')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summary_close_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tab_feed')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Completed a 30-minute conditioning workout!'), findsOneWidget);
    });

    testWidgets('TC-401: End-to-End Weight Loss Journey Flow', (WidgetTester tester) async {
      app.main();
      await skipSplashAndOnboarding(tester);
      await tester.tap(find.byKey(const Key('go_to_register_btn')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('register_name_field')), TestData.testName);
      await tester.enterText(find.byKey(const Key('register_email_field')), TestData.testEmail);
      await tester.enterText(find.byKey(const Key('register_password_field')), TestData.testPassword);
      await tester.tap(find.byKey(const Key('register_submit_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tab_profile')));
      await tester.pumpAndSettle();
      final settingsBtn = find.byKey(const Key('profile_settings_btn')); await tester.ensureVisible(settingsBtn); await tester.tap(settingsBtn);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('goal_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weight Loss').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_save_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Weight Loss Plan'), findsWidgets);
      await tester.tap(find.byKey(const Key('tab_dashboard')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('workout_card_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('start_workout_btn')));
      await tester.pumpAndSettle();

      final nextBtn = find.byKey(const Key('player_next_btn'));
      while (tester.any(nextBtn)) {
        await tester.ensureVisible(nextBtn); await tester.tap(nextBtn);
        await tester.pumpAndSettle();
      }
      final finishBtn = find.byKey(const Key('player_finish_btn')); await tester.ensureVisible(finishBtn); await tester.tap(finishBtn);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summary_close_btn')));
      await tester.pumpAndSettle();

      expect(find.text('1 completed · Tap to start'), findsOneWidget);
    });

    testWidgets('TC-402: End-to-End Advanced Bodybuilding Workout Flow', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('tab_profile')));
      await tester.pumpAndSettle();
      final settingsBtn = find.byKey(const Key('profile_settings_btn')); await tester.ensureVisible(settingsBtn); await tester.tap(settingsBtn);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('goal_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced Bodybuilding').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_save_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tab_explore')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TestData.exerciseDeadlift));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('exercise_like_btn')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail_back_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tab_dashboard')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('workout_card_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('start_workout_btn')));
      await tester.pumpAndSettle();

      final nextBtn = find.byKey(const Key('player_next_btn'));
      while (tester.any(nextBtn)) {
        await tester.ensureVisible(nextBtn); await tester.tap(nextBtn);
        await tester.pumpAndSettle();
      }
      final finishBtn = find.byKey(const Key('player_finish_btn')); await tester.ensureVisible(finishBtn); await tester.tap(finishBtn);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('share_to_feed_btn')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summary_close_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tab_feed')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Completed a 30-minute bodybuilding workout!'), findsOneWidget);

      await tester.tap(find.byKey(const Key('tab_profile')));
      await tester.pumpAndSettle();
      final likedTab = find.byKey(const Key('profile_liked_tab')); await tester.ensureVisible(likedTab); await tester.tap(likedTab);
      await tester.pumpAndSettle();
      expect(find.text('Deadlift'), findsOneWidget);
    });

    testWidgets('TC-403: Fitness Diagnostic Assessment Flow', (WidgetTester tester) async {
      app.main();
      await loginUser(tester, TestData.testEmail, TestData.testPassword);
      await tester.tap(find.byKey(const Key('tab_profile')));
      await tester.pumpAndSettle();
      final fitBtn = find.byKey(const Key('profile_fitness_test_btn')); await tester.ensureVisible(fitBtn); await tester.tap(fitBtn);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('test_heart_rate')), '65');
      await tester.enterText(find.byKey(const Key('test_weight')), '75');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('test_perform_workout_btn')));
      await tester.tap(find.byKey(const Key('test_perform_workout_btn')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('test_submit_btn')));
      await tester.tap(find.byKey(const Key('test_submit_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Advanced Bodybuilding Plan'), findsWidgets);
    });
  });
}
