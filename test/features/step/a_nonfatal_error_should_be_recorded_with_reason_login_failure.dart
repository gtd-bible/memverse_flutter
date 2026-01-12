import 'package:flutter_test/flutter_test.dart';

/// Usage: a non-fatal error should be recorded with reason "Login failure"
Future<void> aNonfatalErrorShouldBeRecordedWithReasonLoginFailure(
    WidgetTester tester) async {
  throw UnimplementedError();
}
