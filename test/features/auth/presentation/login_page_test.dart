import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mockingjay/mockingjay.dart';

// A mock analytics service to override the real one in tests
class MockAuthService extends Mock implements AuthService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

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
      when(
        () => mockNavigator.push(any<Route<dynamic>>()),
      ).thenAnswer((_) => Future<dynamic>.value());

      // Create mock services
      final mockAuthService = MockAuthService();
      final mockAnalyticsService = MockAnalyticsService();

      // Configure mocks
      when(() => mockAuthService.isLoggedIn()).thenAnswer((_) async => false);
      when(
        () => mockAnalyticsService.trackPasswordVisibilityToggle(any()),
      ).thenAnswer((_) async {});

      // 2. Pump the widget with the mock navigator
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clientIdProvider.overrideWithValue('test_client_id'),
            clientSecretProvider.overrideWithValue('test_client_secret'),
            authServiceProvider.overrideWithValue(mockAuthService),
            analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
            // Use state provider override for auth state
            authStateProvider.overrideWithValue(const AuthState()),
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
      verify(() => mockNavigator.push(any<Route<dynamic>>())).called(1);
    });
  });
}
