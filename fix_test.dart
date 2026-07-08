import 'dart:io';

void main() {
  var file = File('D:/Trenx_Flutter/integration_test/app_test.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
    'await tester.tap(nextBtn);',
    'await tester.ensureVisible(nextBtn); await tester.tap(nextBtn);'
  );

  content = content.replaceAll(
    "await tester.tap(find.byKey(const Key('player_finish_btn')));",
    "final finishBtn = find.byKey(const Key('player_finish_btn')); await tester.ensureVisible(finishBtn); await tester.tap(finishBtn);"
  );

  file.writeAsStringSync(content);
}
