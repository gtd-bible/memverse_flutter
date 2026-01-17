import 'package:flutter_test/flutter_test.dart';

/// Usage: relevant diagnostic information should be attached to the error
Future<void> relevantDiagnosticInformationShouldBeAttachedToTheError(
    WidgetTester tester) async {
  throw UnimplementedError();
}
