import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mini_memverse/src/common/providers/bootstrap_provider.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/monitoring/analytics_client.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

class MockAuthService extends Mock implements AuthService {}

class MockTalker extends Mock implements Talker {}

class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}

// Test bootstrap values for authentication
class TestBootstrapValues extends BootstrapValues {
  const TestBootstrapValues()
    : super(clientId: 'test_client_id', clientSecret: 'test_client_secret');
}

void main() {
  group('Auth Analytics Integration Tests', () {
    late MockAuthService mockAuthService;
    late MockTalker mockTalker;
    late MockAnalyticsFacade mockAnalyticsFacade;
    late ProviderContainer container;
    late AuthNotifier authNotifier;

    setUp(() {
      mockAuthService = MockAuthService();
      mockTalker = MockTalker();
      mockAnalyticsFacade = MockAnalyticsFacade();

      // Configure mock methods
      when(() => mockAuthService.isLoggedIn()).thenAnswer((_) async => false);

      // Set up tracking methods to succeed
      when(() => mockAnalyticsFacade.initialize()).thenAnswer((_) async {});
      when(
        () => mockAnalyticsFacade.logEvent(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async {});
      when(() => mockAnalyticsFacade.trackError(any(), any())).thenAnswer((_) async {});
      when(
        () => mockAnalyticsFacade.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: any(named: 'fatal'),
          additionalData: any(named: 'additionalData'),
        ),
      ).thenAnswer((_) async {});

      // Setup Riverpod overrides
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          bootstrapProvider.overrideWithValue(const TestBootstrapValues()),
          talkerProvider.overrideWithValue(mockTalker),
          analyticsFacadeProvider.overrideWithValue(mockAnalyticsFacade),
        ],
      );

      // Initialize the AuthNotifier manually with the mocked dependencies
      authNotifier = AuthNotifier(
        mockAuthService,
        'test_client_id',
        'test_client_secret',
        // We don't need to mock analyticsService for this test
        container.read(analyticsServiceProvider),
        mockAnalyticsFacade,
        mockTalker,
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Login Failure - Should track error events correctly', () async {
      // Arrange
      const testUsername = 'test@example.com';
      const testPassword = 'wrong_password';
      final testException = Exception('Invalid credentials');
      final testStackTrace = StackTrace.current;

      // Mock auth service to throw an exception
      when(() => mockAuthService.login(any(), any(), any(), any())).thenThrow(testException);

      // Act
      await authNotifier.login(testUsername, testPassword);

      // Assert
      // 1. Verify login attempt was logged
      verify(
        () => mockAnalyticsFacade.logEvent('login_attempt', parameters: any(named: 'parameters')),
      ).called(1);

      // 2. Verify error was logged to analytics
      verify(
        () => mockAnalyticsFacade.trackError('auth_error', contains('Invalid credentials')),
      ).called(1);

      // 3. Verify detailed error was recorded with context
      verify(
        () => mockAnalyticsFacade.recordError(
          testException,
          any(),
          reason: 'Login failure',
          fatal: false,
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);

      // 4. Verify error was handled by Talker
      verify(() => mockTalker.handle(testException, any(), any())).called(1);

      // 5. Verify auth state was updated correctly
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.error, isNotNull);
    });

    test('Logout Failure - Should track error events correctly', () async {
      // Arrange
      final testException = Exception('Logout failed');

      // Set initial state as logged in
      when(() => mockAuthService.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockAuthService.getToken()).thenAnswer((_) async => null);

      // Mock logout to throw an error
      when(() => mockAuthService.logout()).thenThrow(testException);

      // Act
      await authNotifier.logout();

      // Assert
      // 1. Verify error was tracked
      verify(
        () => mockAnalyticsFacade.trackError('auth_error', contains('Logout failed')),
      ).called(1);

      // 2. Verify error was recorded with context
      verify(
        () => mockAnalyticsFacade.recordError(
          testException,
          any(),
          reason: 'Logout failure',
          fatal: false,
        ),
      ).called(1);

      // 3. Verify error was handled by Talker
      verify(() => mockTalker.handle(testException, any(), any())).called(1);
    });
  });
}
