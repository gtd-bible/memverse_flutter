import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/auth/application/auth_providers.dart';
import 'package:memverse_flutter/src/features/auth/data/fake_auth_service.dart';
import 'package:memverse_flutter/src/features/auth/presentation/views/login_screen.dart';

void main() {
  group('LoginScreen', () {
    late FakeAuthService mockAuthService;

    setUp(() {
      mockAuthService = FakeAuthService();
    });

    Widget buildTestWidget({VoidCallback? onGuestLogin}) {
      return ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
        child: MaterialApp(
          home: LoginScreen(onGuestLogin: onGuestLogin),
        ),
      );
    }

    testWidgets('displays login title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Login'), findsNWidgets(2)); // Title and button
    });

    testWidgets('displays username field', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
    });

    testWidgets('displays password field', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    });

    testWidgets('password field obscures text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final passwordField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Password'),
      );

      expect(passwordField.obscureText, true);
    });

    testWidgets('displays login button', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('displays guest login button when provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(onGuestLogin: () {}));

      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('does not display guest button when not provided', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Continue as Guest'), findsNothing);
    });

    testWidgets('successful login with valid credentials', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Enter valid credentials
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );

      // Tap login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Should be authenticated
      expect(await mockAuthService.isAuthenticated(), true);

      // Error message should not be visible
      expect(find.text('Invalid username or password.'), findsNothing);
    });

    testWidgets('failed login with invalid username', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'wronguser',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Invalid username or password.'), findsOneWidget);

      // Should remain unauthenticated
      expect(await mockAuthService.isAuthenticated(), false);
    });

    testWidgets('failed login with invalid password', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'wrongpassword',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid username or password.'), findsOneWidget);
      expect(await mockAuthService.isAuthenticated(), false);
    });

    testWidgets('failed login with empty credentials', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Don't enter anything, just tap login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid username or password.'), findsOneWidget);
      expect(await mockAuthService.isAuthenticated(), false);
    });

    testWidgets('shows loading indicator during login', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump(); // Don't settle, check during loading

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Should not show login button
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsNothing);
    });

    testWidgets('disables input fields during loading', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      final usernameField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Username'),
      );
      final passwordField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Password'),
      );

      expect(usernameField.enabled, false);
      expect(passwordField.enabled, false);
    });

    testWidgets('re-enables fields after login completes', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      final usernameField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Username'),
      );

      expect(usernameField.enabled, true);
    });

    testWidgets('guest login button calls callback', (tester) async {
      bool guestLoginCalled = false;

      await tester.pumpWidget(buildTestWidget(
        onGuestLogin: () {
          guestLoginCalled = true;
        },
      ));

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      expect(guestLoginCalled, true);
    });

    testWidgets('guest button not shown during loading', (tester) async {
      await tester.pumpWidget(buildTestWidget(onGuestLogin: () {}));

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Continue as Guest'), findsNothing);
    });

    testWidgets('error message clears on retry', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // First attempt - fail
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'wrong',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'wrong',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid username or password.'), findsOneWidget);

      // Second attempt - should clear error during loading
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Error should be cleared during loading
      expect(find.text('Invalid username or password.'), findsNothing);
    });

    testWidgets('case sensitive username validation', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'Test', // Wrong case
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid username or password.'), findsOneWidget);
    });

    testWidgets('case sensitive password validation', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'Password', // Wrong case
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid username or password.'), findsOneWidget);
    });

    testWidgets('handles whitespace in credentials', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        ' test ',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        ' password ',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid username or password.'), findsOneWidget);
    });

    testWidgets('multiple failed attempts then success', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Attempt 1 - fail
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'wrong1',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'wrong1',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid username or password.'), findsOneWidget);

      // Attempt 2 - fail
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'wrong2',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'wrong2',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid username or password.'), findsOneWidget);

      // Attempt 3 - success
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid username or password.'), findsNothing);
      expect(await mockAuthService.isAuthenticated(), true);
    });

    testWidgets('layout is centered on screen', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('fields are properly spaced', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('error message is displayed in red', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'wrong',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'wrong',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      final errorText = tester.widget<Text>(
        find.text('Invalid username or password.'),
      );

      expect(errorText.style?.color, Colors.red);
    });
  });
}
