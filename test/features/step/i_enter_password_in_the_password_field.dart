import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: I enter "password" in the password field
Future<void> iEnterPasswordInThePasswordField(WidgetTester tester) async {
  final passwordFinder = find.widgetWithText(TextField, 'Password');
  await tester.enterText(passwordFinder, 'password');
  await tester.pump();
}
