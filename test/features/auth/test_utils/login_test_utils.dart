import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';

/// Shared test utilities for login page testing
///
/// This class provides helper methods for testing login functionality
/// in both widget tests and integration tests.
class LoginTestUtils {
  /// Creates a log file for test output
  static IOSink? createLogFile(String testName) {
    try {
      final logDir = Directory('${Directory.current.path}/logs');
      if (!logDir.existsSync()) {
        logDir.createSync();
      }
      
      final logFile = File(
        '${logDir.path}/${testName}_${DateTime.now().millisecondsSinceEpoch}.log',
      );
      return logFile.openWrite();
    } catch (e) {
      print('⚠️ Failed to create log file: $e');
      return null;
    }
  }

  /// Closes the log file
  static Future<void> closeLog(IOSink? logSink, String logPath) async {
    if (logSink != null) {
      await logSink.flush();
      await logSink.close();
      print('📝 Test log saved to: $logPath');
    }
  }

  /// Logs a message to both console and log file
  static void log(String message, {IOSink? logSink}) {
    print(message);
    logSink?.writeln(message);
  }

  /// Get login form elements (username field, password field, login button)
  static Map<String, Finder> getLoginFormElements() {
    return {
      'username': find.byKey(const Key('loginUsernameField')),
      'password': find.byKey(const Key('loginPasswordField')),
      'loginButton': find.byKey(const Key('loginButton')),
    };
  }

  /// Enter credentials and tap login button
  static Future<void> enterCredentialsAndLogin(
    WidgetTester tester, 
    String username, 
    String password, 
    {IOSink? logSink}
  ) async {
    log('📝 Entering login credentials...', logSink: logSink);
    
    final formElements = getLoginFormElements();
    
    // Enter username
    await tester.enterText(formElements['username']!, username);
    log('✓ Entered username: $username', logSink: logSink);
    
    // Enter password (only log first character for security)
    await tester.enterText(formElements['password']!, password);
    final maskedPassword = password.isNotEmpty 
        ? '${password.substring(0, 1)}${'*' * (password.length - 1)}'
        : '';
    log('✓ Entered password: $maskedPassword', logSink: logSink);
    
    // Tap login button
    log('👆 Tapping login button...', logSink: logSink);
    await tester.tap(formElements['loginButton']!);
    await tester.pumpAndSettle();
    log('✓ Login button tapped', logSink: logSink);
  }

  /// Verify login error message is displayed
  static Future<void> verifyLoginError(WidgetTester tester, {IOSink? logSink}) async {
    log('🔍 Looking for error message...', logSink: logSink);
    
    // Wait for error message to appear
    await tester.pumpAndSettle(const Duration(seconds: 3));
    
    // Check for common error messages
    final errorFinder = find.textContaining('Invalid', findRichText: true);
    final errorFinder2 = find.textContaining('incorrect', findRichText: true);
    final errorFinder3 = find.textContaining('failed', findRichText: true);
    
    final hasError = tester.any(errorFinder) || 
                     tester.any(errorFinder2) || 
                     tester.any(errorFinder3);
    
    if (hasError) {
      log('✅ Error message found', logSink: logSink);
    } else {
      log('⚠️ No error message found', logSink: logSink);
      
      // Log visible widgets for debugging
      log('📋 Visible widgets:', logSink: logSink);
      final elements = find.byType(Text);
      for (int i = 0; i < elements.evaluate().length; i++) {
        final widget = elements.at(i).evaluate().first.widget as Text;
        log('  - "${widget.data}"', logSink: logSink);
      }
    }
    
    // Return whether we found an error
    expect(hasError, isTrue, reason: 'Error message should be displayed');
  }

  /// Verify successful login (user is redirected away from login screen)
  static Future<void> verifySuccessfulLogin(WidgetTester tester, {IOSink? logSink}) async {
    log('🔍 Verifying successful login...', logSink: logSink);
    
    // Wait for navigation to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));
    
    // Check that we're no longer on the login page
    final loginPageFinder = find.byType(LoginPage);
    if (tester.any(loginPageFinder)) {
      log('❌ Login failed - still on login page', logSink: logSink);
      
      // Log visible widgets for debugging
      log('📋 Visible widgets:', logSink: logSink);
      final elements = find.byType(Text);
      for (int i = 0; i < elements.evaluate().length; i++) {
        final widget = elements.at(i).evaluate().first.widget as Text;
        log('  - "${widget.data}"', logSink: logSink);
      }
    } else {
      log('✅ Login succeeded - navigated away from login page', logSink: logSink);
    }
    
    expect(find.byType(LoginPage), findsNothing, reason: 'User should be redirected after successful login');
  }
}