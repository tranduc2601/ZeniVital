import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trenx/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byKey(const Key('splash_screen')), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });
}
