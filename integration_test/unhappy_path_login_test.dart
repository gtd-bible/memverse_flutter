import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart' as app;
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';

// Import shared test utilities
import '../test/features/auth/test_utils/login_test_utils.dart';

// Import needed for IntegrationTestWidgetsFlutterBinding
export 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Set up logging for test output
  String testName = 'unhappy_path_login_integration';
  final logSink = LoginTestUtils.createLogFile(testName);
  final logFile = logSink != null
      ? File(
          '${Directory.current.path}/logs/${testName}_${DateTime.now().millisecondsSinceEpoch}.log',
        )
      : null;

  void log(String message) {
    LoginTestUtils.log(message, logSink: logSink);
  }

  setUpAll(() async {
    log('🚀 Starting Unhappy Path Login Integration Test');
    log('📱 Running on: ${binding.defaultBinaryMessenger}');
    log('⚙️ Test Configuration: Intentionally using wrong credentials');
  });

  tearDownAll(() async {
    log('🏁 Completed Unhappy Path Login Integration Test');

    // Close log file
    await LoginTestUtils.closeLog(logSink, logFile?.path ?? 'No log file created');
  });

  testWidgets('Login with wrong credentials should show error message', (
    WidgetTester tester,
  ) async {
    log('📱 Starting login with wrong credentials test');

    // Launch the app
    log('🚀 Launching app...');
    await app.main();
    log('✅ App launched successfully');

    // Wait for app to stabilize and show login screen
    log('⏳ Waiting for login screen to appear...');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify we're on the login screen
    expect(find.byType(LoginPage), findsOneWidget, reason: 'Login page should be displayed');
    log('✅ Login page found');

    // Get login form elements
    final formElements = LoginTestUtils.getLoginFormElements();
    expect(formElements['username'], findsOneWidget, reason: 'Username field should be visible');
    expect(formElements['password'], findsOneWidget, reason: 'Password field should be visible');
    expect(formElements['loginButton'], findsOneWidget, reason: 'Login button should be visible');
    log('✅ Found all login form elements');

    // Enter wrong credentials and tap login
    await LoginTestUtils.enterCredentialsAndLogin(
      tester,
      'wrongusername',
      'wrongpassword',
      logSink: logSink,
    );

    // Take screenshot if supported
    try {
      // Screenshots aren't critical - just log whether they were taken
      binding.takeScreenshot('wrong_credentials_entered');
      log('📸 Attempted to take screenshot: wrong_credentials_entered');
    } catch (e) {
      log('⚠️ Unable to take screenshot: $e');
    }

    // Verify login error
    await LoginTestUtils.verifyLoginError(tester, logSink: logSink);

    // Take screenshot of error state if supported
    try {
      // Screenshots aren't critical - just log whether they were taken
      binding.takeScreenshot('login_error_displayed');
      log('📸 Attempted to take screenshot: login_error_displayed');
    } catch (e) {
      log('⚠️ Unable to take screenshot: $e');
    }

    // Verify form is still there and we can try again
    expect(formElements['username'], findsOneWidget);
    expect(formElements['password'], findsOneWidget);
    expect(formElements['loginButton'], findsOneWidget);
    log('✅ Login form elements still present for retry');

    // Clear the text fields and verify we can try again
    await tester.tap(formElements['username']!);
    await tester.pump();
    await tester.enterText(formElements['username']!, '');

    await tester.tap(formElements['password']!);
    await tester.pump();
    await tester.enterText(formElements['password']!, '');

    log('✅ Fields cleared successfully - user can try again');
    log('🎉 Unhappy path login test completed successfully!');
  });
}
