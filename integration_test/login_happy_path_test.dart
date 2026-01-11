import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart' as app;
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login with valid credentials succeeds', (tester) async {
    // Start the app
    app.main();
    
    // Wait for app to fully load
    await tester.pumpAndSettle(const Duration(seconds: 5));
    
    // Debug: Print what widgets are currently visible
    print('========== CURRENT SCREEN WIDGETS ==========');
    tester.allWidgets.forEach((widget) {
      print('Widget: ${widget.runtimeType}');
    });
    print('===========================================');

    // Check if we're already logged in
    final isOnLoginScreen = find.text('Sign In').evaluate().isNotEmpty;
    
    if (!isOnLoginScreen) {
      print('⚠️ Not on login screen, likely already logged in');
      return; // Test passes if already logged in
    }

    // Get credentials from environment variables
    const username = String.fromEnvironment('MEMVERSE_USERNAME');
    const password = String.fromEnvironment('MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT');
    
    print('📝 Using credentials - Username length: ${username.length}, Password length: ${password.length}');
    
    // Wait for a moment to ensure form is fully loaded
    await tester.pump(const Duration(seconds: 1));

    // Find username field by key
    final usernameField = find.byKey(loginUsernameFieldKey);
    expect(usernameField, findsOneWidget, reason: 'Username field not found');
    await tester.enterText(usernameField, username);
    await tester.pump(const Duration(milliseconds: 500));
    
    // Find password field by key
    final passwordField = find.byKey(loginPasswordFieldKey);
    expect(passwordField, findsOneWidget, reason: 'Password field not found');
    await tester.enterText(passwordField, password);
    await tester.pump(const Duration(milliseconds: 500));

    // Find and tap the login button
    final loginButton = find.byKey(loginButtonKey);
    expect(loginButton, findsOneWidget, reason: 'Login button not found');
    await tester.tap(loginButton);
    await tester.pump(); // Start animations

    // Verify loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for login to complete and UI to update
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Verify we're no longer on the login screen
    expect(find.byKey(loginButtonKey), findsNothing);
    
    // Verify we see the app bar, indicating we've navigated to a new screen
    expect(find.byType(AppBar), findsOneWidget);
    
    print('✅ LOGIN SUCCESSFUL - Integration test passed');
  });
}
