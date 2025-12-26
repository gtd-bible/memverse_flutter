import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/landing/landing_screen.dart';

void main() {
  group('LandingScreen', () {
    Widget buildTestWidget() {
      return const MaterialApp(
        home: LandingScreen(),
      );
    }

    testWidgets('displays "Go to Demo" button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.widgetWithText(ElevatedButton, 'Go to Demo'), findsOneWidget);
    });

    testWidgets('displays "Go to Signed-In Experience" button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.widgetWithText(ElevatedButton, 'Go to Signed-In Experience'),
          findsOneWidget);
    });

    // You can add more tests here to check navigation if you set up a Navigator observer
    // or mock the navigation. For now, we'll keep it simple as per the "simple and solid" request.
  });
}
