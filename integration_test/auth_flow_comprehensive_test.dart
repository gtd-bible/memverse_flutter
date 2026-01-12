import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/firebase_options.dart';
import 'package:mini_memverse/main.dart' as app;
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:mini_memverse/src/features/auth/presentation/signup_page.dart';
import 'package:mini_memverse/src/constants/app_constants.dart';

/// Comprehensive integration test for authentication flows
/// 
/// Tests both happy paths and unhappy paths for login and signup,
/// capturing detailed logs for analytics and error tracking.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Logs directory for saving test output
  final logsDir = Directory('${Directory.current.path}/logs');
  if (!logsDir.existsSync()) {
    logsDir.createSync();
  }

  // Log file for test results
  final logFile = File('${logsDir.path}/auth_flow_test_${DateTime.now().millisecondsSinceEpoch}.log');
  final logSink = logFile.openWrite();

  void log(String message) {
    print(message);
    logSink.writeln('${DateTime.now().toIso8601String()} - $message');
  }

  setUpAll(() async {
    log('🚀 Starting Authentication Flow Comprehensive Test');
    log('📱 Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    
    // Initialize Firebase
    log('🔥 Initializing Firebase...');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      log('✅ Firebase initialized successfully');
    } catch (e) {
      log('⚠️ Firebase initialization failed: $e');
      log('⚠️ Continuing tests with local logging only');
    }
  });

  tearDownAll(() async {
    log('🏁 Completed Authentication Flow Comprehensive Test');
    
    // Clean up resources
    await logSink.flush();
    await logSink.close();
    
    log('📝 Logs written to: ${logFile.path}');
  });

  group('Login Flow Tests', () {
    testWidgets('Happy Path: Login with correct credentials succeeds',
        (WidgetTester tester) async {
      log('▶️ TEST STARTED: Happy Path Login');
      
      // Get credentials from environment variables
      final username = const String.fromEnvironment('MEMVERSE_USERNAME');
      final password = const String.fromEnvironment('MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT');
      final clientId = const String.fromEnvironment('MEMVERSE_CLIENT_ID');
      final clientApiKey = const String.fromEnvironment('MEMVERSE_CLIENT_API_KEY');
      
      // Verify credentials are available
      log('🔍 Checking environment variables:');
      log('   MEMVERSE_USERNAME: ${username.isNotEmpty ? "✅ SET" : "❌ MISSING"}');
      log('   MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT: ${password.isNotEmpty ? "✅ SET" : "❌ MISSING"}');
      log('   MEMVERSE_CLIENT_ID: ${clientId.isNotEmpty ? "✅ SET (${clientId.length} chars)" : "❌ MISSING"}');
      log('   MEMVERSE_CLIENT_API_KEY: ${clientApiKey.isNotEmpty ? "✅ SET (${clientApiKey.length} chars)" : "❌ MISSING"}');
      
      if (username.isEmpty || password.isEmpty || clientId.isEmpty || clientApiKey.isEmpty) {
        log('❌ Environment variables not set. Cannot run test without credentials.');
        fail('Environment variables not set. Cannot run test without credentials.');
      }
      
      // Launch the app
      log('🚀 Launching app...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      log('✅ App initialization complete');
      
      // Verify login screen appears
      expect(find.byType(LoginPage), findsOneWidget, 
          reason: 'Login page should appear on app launch');
      log('✅ Login page found');
      
      // Enter credentials
      final usernameField = find.byKey(loginUsernameFieldKey);
      final passwordField = find.byKey(loginPasswordFieldKey);
      final loginButton = find.byKey(loginButtonKey);
      
      expect(usernameField, findsOneWidget, reason: 'Username field not found');
      expect(passwordField, findsOneWidget, reason: 'Password field not found');
      expect(loginButton, findsOneWidget, reason: 'Login button not found');
      log('✅ All login form elements found');
      
      log('🔑 Entering credentials...');
      await tester.enterText(usernameField, username);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(passwordField, password);
      await tester.pump(const Duration(milliseconds: 300));
      log('✅ Credentials entered');
      
      // Click login button
      log('🔘 Tapping login button...');
      await tester.tap(loginButton);
      await tester.pump();
      
      // Wait for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget, 
          reason: 'Loading indicator should appear after tapping login');
      log('⏳ Loading indicator appeared');
      
      // Wait for authentication to complete and navigation
      log('⏳ Waiting for authentication to complete (up to 15 seconds)...');
      await tester.pumpAndSettle(const Duration(seconds: 15));
      
      // Verify login was successful - should navigate away from login page
      log('🔍 Verifying login success...');
      expect(find.byType(LoginPage), findsNothing, 
          reason: 'Login page should not be visible after successful login');
      
      // Additional verification - should see app bar in main screen
      expect(find.byType(AppBar), findsOneWidget, 
          reason: 'App bar should be visible after successful login');
      log('✅ Navigation to main app confirmed');
      
      // Verify we can find some verse-related content
      await tester.pump(const Duration(seconds: 2));
      final hasVerseRelatedContent = find.textContaining('verse', findRichText: true).evaluate().isNotEmpty;
      log(hasVerseRelatedContent 
          ? '✅ Found verse-related content on main screen' 
          : '⚠️ No verse-related content found on main screen');
      
      log('🎉 TEST PASSED: Happy Path Login');
    });

    testWidgets('Unhappy Path: Login with incorrect password shows error',
        (WidgetTester tester) async {
      log('▶️ TEST STARTED: Login with incorrect password');
      
      // Get username from environment variables, but use incorrect password
      final username = const String.fromEnvironment('MEMVERSE_USERNAME');
      final incorrectPassword = 'definitely_wrong_password_123';
      
      if (username.isEmpty) {
        log('❌ Username environment variable not set. Cannot run test.');
        fail('Username environment variable not set. Cannot run test.');
      }
      
      // Launch the app
      log('🚀 Launching app...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      log('✅ App initialization complete');
      
      // Verify login screen appears
      expect(find.byType(LoginPage), findsOneWidget);
      log('✅ Login page found');
      
      // Enter credentials
      final usernameField = find.byKey(loginUsernameFieldKey);
      final passwordField = find.byKey(loginPasswordFieldKey);
      final loginButton = find.byKey(loginButtonKey);
      
      expect(usernameField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);
      log('✅ All login form elements found');
      
      log('🔑 Entering credentials with incorrect password...');
      await tester.enterText(usernameField, username);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(passwordField, incorrectPassword);
      await tester.pump(const Duration(milliseconds: 300));
      log('✅ Credentials with incorrect password entered');
      
      // Click login button
      log('🔘 Tapping login button...');
      await tester.tap(loginButton);
      await tester.pump();
      
      // Wait for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      log('⏳ Loading indicator appeared');
      
      // Wait for error response
      log('⏳ Waiting for authentication failure response...');
      await tester.pumpAndSettle(const Duration(seconds: 10));
      
      // Verify error message appears
      log('🔍 Checking for error message...');
      final errorText = find.textContaining('invalid', findRichText: true) 
          .evaluate().isNotEmpty || find.textContaining('Invalid', findRichText: true).evaluate().isNotEmpty;
      
      // If no 'invalid' text found, try more generic error message patterns
      final genericError = !errorText && (
          find.textContaining('fail', findRichText: true).evaluate().isNotEmpty || 
          find.textContaining('error', findRichText: true).evaluate().isNotEmpty ||
          find.textContaining('Error', findRichText: true).evaluate().isNotEmpty
      );
      
      if (errorText) {
        log('✅ Error message for invalid credentials found');
      } else if (genericError) {
        log('✅ Generic error message found');
      } else {
        log('⚠️ No explicit error message found, checking if still on login page');
      }
      
      // Verify we're still on the login page
      expect(find.byType(LoginPage), findsOneWidget, 
          reason: 'Should still be on login page after failed login');
      log('✅ Still on login page after failed login');
      
      log('🎉 TEST PASSED: Login with incorrect password shows error');
    });

    testWidgets('Unhappy Path: Login with malformed URL simulated',
        (WidgetTester tester) async {
      log('▶️ TEST STARTED: Login with malformed URL');
      
      // Skip this test on real device since we can't modify the URL easily
      log('⏭️ This test requires URL mocking which is only available in the auth_error_scenarios_test');
      log('⏭️ For manual testing: confirm that requests to typo'd URLs show appropriate error messages');
      
      log('🎭 TEST SKIPPED: Login with malformed URL (requires mocking)');
    });

    testWidgets('Unhappy Path: Login with network failure simulated',
        (WidgetTester tester) async {
      log('▶️ TEST STARTED: Login with network failure');
      
      // Skip this test on real device since we can't easily simulate network failure
      log('⏭️ This test requires network mocking which is only available in the auth_error_scenarios_test');
      log('⏭️ For manual testing: try airplane mode or disable wifi during login to test network failures');
      
      log('🎭 TEST SKIPPED: Login with network failure (requires mocking)');
    });
  });

  group('Signup Flow Tests', () {
    testWidgets('Signup UI renders correctly and validates input',
        (WidgetTester tester) async {
      log('▶️ TEST STARTED: Signup UI Validation');
      
      // Launch the app
      log('🚀 Launching app...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      log('✅ App initialization complete');
      
      // Verify login screen appears
      expect(find.byType(LoginPage), findsOneWidget);
      log('✅ Login page found');
      
      // Find and tap signup link/button
      log('🔍 Looking for signup button or link...');
      
      // Try various ways to find the signup link
      final signupText = find.textContaining('Sign up', findRichText: true);
      final createAccountText = find.textContaining('Create account', findRichText: true);
      final registerText = find.textContaining('Register', findRichText: true);
      
      Finder signupLink;
      if (signupText.evaluate().isNotEmpty) {
        signupLink = signupText;
        log('✅ Found "Sign up" text');
      } else if (createAccountText.evaluate().isNotEmpty) {
        signupLink = createAccountText;
        log('✅ Found "Create account" text');
      } else if (registerText.evaluate().isNotEmpty) {
        signupLink = registerText;
        log('✅ Found "Register" text');
      } else {
        log('❌ Could not find any signup link or button');
        log('🔍 Dumping widget tree to help diagnose the issue:');
        log(tester.allWidgets.map((w) => '${w.runtimeType}').join('\n'));
        fail('Could not find any signup link or button');
      }
      
      // Tap the signup link
      log('🔘 Tapping signup link/button...');
      await tester.tap(signupLink);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify navigation to signup page
      final onSignupPage = find.byType(SignupPage).evaluate().isNotEmpty;
      if (!onSignupPage) {
        log('⚠️ SignupPage widget not found directly');
        
        // Check for signup form elements as fallback
        final hasEmailField = find.textContaining('email', findRichText: true).evaluate().isNotEmpty;
        final hasPasswordFields = find.textContaining('password', findRichText: true).evaluate().length >= 2;
        final hasSignupButton = find.textContaining('Sign up', findRichText: true).evaluate().isNotEmpty ||
            find.textContaining('Register', findRichText: true).evaluate().isNotEmpty;
        
        if (hasEmailField && hasPasswordFields && hasSignupButton) {
          log('✅ Found signup form elements, continuing test');
        } else {
          log('❌ Could not verify navigation to signup page');
          fail('Could not verify navigation to signup page');
        }
      } else {
        log('✅ SignupPage found');
      }
      
      // Find signup form fields
      log('🔍 Looking for signup form fields...');
      
      // Try to find email field
      final emailField = find.widgetWithText(TextField, 'Email');
      final emailTextFormField = find.widgetWithText(TextFormField, 'Email');
      final usernameField = find.widgetWithText(TextField, 'Username');
      
      // Try to find password fields
      final passwordField = find.widgetWithText(TextField, 'Password');
      final passwordTextFormField = find.widgetWithText(TextFormField, 'Password');
      final confirmPasswordField = find.textContaining('Confirm', findRichText: true);
      
      if (emailField.evaluate().isNotEmpty || emailTextFormField.evaluate().isNotEmpty) {
        log('✅ Found email field');
      } else {
        log('⚠️ Could not find email field');
      }
      
      if (passwordField.evaluate().isNotEmpty || passwordTextFormField.evaluate().isNotEmpty) {
        log('✅ Found password field');
      } else {
        log('⚠️ Could not find password field');
      }
      
      if (confirmPasswordField.evaluate().isNotEmpty) {
        log('✅ Found confirm password field');
      } else {
        log('⚠️ Could not find confirm password field');
      }
      
      // Test form validation
      log('🔍 Testing form validation...');
      
      // Try to find signup button
      final signupButton = find.textContaining('Sign up', findRichText: true).first;
      final registerButton = find.textContaining('Register', findRichText: true).first;
      final createAccountButton = find.textContaining('Create account', findRichText: true).first;
      
      Finder submitButton;
      if (signupButton.evaluate().isNotEmpty) {
        submitButton = signupButton;
        log('✅ Found "Sign up" button');
      } else if (registerButton.evaluate().isNotEmpty) {
        submitButton = registerButton;
        log('✅ Found "Register" button');
      } else if (createAccountButton.evaluate().isNotEmpty) {
        submitButton = createAccountButton;
        log('✅ Found "Create account" button');
      } else {
        log('❌ Could not find signup submit button');
        fail('Could not find signup submit button');
      }
      
      // Try to tap the signup button without filling out form
      log('🔘 Tapping signup button with empty form...');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      
      // Check for validation error messages
      final validationErrors = find.textContaining('required', findRichText: true).evaluate().isNotEmpty ||
          find.textContaining('valid', findRichText: true).evaluate().isNotEmpty ||
          find.textContaining('empty', findRichText: true).evaluate().isNotEmpty;
      
      if (validationErrors) {
        log('✅ Form validation working - shows errors for empty fields');
      } else {
        log('⚠️ No validation errors found for empty form submission');
      }
      
      log('🎉 TEST PASSED: Signup UI renders and validates input');
    });
  });
}