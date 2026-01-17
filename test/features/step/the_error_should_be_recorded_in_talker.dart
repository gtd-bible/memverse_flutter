import 'package:flutter_test/flutter_test.dart';

/// Usage: the error should be recorded in Talker
Future<void> theErrorShouldBeRecordedInTalker(WidgetTester tester) async {
  throw UnimplementedError();
}
