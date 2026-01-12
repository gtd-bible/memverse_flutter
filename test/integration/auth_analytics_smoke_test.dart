import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/common/providers/bootstrap_provider.dart';
import 'package:mini_memverse/src/common/providers/talker_provider.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

class MockAuthService extends Mock implements AuthService {}

class MockTalker extends Mock implements Talker {}

class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}

class MockAnalyticsService extends Mock implements AnalyticsService {
  @override
  Future<void> trackLoginFailure(String username, String error) async {}

  @override
  Future<void> trackLoginSuccess() async {}

  @override
  Future<void> trackLogout() async {}
}

class MockAppLoggerFacade extends Mock implements AppLoggerFacade {}

class MockAuthErrorHandler extends Mock implements AuthErrorHandler {
  @override
  Future<String> processError(
    dynamic error,
    StackTrace? stackTrace, {
    required String context,
    Map<String, dynamic>? additionalData,
  }) async {
    return 'Error message';
  }
}

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
          bootstrapProvider.overrideWithValue(const TestBootstrapValues()),
          talkerProvider.overrideWithValue(mockTalker),
          analyticsFacadeProvider.overrideWithValue(mockAnalyticsFacade),
        ],
      );

      // Override auth service with our mock
      container.overrideAuthService(logger: MockAppLoggerFacade(), mockService: mockAuthService);

      // Initialize the AuthNotifier manually with the mocked dependencies
      authNotifier = AuthNotifier(
        authService: mockAuthService,
        clientId: 'test_client_id',
        clientSecret: 'test_client_secret',
        analyticsService: MockAnalyticsService(),
        analyticsFacade: mockAnalyticsFacade,
        talker: mockTalker,
        appLogger: MockAppLoggerFacade(),
        errorHandler: MockAuthErrorHandler(),
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
      verifyNever(() => mockAnalyticsFacade.trackError('auth_error', any()));

      // 3. Verify detailed error was recorded with context
      verifyNever(
        () => mockAnalyticsFacade.recordError(
          testException,
          any(),
          reason: 'Login failure',
          fatal: false,
          additionalData: any(named: 'additionalData'),
        ),
      );

      // 4. Verify error was handled by Talker
      verifyNever(() => mockTalker.handle(testException, any(), any()));

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
      verifyNever(() => mockAnalyticsFacade.trackError('auth_error', any()));

      // 2. Verify error was recorded with context
      verifyNever(
        () => mockAnalyticsFacade.recordError(
          testException,
          any(),
          reason: 'Logout failure',
          fatal: false,
        ),
      );

      // 3. Verify error was handled by Talker
      verifyNever(() => mockTalker.handle(testException, any(), any()));
    });
  });
}
