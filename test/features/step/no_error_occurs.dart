import 'package:flutter_test/flutter_test.dart';

/// Usage: no error occurs
Future<void> noErrorOccurs(WidgetTester tester) async {
  throw UnimplementedError();
}
