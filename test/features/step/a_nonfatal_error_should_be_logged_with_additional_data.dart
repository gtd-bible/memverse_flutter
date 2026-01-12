import 'package:flutter_test/flutter_test.dart';

/// Usage: a non-fatal error should be logged with additional data
Future<void> aNonfatalErrorShouldBeLoggedWithAdditionalData(
    WidgetTester tester) async {
  throw UnimplementedError();
}
