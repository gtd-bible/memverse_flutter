import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/demo_home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo mode - can see demo home screen', (tester) async {
    // Launch just the demo home screen directly (no Firebase needed)
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DemoHomeScreen(),
        ),
      ),
    );

    // Wait for initialization
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify we can see the demo screen title
    expect(
      find.text('Scripture App (Demo)'),
      findsOneWidget,
      reason: 'Demo home screen should display its title',
    );
  });
}
