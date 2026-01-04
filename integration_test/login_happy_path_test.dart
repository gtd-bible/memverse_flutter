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
    await tester.pumpAndSettle();

    // Get credentials from environment variables
    const username = String.fromEnvironment('MEMVERSE_USERNAME');
    const password = String.fromEnvironment('MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT');

    // Find and fill the username field
    await tester.enterText(find.byKey(loginUsernameFieldKey), username);

    // Find and fill the password field
    await tester.enterText(find.byKey(loginPasswordFieldKey), password);

    // Tap the login button
    await tester.tap(find.byKey(loginButtonKey));
    await tester.pump(); // Start animations

    // Verify loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for login to complete and UI to update
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Verify we're no longer on the login screen
    expect(find.byKey(loginButtonKey), findsNothing);

    // Verify we see the app bar, indicating we've navigated to a new screen
    expect(find.byType(AppBar), findsOneWidget);
  });
}
