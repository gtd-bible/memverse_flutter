import 'package:flutter_test/flutter_test.dart';

/// Usage: I tap {string}
Future<void> iTap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}
