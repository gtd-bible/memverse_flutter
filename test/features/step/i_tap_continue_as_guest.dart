import 'package:flutter_test/flutter_test.dart';

Future<void> iTapContinueAsGuest(WidgetTester tester) async {
  await tester.tap(find.text('Continue as Guest'));
  await tester.pumpAndSettle();
}