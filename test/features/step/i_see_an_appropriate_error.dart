import 'package:flutter_test/flutter_test.dart';

/// Usage: I see an appropriate error
Future<void> iSeeAnAppropriateError(WidgetTester tester) async {
  throw UnimplementedError();
}
