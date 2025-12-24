import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memverse_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Signed-In Mode & Firebase Integration Tests', () {
    testWidgets('User can login, trigger Firebase events, and logout', (tester) async {
      // 1. Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Ensure we are on the Login screen
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);

      // 2. Log in with "test"/"password"
      await tester.enterText(find.byType(TextField).at(0), 'test');
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.pumpAndSettle(); // Allow text to be entered

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(); // Wait for login and navigation

      // 3. Verify successful login (now on Home Screen)
      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Welcome to MemVerse!'), findsOneWidget);

      // 4. Navigate to Settings screen via bottom nav bar
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify we are on Settings screen
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Test Crash'), findsOneWidget);
      expect(find.text('Test NFE'), findsOneWidget);

      // 5. Tap "Test Crash" button
      await tester.tap(find.text('Test Crash'));
      await tester.pumpAndSettle();
      // No expect here, as this will crash the app (or test runner)
      // If we don't crash, it means the button press worked without immediate error.

      // 6. Tap "Test NFE" button
      // Note: A real NFE test would require verifying Crashlytics logs remotely,
      // but here we just ensure the button tap doesn't throw a local error.
      await tester.tap(find.text('Test NFE'));
      await tester.pumpAndSettle();

      // 7. Navigate back to Home screen via bottom nav bar
      // This will ensure the app hasn't crashed due to the NFE button
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Verify back on Home screen
      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Welcome to MemVerse!'), findsOneWidget);

      // 8. Tap "Logout"
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle(); // Wait for logout and redirection

      // 9. Verify logout (redirected to Login screen)
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('Welcome to MemVerse!'), findsNothing); // Ensure Home screen is gone
    });
  });
}
