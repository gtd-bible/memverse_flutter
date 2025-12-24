import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/auth/presentation/views/login_screen.dart';

Future<void> iSeeTheLoginScreen(WidgetTester tester) async {
  expect(find.byType(LoginScreen), findsOneWidget);
}