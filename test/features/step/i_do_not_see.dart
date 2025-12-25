import 'package:flutter_test/flutter_test.dart';

/// Usage: I do not see {string}
Future<void> iDoNotSee(WidgetTester tester, String text) async {
  expect(find.text(text), findsNothing);
}
