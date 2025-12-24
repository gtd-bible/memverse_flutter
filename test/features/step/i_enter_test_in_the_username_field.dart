import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: I enter "test" in the username field
Future<void> iEnterTestInTheUsernameField(WidgetTester tester) async {
  final usernameFinder = find.widgetWithText(TextField, 'Username');
  await tester.enterText(usernameFinder, 'test');
  await tester.pump();
}
