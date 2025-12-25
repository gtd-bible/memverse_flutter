import 'package:flutter_test/flutter_test.dart';
import 'i_tap.dart';

/// Usage: I tap "Login"
Future<void> iTapLogin(WidgetTester tester) async {
  await iTap(tester, 'Login');
}
