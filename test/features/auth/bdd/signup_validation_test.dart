import 'package:bdd_widget_test/bdd_widget_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/main.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:mini_memverse/src/features/auth/presentation/signup_page.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}

/*
Feature: User Registration
  As a new user
  I want to create an account
  So that I can use the app
*/

void main() {
  final featureFile = File('registration.feature');

  setUp(() {
    // Set up mocks
    final mockAnalytics = MockAnalyticsFacade();

    // Setup mock behavior
    when(() => mockAnalytics.trackSignUp()).thenAnswer((_) async {});
    when(
      () => mockAnalytics.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
  });

  Future<void> setupApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();
  }

  group(featureFile, () {
    testWidgets('User navigates to signup page from login screen', (tester) async {
      await setupApp(tester);

      await tester.runFeature(
        'registration.feature',
        steps: [
          given('I am on the login screen', (context) async {
            expect(find.byType(LoginPage), findsOneWidget);
          }),

          when('I tap the create account link', (context) async {
            // Try to find signup link - check various possible texts
            final signupText = find.textContaining('Sign up', findRichText: true);
            final createAccountText = find.textContaining('Create account', findRichText: true);
            final registerText = find.textContaining('Register', findRichText: true);

            Finder signupLink;
            if (signupText.evaluate().isNotEmpty) {
              signupLink = signupText;
            } else if (createAccountText.evaluate().isNotEmpty) {
              signupLink = createAccountText;
            } else if (registerText.evaluate().isNotEmpty) {
              signupLink = registerText;
            } else {
              fail('Could not find any signup link or button');
            }

            await tester.tap(signupLink);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }),

          then('I should see the registration form', (context) async {
            // Verify navigation to signup page
            final onSignupPage = find.byType(SignupPage).evaluate().isNotEmpty;
            if (!onSignupPage) {
              // Check for signup form elements as fallback
              final hasEmailField = find
                  .textContaining('email', findRichText: true)
                  .evaluate()
                  .isNotEmpty;
              final hasPasswordFields =
                  find.textContaining('password', findRichText: true).evaluate().length >= 2;
              final hasSignupButton =
                  find.textContaining('Sign up', findRichText: true).evaluate().isNotEmpty ||
                  find.textContaining('Register', findRichText: true).evaluate().isNotEmpty;

              expect(hasEmailField && hasPasswordFields && hasSignupButton, isTrue);
            } else {
              expect(find.byType(SignupPage), findsOneWidget);
            }
          }),
        ],
      );
    });

    testWidgets('User submits signup form with empty fields', (tester) async {
      await setupApp(tester);

      await tester.runFeature(
        'registration.feature',
        steps: [
          given('I am on the signup screen', (context) async {
            // Navigate to signup first
            final signupText = find.textContaining('Sign up', findRichText: true).first;
            await tester.tap(signupText);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Verify on signup page
            final hasSignupForm =
                find.textContaining('email', findRichText: true).evaluate().isNotEmpty &&
                find.textContaining('password', findRichText: true).evaluate().isNotEmpty;
            expect(hasSignupForm, isTrue);
          }),

          when('I submit the form without filling any fields', (context) async {
            // Try to find signup button
            final signupButton = find.textContaining('Sign up', findRichText: true).first;
            final registerButton = find.textContaining('Register', findRichText: true).first;
            final createAccountButton = find
                .textContaining('Create account', findRichText: true)
                .first;

            Finder submitButton;
            if (signupButton.evaluate().isNotEmpty) {
              submitButton = signupButton;
            } else if (registerButton.evaluate().isNotEmpty) {
              submitButton = registerButton;
            } else if (createAccountButton.evaluate().isNotEmpty) {
              submitButton = createAccountButton;
            } else {
              fail('Could not find signup submit button');
            }

            // Tap the signup button without filling form
            await tester.tap(submitButton);
            await tester.pumpAndSettle();
          }),

          then('I should see validation error messages', (context) async {
            // Check for validation error messages
            final validationErrors =
                find.textContaining('required', findRichText: true).evaluate().isNotEmpty ||
                find.textContaining('valid', findRichText: true).evaluate().isNotEmpty ||
                find.textContaining('empty', findRichText: true).evaluate().isNotEmpty;

            expect(validationErrors, isTrue);
          }),

          and('I should remain on the signup screen', (context) async {
            // Verify still on signup page
            final hasSignupForm =
                find.textContaining('email', findRichText: true).evaluate().isNotEmpty &&
                find.textContaining('password', findRichText: true).evaluate().isNotEmpty;
            expect(hasSignupForm, isTrue);
          }),
        ],
      );
    });
  });
}
