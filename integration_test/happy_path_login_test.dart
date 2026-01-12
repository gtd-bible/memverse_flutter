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
  String testName = 'happy_path_login_integration';
  final logSink = LoginTestUtils.createLogFile(testName);
  final logFile = logSink != null
      ? File(
          '${Directory.current.path}/logs/${testName}_${DateTime.now().millisecondsSinceEpoch}.log',
        )
      : null;

  void log(String message) {
    LoginTestUtils.log(message, logSink: logSink);
  }

  // Get environment variables for test credentials
  final username = Platform.environment['MEMVERSE_USERNAME'];
  final password = Platform.environment['MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT'];
  final clientId = Platform.environment['MEMVERSE_CLIENT_ID'];
  final clientSecret = Platform.environment['MEMVERSE_CLIENT_API_KEY'];

  setUpAll(() async {
    log('🚀 Starting Happy Path Login Integration Test');
    log('📱 Running on: ${binding.defaultBinaryMessenger}');
    log('⚙️ Test Configuration: Using environment variables for credentials');

    // Validate credentials are available
    bool credentialsAvailable = true;
    if (username == null || username.isEmpty) {
      log('⚠️ MEMVERSE_USERNAME environment variable not set');
      credentialsAvailable = false;
    }

    if (password == null || password.isEmpty) {
      log('⚠️ MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT environment variable not set');
      credentialsAvailable = false;
    }

    if (clientId == null || clientId.isEmpty) {
      log('⚠️ MEMVERSE_CLIENT_ID environment variable not set');
      credentialsAvailable = false;
    }

    if (clientSecret == null || clientSecret.isEmpty) {
      log('⚠️ MEMVERSE_CLIENT_API_KEY environment variable not set');
      credentialsAvailable = false;
    }

    if (!credentialsAvailable) {
      log('❌ Test cannot proceed without proper credentials');
      log('📝 Please set the following environment variables:');
      log('   export MEMVERSE_USERNAME="your_username"');
      log('   export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT="your_password"');
      log('   export MEMVERSE_CLIENT_ID="your_client_id"');
      log('   export MEMVERSE_CLIENT_API_KEY="your_client_secret"');
    }
  });

  tearDownAll(() async {
    log('🏁 Completed Happy Path Login Integration Test');
    await LoginTestUtils.closeLog(logSink, logFile?.path ?? 'No log file created');
  });

  testWidgets('Login with correct credentials should succeed', (WidgetTester tester) async {
    // Skip test if credentials are not available
    if (username == null || password == null || username.isEmpty || password.isEmpty) {
      log('⏭️ Skipping test due to missing credentials');
      return;
    }

    log('📱 Starting login with correct credentials test');

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

    // Enter correct credentials and tap login
    log('📝 Using credentials from environment variables...');
    await LoginTestUtils.enterCredentialsAndLogin(tester, username, password, logSink: logSink);

    // Take screenshot if supported
    try {
      // Screenshots aren't critical - just log whether they were taken
      binding.takeScreenshot('correct_credentials_entered');
      log('📸 Attempted to take screenshot: correct_credentials_entered');
    } catch (e) {
      log('⚠️ Unable to take screenshot: $e');
    }

    // Verify successful login
    log('⏳ Waiting for login to complete and redirect...');
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await LoginTestUtils.verifySuccessfulLogin(tester, logSink: logSink);

    // Take screenshot of logged-in state if supported
    try {
      // Screenshots aren't critical - just log whether they were taken
      binding.takeScreenshot('login_successful_redirect');
      log('📸 Attempted to take screenshot: login_successful_redirect');
    } catch (e) {
      log('⚠️ Unable to take screenshot: $e');
    }

    log('🎉 Happy path login test completed successfully!');
  });
}
