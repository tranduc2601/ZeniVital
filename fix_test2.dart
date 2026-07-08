import 'dart:io';

void main() {
  var file = File('D:/Trenx_Flutter/integration_test/app_test.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
    "await tester.tap(find.byKey(const Key('profile_liked_tab')));",
    "final likedTab = find.byKey(const Key('profile_liked_tab')); await tester.ensureVisible(likedTab); await tester.tap(likedTab);"
  );

  content = content.replaceAll(
    "await tester.tap(find.byKey(const Key('profile_settings_btn')));",
    "final settingsBtn = find.byKey(const Key('profile_settings_btn')); await tester.ensureVisible(settingsBtn); await tester.tap(settingsBtn);"
  );

  content = content.replaceAll(
    "await tester.tap(find.byKey(const Key('profile_fitness_test_btn')));",
    "final fitBtn = find.byKey(const Key('profile_fitness_test_btn')); await tester.ensureVisible(fitBtn); await tester.tap(fitBtn);"
  );

  file.writeAsStringSync(content);
}
