import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:mini_memverse/src/features/auth/presentation/signup_page.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mockingjay/mockingjay.dart';

// A mock analytics service to override the real one in tests
class MockAnalyticsService {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
    registerFallbackValue(MaterialPageRoute<dynamic>(builder: (_) => Container()));
  });

  group('LoginPage', () {
    testWidgets('navigates to SignupPage when Sign Up button is tapped', (tester) async {
      // 1. Create a mock navigator
      final mockNavigator = MockNavigator();
      when(() => mockNavigator.canPop()).thenReturn(true);
      // Ensure push returns a completed Future<dynamic>
      when(() => mockNavigator.push(any<Route<dynamic>>())).thenAnswer((_) => Future<dynamic>.value());

      // 2. Pump the widget with the mock navigator
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clientIdProvider.overrideWithValue('test_client_id'),
          ],
          child: MaterialApp(
            home: MockNavigatorProvider(navigator: mockNavigator, child: const LoginPage()),
          ),
        ),
      );

      // 3. Find and tap the "Sign Up" button
      final signUpFinder = find.text('Sign Up');
      await tester.ensureVisible(signUpFinder);
      await tester.tap(signUpFinder);
      await tester.pump();

      // 4. Verify that the navigator was asked to push a new route
      verify(
        () => mockNavigator.push(any<Route<dynamic>>()),
      ).called(1);
    });
  });
}
