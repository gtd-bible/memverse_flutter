import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart' as app;
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:mini_memverse/src/constants/app_constants.dart';

/// Integration test to verify login functionality works
/// Uses real API credentials from environment variables
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Verification', () {
    testWidgets('Login with correct credentials succeeds', (WidgetTester tester) async {
      // Get credentials from environment variables
      final username = const String.fromEnvironment('MEMVERSE_USERNAME');
      final password = const String.fromEnvironment('MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT');
      final clientId = const String.fromEnvironment('MEMVERSE_CLIENT_ID');
      final clientApiKey = const String.fromEnvironment('MEMVERSE_CLIENT_API_KEY');
      
      // Print environment variables for debugging
      print('🔍 Checking environment variables:');
      print('   MEMVERSE_USERNAME: ${username.isNotEmpty ? '✅ SET' : '❌ MISSING'}');
      print('   MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT: ${password.isNotEmpty ? '✅ SET' : '❌ MISSING'}');
      print('   MEMVERSE_CLIENT_ID: ${clientId.isNotEmpty ? '✅ SET' : '❌ MISSING'}');
      print('   MEMVERSE_CLIENT_API_KEY: ${clientApiKey.isNotEmpty ? '✅ SET' : '❌ MISSING'}');
      
      // Verify credentials are available
      if (username.isEmpty || password.isEmpty || clientId.isEmpty || clientApiKey.isEmpty) {
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
      
      // Print widget tree for debugging
      print('🔍 Widget tree:');
      print(tester.allWidgets.map((w) => w.runtimeType).toList());
      
      // Check if we see a login page
      if (find.byType(LoginPage).evaluate().isEmpty) {
        print('⚠️ LoginPage not found! Trying to identify current screen...');
        
        // Try to identify where we are
        if (find.byType(AppBar).evaluate().isNotEmpty) {
          print('📱 Found AppBar - possibly already logged in');
        }
        
        if (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
          print('⏳ Found loading indicator - app might be initializing');
        }
        
        // Try to find text fields which might be on the login screen
        if (find.byType(TextField).evaluate().isNotEmpty || find.byType(TextFormField).evaluate().isNotEmpty) {
          print('🔑 Found text input fields - might be on login screen with different structure');
        }
        
        // Try to find a login button by its label
        final loginButtons = find.widgetWithText(ElevatedButton, 'Sign In');
        if (loginButtons.evaluate().isNotEmpty) {
          print('🔘 Found Sign In button');
        }
      } else {
        print('✅ Login page found');
      }
      
      // Verify login screen appears
      expect(find.byType(LoginPage), findsOneWidget, reason: 'Login page should appear on app launch');
      
      // Enter credentials
      final usernameField = find.byKey(loginUsernameFieldKey);
      final passwordField = find.byKey(loginPasswordFieldKey);
      final loginButton = find.byKey(loginButtonKey);
      
      expect(usernameField, findsOneWidget, reason: 'Username field not found');
      expect(passwordField, findsOneWidget, reason: 'Password field not found');
      expect(loginButton, findsOneWidget, reason: 'Login button not found');
      
      print('🔑 Entering credentials...');
      await tester.enterText(usernameField, username);
      await tester.enterText(passwordField, password);
      await tester.pump(const Duration(milliseconds: 500));
      
      print('✅ Credentials entered');
      print('   Username: $username');
      print('   Password: ${password.substring(0, 2)}*****');
      
      // Click login button
      print('🔘 Tapping login button...');
      await tester.tap(loginButton);
      await tester.pump();
      
      // Wait for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget, 
          reason: 'Loading indicator should appear after tapping login');
      print('⏳ Loading indicator appeared');
      
      // Wait for authentication to complete and navigation
      print('⏳ Waiting for authentication to complete...');
      await tester.pumpAndSettle(const Duration(seconds: 10));
      
      // Verify login was successful - should navigate away from login page
      print('🔍 Verifying login success...');
      expect(find.byType(LoginPage), findsNothing, 
          reason: 'Login page should not be visible after successful login');
      
      // Additional verification - should see app bar in main screen
      expect(find.byType(AppBar), findsOneWidget, 
          reason: 'App bar should be visible after successful login');
      
      print('🎉 Login successful! Navigated away from login screen');
      
      // Wait a moment to verify stability
      await tester.pump(const Duration(seconds: 2));
      
      print('✅ TEST PASSED: Login with correct credentials succeeds');
    });
  });
}