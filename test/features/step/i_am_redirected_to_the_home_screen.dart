import 'package:flutter_test/flutter_test.dart';
import 'common_steps.dart';

/// Usage: I am redirected to the home screen
Future<void> iAmRedirectedToTheHomeScreen(WidgetTester tester) async {
  await iWaitForAnimations(tester);
  await iSeeText(tester, 'Home Screen');
}
