import 'package:flutter_test/flutter_test.dart';

/// Usage: the error should be recorded in Crashlytics with stack trace
Future<void> theErrorShouldBeRecordedInCrashlyticsWithStackTrace(
    WidgetTester tester) async {
  throw UnimplementedError();
}
