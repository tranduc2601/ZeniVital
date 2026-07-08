import 'dart:io';

void main() {
  var file = File('D:/Trenx_Flutter/lib/presentation/screens/main_tabs.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "return SingleChildScrollView(",
    "return SingleChildScrollView(\n      key: const Key('profile_screen'),"
  );
  file.writeAsStringSync(content);
}
