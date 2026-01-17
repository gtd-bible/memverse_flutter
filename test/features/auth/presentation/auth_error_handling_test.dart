import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

// Mocks
class MockAuthService extends Mock implements AuthService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}

class MockTalker extends Mock implements Talker {}

class MockAppLoggerFacade extends Mock implements AppLoggerFacade {}

void main() {
  late MockAuthService authService;
  late MockAnalyticsService analyticsService;
  late MockAnalyticsFacade analyticsFacade;
  late MockTalker talker;
  late MockAppLoggerFacade appLogger;
  late AuthNotifier authNotifier;

  // Test credentials
  const testUsername = 'test_user@example.com';
  const testPassword = 'test_password';
  const testClientId = 'test_client_id';
  const testClientSecret = 'test_client_secret';

  void logTestStep(String step) {
    print('🧪 TEST: $step');
  }

  setUp(() {
    authService = MockAuthService();
    analyticsService = MockAnalyticsService();
    analyticsFacade = MockAnalyticsFacade();
    talker = MockTalker();
    appLogger = MockAppLoggerFacade();

    // Initialize the AuthNotifier with our mocks
    authNotifier = AuthNotifier(
      authService,
      testClientId,
      testClientSecret,
      analyticsService,
      analyticsFacade,
      talker,
    );

    // Set up default behavior
    when(
      () => analyticsFacade.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
    when(() => analyticsFacade.trackLogin()).thenAnswer((_) async {});
    when(() => analyticsFacade.trackError(any(), any())).thenAnswer((_) async {});
    when(
      () => analyticsFacade.recordError(
        any(),
        any(),
        reason: any(named: 'reason'),
        fatal: any(named: 'fatal'),
        additionalData: any(named: 'additionalData'),
      ),
    ).thenAnswer((_) async {});
    when(() => analyticsService.trackLogin(any())).thenAnswer((_) async {});
    when(() => analyticsService.trackLoginFailure(any(), any())).thenAnswer((_) async {});
    when(() => talker.handle(any(), any(), any())).thenReturn(null);
    when(() => talker.error(any(), any(), any())).thenReturn(null);
  });

  group('Authentication Error Handling Tests -', () {
    test('Network error during login should be properly reported', () async {
      logTestStep('Setting up network error scenario');

      // Setup auth service to throw a network error
      final networkException = Exception('Network connection failed');
      when(() => authService.login(any(), any(), any(), any())).thenThrow(networkException);

      logTestStep('Calling login with test credentials');

      // Attempt login which will fail due to network error
      await authNotifier.login(testUsername, testPassword);

      logTestStep('Verifying error tracking calls');

      // Verify analytics events are logged
      verify(
        () => analyticsFacade.logEvent('login_attempt', parameters: any(named: 'parameters')),
      ).called(1);

      verify(
        () => analyticsFacade.trackError('auth_error', any(that: contains('Network'))),
      ).called(1);

      // Verify detailed error is recorded with context
      verify(
        () => analyticsFacade.recordError(
          networkException,
          any(),
          reason: 'Login failure',
          fatal: false,
          additionalData: any(that: contains('username_provided')),
        ),
      ).called(1);

      // Verify talker is used for error logging
      verify(() => talker.handle(networkException, any(), 'Login failed')).called(1);

      // Verify traditional analytics is still called
      verify(
        () => analyticsService.trackLoginFailure(testUsername, any(that: contains('Network'))),
      ).called(1);

      logTestStep('Verifying auth state is updated');

      // Verify auth state is updated correctly
      expect(authNotifier.state.isLoading, false, reason: 'isLoading should be false after error');
      expect(
        authNotifier.state.error,
        isNotNull,
        reason: 'error should be set after network failure',
      );
      expect(
        authNotifier.state.isAuthenticated,
        false,
        reason: 'isAuthenticated should remain false',
      );
    });

    test('Invalid credentials should be properly reported', () async {
      logTestStep('Setting up invalid credentials scenario');

      // Setup auth service to return null token (auth failure)
      when(() => authService.login(any(), any(), any(), any())).thenAnswer((_) async => null);

      logTestStep('Calling login with invalid credentials');

      // Attempt login which will fail due to invalid credentials
      await authNotifier.login(testUsername, 'wrong_password');

      logTestStep('Verifying auth state and analytics');

      // Verify auth state is updated correctly
      expect(
        authNotifier.state.isAuthenticated,
        false,
        reason: 'isAuthenticated should be false after invalid credentials',
      );

      // Verify empty token error is logged
      verify(
        () => analyticsFacade.logEvent('login_empty_token', parameters: any(named: 'parameters')),
      ).called(1);

      // Verify talker error is logged
      verify(() => talker.error('Login failed - Empty access token received')).called(1);

      logTestStep('Empty token error properly tracked');
    });

    test('Server error response should be properly reported', () async {
      logTestStep('Setting up server error scenario');

      // Setup auth service to throw a server error
      final serverException = Exception('Server error: 500 Internal Server Error');
      when(() => authService.login(any(), any(), any(), any())).thenThrow(serverException);

      logTestStep('Calling login with test credentials during server error');

      // Attempt login which will fail due to server error
      await authNotifier.login(testUsername, testPassword);

      logTestStep('Verifying server error analytics');

      // Verify analytics service records detailed error info
      verify(
        () => analyticsFacade.recordError(
          serverException,
          any(),
          additionalData: any(that: contains('client_id_provided')),
        ),
      ).called(1);

      // Verify error contains correct details for debugging
      verify(
        () => analyticsFacade.trackError('auth_error', any(that: contains('Server error'))),
      ).called(1);

      logTestStep('Server error properly tracked with details');
    });

    test('Logout error should be properly reported', () async {
      logTestStep('Setting up logout error scenario');

      // Setup auth service to throw during logout
      final logoutException = Exception('Session expired');
      when(() => authService.logout()).thenThrow(logoutException);

      logTestStep('Calling logout during error scenario');

      // Attempt logout which will fail
      await authNotifier.logout();

      logTestStep('Verifying logout error analytics');

      // Verify error tracking
      verify(
        () => analyticsFacade.recordError(
          logoutException,
          any(),
          reason: 'Logout failure',
          fatal: false,
        ),
      ).called(1);

      // Verify talker is used
      verify(() => talker.handle(logoutException, any(), 'Logout failed')).called(1);

      // Verify analytics error event
      verify(
        () => analyticsFacade.trackError('auth_error', any(that: contains('Session expired'))),
      ).called(1);

      logTestStep('Logout error properly tracked');
    });
  });
}
