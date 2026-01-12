import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart' as app;

/// Ultra-minimal test that focuses purely on the happy path for auth
///
/// This test validates that a user can log in successfully with valid credentials.
/// It's intentionally kept small for reliability.
void main() {
  // Initialize integration test binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login with valid credentials navigates away from login page', (
    WidgetTester tester,
  ) async {
    // Get credentials from environment variables
    final username = Platform.environment['MEMVERSE_USERNAME'] ?? '';
    final password = Platform.environment['MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT'] ?? '';

    if (username.isEmpty || password.isEmpty) {
      print(
        '❌ Test requires MEMVERSE_USERNAME and MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT environment variables.',
      );
      return;
    }

    // Launch app using the real main() function
    print('🚀 Launching app...');
    await app.main();
    await tester.pumpAndSettle();

    // Verify we're on the login page
    expect(
      find.byKey(const Key('loginUsernameField')),
      findsOneWidget,
      reason: 'Should show username field',
    );
    expect(
      find.byKey(const Key('loginButton')),
      findsOneWidget,
      reason: 'Should show login button',
    );
    print('✓ App launched to login page');

    // Enter username
    print('📝 Entering username: $username');
    await tester.enterText(find.byKey(const Key('loginUsernameField')), username);

    // Enter password (masked for security)
    print(
      '🔑 Entering password: ${password.replaceRange(1, password.length, '*' * (password.length - 1))}',
    );
    await tester.enterText(find.byKey(const Key('loginPasswordField')), password);

    // Tap login button
    print('👆 Tapping login button...');
    await tester.tap(find.byKey(const Key('loginButton')));

    // Wait for login and navigation (7 seconds as requested)
    print('⏳ Waiting 7 seconds for API response and navigation...');
    await tester.pumpAndSettle(const Duration(seconds: 7));

    // Check that we're no longer on the login page
    expect(
      find.byKey(const Key('loginButton')),
      findsNothing,
      reason: 'Login button should not be visible after successful login',
    );

    print('🎉 TEST PASSED: Successfully logged in and navigated away from login page!');
  });
}
