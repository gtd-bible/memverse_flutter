import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/auth/presentation/views/login_screen.dart';
import 'common_steps.dart';

/// Usage: I am on the login screen
Future<void> iAmOnTheLoginScreen(WidgetTester tester) async {
  await iSeeWidget(tester, LoginScreen);
}
