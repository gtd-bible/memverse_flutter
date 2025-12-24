import 'package:flutter_test/flutter_test.dart';
import 'common_steps.dart';

/// Usage: I see "Invalid username or password." error message
Future<void> iSeeInvalidUsernameOrPasswordErrorMessage(WidgetTester tester) async {
  await iSeeText(tester, 'Invalid username or password.');
}
