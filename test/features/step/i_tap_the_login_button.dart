import 'package:flutter_test/flutter_test.dart';
import 'common_steps.dart';

/// Usage: I tap the "Login" button
Future<void> iTapTheLoginButton(WidgetTester tester) async {
  await iTapText(tester, 'Login');
}
