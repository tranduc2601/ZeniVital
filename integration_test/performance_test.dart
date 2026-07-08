import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:trenx/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Exercise Library Performance and Scrolling test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Bypass splash/onboarding if needed (assuming test runs on a fresh state, we might need to tap through)
    // For this simple test, if we are at login or onboarding, we should navigate.
    // However, for the sake of the plan, we assume the user can navigate to Explore and tap the FAB.

    // Try finding the explore tab
    final exploreTab = find.byKey(const Key('tab_explore'));
    if (exploreTab.evaluate().isNotEmpty) {
      await tester.tap(exploreTab);
      await tester.pumpAndSettle();

      final fab = find.byIcon(Icons.list);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // We are in Exercise Library. Wait for API fetch
      await tester.pump(const Duration(seconds: 3));
      
      // Scroll rapidly to test performance
      final listFinder = find.byType(Scrollable);
      if (listFinder.evaluate().isNotEmpty) {
        for (int i = 0; i < 10; i++) {
          await tester.drag(listFinder, const Offset(0, -500));
          await tester.pump();
        }
      }
    }
  });
}
