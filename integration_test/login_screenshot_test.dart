import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart' as app;
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:screenshot_callback/screenshot_callback.dart';

/// Integration test to verify login functionality works
/// Uses real API credentials from environment variables
/// Takes screenshots at key steps
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Verification with Screenshots', () {
    testWidgets('Login with correct credentials succeeds', (WidgetTester tester) async {
      // Get credentials from environment variables
      final username = const String.fromEnvironment('MEMVERSE_USERNAME');
      final password = const String.fromEnvironment('MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT');
      final clientId = const String.fromEnvironment('MEMVERSE_CLIENT_ID');
      final clientApiKey = const String.fromEnvironment('MEMVERSE_CLIENT_API_KEY');

      // Print environment variables for debugging
      print('🔍 Checking environment variables:');
      print('   MEMVERSE_USERNAME: ${username.isNotEmpty ? '✅ SET' : '❌ MISSING'}');
      print(
        '   MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT: ${password.isNotEmpty ? '✅ SET' : '❌ MISSING'}',
      );
      print(
        '   MEMVERSE_CLIENT_ID: ${clientId.isNotEmpty ? '✅ SET (${clientId.length} chars)' : '❌ MISSING'}',
      );
      print(
        '   MEMVERSE_CLIENT_API_KEY: ${clientApiKey.isNotEmpty ? '✅ SET (${clientApiKey.length} chars)' : '❌ MISSING'}',
      );

      // Verify credentials are available
      if (username.isEmpty || password.isEmpty || clientId.isEmpty || clientApiKey.isEmpty) {
        fail('Environment variables not set. Cannot run test without credentials.');
      }

      // Launch the app
      print('�� Launching app...');
      app.main();

      // First pump - initial frame
      await tester.pump();
      print('✅ First frame rendered');

      // Pump for a few seconds to allow app to initialize
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('✅ App initialization complete');

      // Create screenshot description for login screen
      await _saveScreenshotDescription(
        tester,
        'login_screen_initial',
        'Initial login screen showing username and password fields',
      );
      print('📝 Screenshot description saved: login_screen_initial');

      // Verify login screen appears
      expect(
        find.byType(LoginPage),
        findsOneWidget,
        reason: 'Login page should appear on app launch',
      );
      print('✅ Login page found');

      // Enter credentials
      final usernameField = find.byKey(loginUsernameFieldKey);
      final passwordField = find.byKey(loginPasswordFieldKey);
      final loginButton = find.byKey(loginButtonKey);

      expect(usernameField, findsOneWidget, reason: 'Username field not found');
      expect(passwordField, findsOneWidget, reason: 'Password field not found');
      expect(loginButton, findsOneWidget, reason: 'Login button not found');
      print('✅ Username field found');
      print('✅ Password field found');
      print('✅ Login button found');

      print('🔑 Entering credentials...');
      await tester.enterText(usernameField, username);
      await tester.enterText(passwordField, password);
      await tester.pump(const Duration(milliseconds: 500));

      // Create screenshot description for filled login form
      await _saveScreenshotDescription(
        tester,
        'login_credentials_entered',
        'Login form with username and password entered',
      );
      print('📝 Screenshot description saved: login_credentials_entered');

      print('✅ Credentials entered');
      print('   Username: $username');
      print('   Password: ${password.substring(0, 2)}*****');

      // Click login button
      print('🔘 Tapping login button...');
      await tester.tap(loginButton);
      await tester.pump();

      // Wait for loading indicator
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
        reason: 'Loading indicator should appear after tapping login',
      );

      // Create screenshot description for loading state
      await _saveScreenshotDescription(
        tester,
        'login_loading',
        'Loading indicator showing authentication in progress',
      );
      print('📝 Screenshot description saved: login_loading');
      print('⏳ Loading indicator appeared');

      // Wait for authentication to complete and navigation
      print('⏳ Waiting for authentication to complete...');
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Create screenshot description for successful login
      await _saveScreenshotDescription(
        tester,
        'login_successful',
        'Main app screen after successful login, showing dashboard',
      );
      print('📝 Screenshot description saved: login_successful');

      // Verify login was successful - should navigate away from login page
      print('🔍 Verifying login success...');
      expect(
        find.byType(LoginPage),
        findsNothing,
        reason: 'Login page should not be visible after successful login',
      );

      // Additional verification - should see app bar in main screen
      expect(
        find.byType(AppBar),
        findsOneWidget,
        reason: 'App bar should be visible after successful login',
      );

      print('🎉 Login successful! Navigated away from login screen');

      // Wait a moment to verify stability
      await tester.pump(const Duration(seconds: 2));

      print('✅ TEST PASSED: Login with correct credentials succeeds');
      print(
        '📝 All screenshot descriptions saved to: /Users/neil/code/gtd_bible_verses/memverse_flutter/screenshots/',
      );

      // Instruct user how to manually take screenshots
      print('\n📸 INSTRUCTIONS: To capture actual screenshots:');
      print('1. Open the iOS Simulator');
      print('2. Navigate to the app');
      print('3. Press Cmd+S to take a screenshot');
      print('4. Screenshots are saved to the desktop');
      print('5. Rename them according to the saved descriptions in the screenshots directory');
    });
  });
}

/// Helper method to save a screenshot description
/// Since taking actual screenshots in integration tests is challenging,
/// we'll save descriptions that can be paired with manually taken screenshots
Future<void> _saveScreenshotDescription(
  WidgetTester tester,
  String name,
  String description,
) async {
  final screenshotPath = '/Users/neil/code/gtd_bible_verses/memverse_flutter/screenshots/$name.txt';
  final file = File(screenshotPath);

  final content =
      '''
SCREENSHOT NAME: $name
DESCRIPTION: $description
TIMESTAMP: ${DateTime.now()}
VISIBLE WIDGETS: ${tester.allWidgets.map((w) => w.runtimeType).toList().join(', ')}
''';

  await file.writeAsBytes(utf8.encode(content));
}
