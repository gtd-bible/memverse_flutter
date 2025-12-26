import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memverse_flutter/main.dart' as app;

/// Complete demo mode integration test - NO MOCKING
/// Tests the entire user flow from launch to using demo mode features
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Demo Mode - Complete Integration (No Mocking)', () {
    testWidgets('user can launch app and see demo mode', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should see demo mode title
      expect(find.text('Scripture App (Demo)'), findsOneWidget);
    });

    testWidgets('complete happy path - add, view, and navigate', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Verify we're in demo mode
      expect(find.text('Scripture App (Demo)'), findsOneWidget);

      // Step 2: Should see Add Scripture button
      expect(find.text('Add Scripture'), findsOneWidget);

      // Step 3: Should see a list (empty or with default verses)
      expect(find.byType(ListView), findsOneWidget);

      // Step 4: Can tap add button to open form
      await tester.tap(find.text('Add Scripture'));
      await tester.pumpAndSettle();

      // Step 5: Form should be visible
      expect(find.text('Submit'), findsOneWidget);

      // Step 6: Close form
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Step 7: Back to main screen
      expect(find.text('Scripture App (Demo)'), findsOneWidget);
    });

    testWidgets('can view scripture details', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // If there are any scriptures, try to tap one
      final scriptureItems = find.byType(ListTile);
      if (tester.widgetList(scriptureItems).isNotEmpty) {
        await tester.tap(scriptureItems.first);
        await tester.pumpAndSettle();

        // Dialog should appear
        expect(find.byType(Dialog), findsOneWidget);

        // Close dialog
        await tester.tapAt(const Offset(10, 10)); // Tap outside
        await tester.pumpAndSettle();
      }
    });

    testWidgets('pull to refresh works', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find the RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Perform pull to refresh
      await tester.drag(refreshIndicator, const Offset(0, 300));
      await tester.pumpAndSettle();

      // Should still be on demo screen
      expect(find.text('Scripture App (Demo)'), findsOneWidget);
    });

    testWidgets('collections button is visible', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should have collections icon button in app bar
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('back button is visible', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should have back button in app bar
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
