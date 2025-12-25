import 'package:flutter_test/flutter_test.dart';
import 'i_enter_in_the_field.dart';

/// Usage: I enter "password" in the "Password" field
Future<void> iEnterPasswordInThePasswordField(WidgetTester tester) async {
  await iEnterInTheField(tester, 'password', 'Password');
}
