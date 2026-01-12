import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart' as app;
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';

/// Happy path test on iOS simulator: app launch → real login → verify success
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('iOS Happy Path: App launch → real login → success', (WidgetTester tester) async {
    debugPrint('🎉 Starting iOS happy path test with real credentials');

    // Verify environment variables are set
    const username = String.fromEnvironment('MEMVERSE_USERNAME');
    const password = String.fromEnvironment('MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT');
    const clientId = String.fromEnvironment('MEMVERSE_CLIENT_ID');
    const clientSecret = String.fromEnvironment('MEMVERSE_CLIENT_API_KEY');

    if (username.isEmpty || password.isEmpty || clientId.isEmpty || clientSecret.isEmpty) {
      throw Exception('Environment variables not set properly');
    }

    debugPrint('✅ Environment variables verified (all non-empty)');

    // Step 1: Launch app exactly as users do
    debugPrint('📱 Launching app on iOS simulator...');
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify app launched
    expect(find.byType(MaterialApp), findsOneWidget);
    debugPrint('✅ App launched successfully on iOS');

    // Step 2: Check if on login screen
    final loginPage = find.byType(LoginPage);
    if (loginPage.evaluate().isNotEmpty) {
      debugPrint('🔐 On login screen - proceeding with real login');

      // Step 3: Use real credentials from environment
      final realUsername = username;
      final realPassword = password;

      // Find and fill fields
      final usernameField = find.byKey(loginUsernameFieldKey);
      final passwordField = find.byKey(loginPasswordFieldKey);

      expect(usernameField, findsOneWidget, reason: 'Username field should exist');
      expect(passwordField, findsOneWidget, reason: 'Password field should exist');

      await tester.enterText(usernameField, realUsername);
      await tester.enterText(passwordField, realPassword);
      await tester.pump(const Duration(milliseconds: 500));

      debugPrint('📝 Entered real credentials');

      // Step 4: Tap sign in button
      final signInButton = find.byKey(loginButtonKey);
      expect(signInButton, findsOneWidget, reason: 'Sign in button should exist');

      await tester.tap(signInButton);
      await tester.pump();

      // Step 5: Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      debugPrint('⏳ Loading indicator appeared');

      // Step 6: Wait for real authentication
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Step 7: Verify navigation away from login
      expect(
        find.byKey(loginButtonKey),
        findsNothing,
        reason: 'Should navigate away from login screen',
      );

      // Step 8: Verify app bar appears (successful navigation)
      expect(
        find.byType(AppBar),
        findsOneWidget,
        reason: 'App bar should appear after successful login',
      );

      debugPrint('🎉 Real login successful - navigated to main app');
    } else {
      debugPrint('ℹ️ Not on login screen (may already be authenticated)');
      expect(find.byType(AppBar), findsOneWidget, reason: 'App bar should be visible');
    }

    // Step 9: Verify app remains stable
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(MaterialApp), findsOneWidget, reason: 'App should remain stable');

    debugPrint('✅ iOS happy path test with real credentials PASSED');
  });
}
