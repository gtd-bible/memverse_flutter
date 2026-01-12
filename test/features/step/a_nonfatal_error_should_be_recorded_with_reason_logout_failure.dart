import 'package:flutter_test/flutter_test.dart';

/// Usage: a non-fatal error should be recorded with reason "Logout failure"
Future<void> aNonfatalErrorShouldBeRecordedWithReasonLogoutFailure(
    WidgetTester tester) async {
  throw UnimplementedError();
}
