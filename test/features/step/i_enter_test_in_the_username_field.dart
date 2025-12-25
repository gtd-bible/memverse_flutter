import 'package:flutter_test/flutter_test.dart';
import 'i_enter_in_the_field.dart';

/// Usage: I enter "test" in the "Username" field
Future<void> iEnterTestInTheUsernameField(WidgetTester tester) async {
  await iEnterInTheField(tester, 'test', 'Username');
}
