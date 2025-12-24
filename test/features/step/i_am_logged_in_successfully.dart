import 'package:flutter_test/flutter_test.dart';
import '../utils/test_app_builder.dart';

/// Usage: I am logged in successfully
Future<void> iAmLoggedInSuccessfully(WidgetTester tester) async {
  expect(await isAuthenticatedInTest(), true);
}
