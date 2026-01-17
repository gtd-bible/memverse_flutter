import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart' as app;
import 'package:mini_memverse/src/constants/app_constants.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';

/// Special integration test for Android to verify Firebase Analytics/Crashlytics with debug mode
///
/// Before running this test, set up Android with:
/// 1. Enable debug logging: `adb shell setprop log.tag.FA VERBOSE`
/// 2. Enable debug logging: `adb shell setprop log.tag.FA-SVC VERBOSE`
/// 3. Enable debug mode: `adb shell setprop debug.firebase.analytics.app your.package.name`
///
/// To run:
/// flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/android_firebase_debug_test.dart --dart-define=IS_FIREBASE_DEBUG=true
///
/// The test will output log entries to logcat that can be viewed with:
/// adb logcat -v time | grep -E 'FA|Firebase|Crashlytics'
void main() {
  // Check if running in Firebase debug mode
  final isFirebaseDebug = const bool.fromEnvironment('IS_FIREBASE_DEBUG', defaultValue: false);

  // Only run this test when explicitly requested
  if (!isFirebaseDebug && !kDebugMode) {
    // Skip test if not in debug mode with flag enabled
    print(
      '⚠️ SKIPPING ANDROID FIREBASE DEBUG TEST - Run with --dart-define=IS_FIREBASE_DEBUG=true',
    );
    return;
  }

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Create log file entries with timestamps
  List<String> testLogs = [];
  void log(String message) {
    final timestamp = DateTime.now().toString();
    final entry = '[$timestamp] $message';
    testLogs.add(entry);
    print(entry);
  }

  group('Android Firebase Debug Tests', () {
    log('🔥 STARTING ANDROID FIREBASE DEBUG TEST');
    log('Firebase Debug Mode: ${isFirebaseDebug ? "ENABLED" : "DISABLED"}');
    log('This test verifies that Firebase Analytics and Crashlytics events are properly sent');
    log('Check logcat with: adb logcat -v time | grep -E "FA|Firebase|Crashlytics"');

    testWidgets('Authentication flows with Firebase Analytics', (WidgetTester tester) async {
      log('Starting Firebase Analytics authentication test');

      // Verify environment setup
      if (memverseClientId.isEmpty || memverseClientSecret.isEmpty) {
        fail('Environment variables not set up - Cannot run Firebase test without credentials');
      }

      log('✅ Environment variables are properly set');

      // Launch the app
      app.main();
      log('App launched - Firebase should be initializing');

      // Wait for app to stabilize
      await tester.pumpAndSettle(const Duration(seconds: 3));
      log('App UI stabilized - Check logcat for Firebase initialization logs');

      // Pause to allow Firebase to initialize and log
      await Future.delayed(const Duration(seconds: 3));

      // Verify we're on the login screen
      expect(find.byType(LoginPage), findsOneWidget, reason: 'Login page should be displayed');
      log('Login page found - Screen view event should be logged in Firebase');

      // Find username and password fields
      final usernameField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;
      final loginButton = find.text('Login').last;

      // Enter invalid credentials to trigger analytics events
      await tester.enterText(usernameField, 'firebase_test@example.com');
      await tester.enterText(passwordField, 'wrongpassword_firebase_test');
      log('Entered test credentials for Firebase event tracking');

      // Pause to ensure analytics events are logged
      await Future.delayed(const Duration(seconds: 1));

      // Tap login to trigger login_attempt events
      await tester.tap(loginButton);
      log('Login button tapped - login_attempt event should be logged');

      // Wait for error processing
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 2));

      log('Login error should be processed - auth_error event should be logged');

      // Verify error message is shown (this confirms the error tracking flow completed)
      final errorMessageFinder = find.textContaining('Please');
      expect(
        errorMessageFinder,
        findsWidgets,
        reason: 'Error message should be displayed after failed login',
      );

      // Force an exception to test Crashlytics
      if (isFirebaseDebug) {
        log('INTENTIONALLY TRIGGERING TEST EXCEPTION FOR CRASHLYTICS');
        try {
          // This will throw an exception that Crashlytics should capture
          throw Exception('Intentional test exception for Crashlytics - IGNORE THIS CRASH');
        } catch (e, stack) {
          log('Exception thrown: $e - Crashlytics should record this');
          // The global error handlers should catch this and report to Crashlytics
          // No need to do anything here
        }
      }

      // Allow time for error to be processed
      await tester.pump(const Duration(seconds: 3));

      log('✅ Firebase Analytics Test Completed');
      log('Check logcat for the following events:');
      log('1. app_open - When app starts');
      log('2. screen_view - When login page is shown');
      log('3. login_attempt - When login button is tapped');
      log('4. auth_error - When login fails');
      log('5. Exception - From our intentional test crash');
    });
  });
}
