import 'dart:io';

void main() {
  // 1. Fix TC-401 in app_test.dart
  var file = File('D:/Trenx_Flutter/integration_test/app_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "expect(find.text('Weight Loss Plan'), findsWidgets);\n\n      await tester.tap(find.byKey(const Key('workout_card_0')));",
    "expect(find.text('Weight Loss Plan'), findsWidgets);\n      await tester.tap(find.byKey(const Key('tab_dashboard')));\n      await tester.pumpAndSettle();\n\n      await tester.tap(find.byKey(const Key('workout_card_0')));"
  );
  file.writeAsStringSync(content);

  // 2. Fix FeedScreen in main_tabs.dart
  file = File('D:/Trenx_Flutter/lib/presentation/screens/main_tabs.dart');
  content = file.readAsStringSync();
  content = content.replaceAll(
    "CircleAvatar(backgroundImage: NetworkImage(p.avatarUrl)),",
    "CircleAvatar(backgroundImage: p.avatarUrl.isNotEmpty ? NetworkImage(p.avatarUrl) : null, child: p.avatarUrl.isEmpty ? const Icon(Icons.person) : null),"
  );
  file.writeAsStringSync(content);

  // 3. Fix static_data.dart
  file = File('D:/Trenx_Flutter/lib/data/api/static_data.dart');
  content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"'https://example\.com/avatar.*\.jpg'"), "''");
  file.writeAsStringSync(content);

  // 4. Fix workout_screens.dart
  file = File('D:/Trenx_Flutter/lib/presentation/screens/workout_screens.dart');
  content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"'https://example\.com/avatar.*\.jpg'"), "''");
  file.writeAsStringSync(content);
}
