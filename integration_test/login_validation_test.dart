import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart' as app;
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';

/// Integration test to verify login functionality works
/// Uses real API credentials from environment variables
/// Creates text files describing each state for manual screenshots
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Verification', () {
    testWidgets('Login with correct credentials succeeds', (WidgetTester tester) async {
      // Ensure screenshots directory exists
      final dir = Directory('/Users/neil/code/gtd_bible_verses/memverse_flutter/screenshots');
      if (!dir.existsSync()) {
        dir.createSync();
      }

      // Get credentials from environment variables
      final username = const String.fromEnvironment('MEMVERSE_USERNAME');
      final password = const String.fromEnvironment('MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT');

      // Print environment status
      print('🔍 Environment variables checked');

      // Verify credentials are available
      if (username.isEmpty || password.isEmpty) {
        fail('Environment variables not set. Cannot run test without credentials.');
      }

      // Launch the app
      print('🚀 Launching app...');
      app.main();

      // First pump - initial frame
      await tester.pump();
      print('✅ First frame rendered');

      // Pump for a few seconds to allow app to initialize
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('✅ App initialization complete');

      // Log login screen state
      await _logWidgetState(tester, 'step1_login_screen');
      print('📝 Logged: step1_login_screen');

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

      // Log credentials entered state
      await _logWidgetState(tester, 'step2_credentials_entered');
      print('📝 Logged: step2_credentials_entered');

      print('✅ Credentials entered');

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

      // Log loading state
      await _logWidgetState(tester, 'step3_loading');
      print('📝 Logged: step3_loading');
      print('⏳ Loading indicator appeared');

      // Wait for authentication to complete and navigation
      print('⏳ Waiting for authentication to complete...');
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Log successful login state
      await _logWidgetState(tester, 'step4_successful_login');
      print('📝 Logged: step4_successful_login');

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
        '📝 Detailed logs saved in /Users/neil/code/gtd_bible_verses/memverse_flutter/screenshots/',
      );

      // Add final summary
      final summary = File(
        '/Users/neil/code/gtd_bible_verses/memverse_flutter/screenshots/test_summary.txt',
      );
      await summary.writeAsString('''
INTEGRATION TEST SUMMARY
=======================
Test: Login Validation
Status: ✅ PASSED
Time: ${DateTime.now()}

Steps Completed:
1. Login screen displayed correctly ✅
2. Credentials entered successfully ✅ 
3. Loading indicator displayed ✅
4. Authentication completed successfully ✅
5. Navigated to main app screen ✅

The app successfully authenticates with the Memverse API and navigates to the main screen.
This validates that the sign-in functionality works properly.
''');
    });
  });
}

/// Log the current widget state for later reference
Future<void> _logWidgetState(WidgetTester tester, String stepName) async {
  final logFile = File(
    '/Users/neil/code/gtd_bible_verses/memverse_flutter/screenshots/$stepName.log',
  );

  // Get visible widgets
  final widgetTypes = tester.allWidgets.map((w) => w.runtimeType.toString()).toList();
  final textWidgets = tester.widgetList(find.byType(Text)).map((w) => (w as Text).data).toList();

  final content =
      '''
TEST STEP: $stepName
TIMESTAMP: ${DateTime.now()}
------------------------------------------------------------
VISIBLE WIDGET TYPES:
${widgetTypes.join('\n')}

VISIBLE TEXT:
${textWidgets.join('\n')}

WIDGET COUNT: ${tester.allWidgets.length}
TEXT WIDGET COUNT: ${textWidgets.length}
TEXTFIELD COUNT: ${tester.widgetList(find.byType(TextField)).length}
BUTTON COUNT: ${tester.widgetList(find.byType(ElevatedButton)).length}
------------------------------------------------------------
''';

  await logFile.writeAsString(content);
}
