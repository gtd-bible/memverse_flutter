import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_token.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}

class MockTalker extends Mock implements Talker {}

class MockAppLoggerFacade extends Mock implements AppLoggerFacade {}

class MockAuthErrorHandler extends Mock implements AuthErrorHandler {}

void main() {
  late MockAuthService authService;
  late MockAnalyticsService analyticsService;
  late MockAnalyticsFacade analyticsFacade;
  late MockTalker talker;
  late MockAppLoggerFacade appLogger;
  late MockAuthErrorHandler errorHandler;
  late AuthNotifier authNotifier;

  const testUsername = 'test@example.com';
  const testPassword = 'password123';
  const testClientId = 'test_client_id';
  const testClientSecret = 'test_client_secret';

  // Sample test token
  const testToken = AuthToken(
    accessToken: 'test_access_token',
    tokenType: 'Bearer',
    scope: 'user',
    createdAt: 1640995200,
    userId: 12345,
  );

  setUp(() {
    authService = MockAuthService();
    analyticsService = MockAnalyticsService();
    analyticsFacade = MockAnalyticsFacade();
    talker = MockTalker();
    appLogger = MockAppLoggerFacade();
    errorHandler = MockAuthErrorHandler();

    // Set up default behaviors
    when(() => authService.isLoggedIn()).thenAnswer((_) async => false);
    when(() => analyticsService.trackLogin(any())).thenAnswer((_) async {});
    when(() => analyticsService.trackLoginFailure(any(), any())).thenAnswer((_) async {});
    when(() => analyticsService.trackLogout()).thenAnswer((_) async {});
    when(() => analyticsFacade.trackLogin()).thenAnswer((_) async {});
    when(() => analyticsFacade.trackLogout()).thenAnswer((_) async {});
    when(() => analyticsFacade.setUserId(any())).thenAnswer((_) async {});
    when(
      () => analyticsFacade.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
    when(() => analyticsFacade.logScreenView(any(), any())).thenAnswer((_) async {});
    when(() => appLogger.i(any())).thenReturn(null);
    when(() => appLogger.warning(any(), any(), any())).thenReturn(null);
    when(() => appLogger.error(any(), any(), any())).thenReturn(null);
    when(() => talker.handle(any(), any(), any())).thenReturn(null);
    when(
      () => errorHandler.processError(
        any(),
        any(),
        context: any(named: 'context'),
        additionalData: any(named: 'additionalData'),
      ),
    ).thenAnswer((_) async => 'Test error message');

    authNotifier = AuthNotifier(
      authService: authService,
      clientId: testClientId,
      clientSecret: testClientSecret,
      analyticsService: analyticsService,
      analyticsFacade: analyticsFacade,
      talker: talker,
      appLogger: appLogger,
      errorHandler: errorHandler,
    );
  });

  group('AuthNotifier - Initialization', () {
    test('initializes with not authenticated state', () {
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.token, null);
      expect(authNotifier.state.error, null);
    });

    test('checks for existing authentication on init', () async {
      // Verify isLoggedIn was called during initialization
      verify(() => authService.isLoggedIn()).called(1);
    });

    test('initializes with authenticated state if already logged in', () async {
      // Arrange
      when(() => authService.isLoggedIn()).thenAnswer((_) async => true);
      when(() => authService.getToken()).thenAnswer((_) async => testToken);

      // Act
      final authNotifier = AuthNotifier(
        authService: authService,
        clientId: testClientId,
        clientSecret: testClientSecret,
        analyticsService: analyticsService,
        analyticsFacade: analyticsFacade,
        talker: talker,
        appLogger: appLogger,
        errorHandler: errorHandler,
      );

      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authNotifier.state.isAuthenticated, true);
      expect(authNotifier.state.token, testToken);
      verify(() => authService.getToken()).called(1);
    });
  });

  group('AuthNotifier - Login', () {
    test('successful login updates state and tracks analytics', () async {
      // Arrange
      when(
        () => authService.login(testUsername, testPassword, testClientId, testClientSecret),
      ).thenAnswer((_) async => testToken);

      // Act
      await authNotifier.login(testUsername, testPassword);

      // Assert
      expect(authNotifier.state.isAuthenticated, true);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.token, testToken);
      expect(authNotifier.state.error, null);

      // Verify analytics calls
      verify(
        () => analyticsFacade.logEvent('login_attempt', parameters: any(named: 'parameters')),
      ).called(1);
      verify(() => analyticsService.trackLogin(testUsername)).called(1);
      verify(() => analyticsFacade.trackLogin()).called(1);
      verify(() => analyticsFacade.setUserId(testToken.userId.toString())).called(1);
      verify(
        () => analyticsFacade.logEvent('login_success', parameters: any(named: 'parameters')),
      ).called(1);
      verify(() => analyticsFacade.logScreenView('dashboard', 'DashboardScreen')).called(1);

      // Verify logging
      verify(() => appLogger.i(any())).called(3); // Multiple info logs
    });

    test('login with null token updates state with error', () async {
      // Arrange
      when(
        () => authService.login(testUsername, testPassword, testClientId, testClientSecret),
      ).thenAnswer((_) async => const AuthToken(accessToken: ''));

      // Act
      await authNotifier.login(testUsername, testPassword);

      // Assert
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.error, 'Login failed. Please try again later.');

      // Verify analytics calls for empty token
      verify(
        () => analyticsFacade.logEvent('login_empty_token', parameters: any(named: 'parameters')),
      ).called(1);
      verify(
        () => errorHandler.processError(
          any(),
          any(),
          context: 'Login',
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);

      // Verify warning logged
      verify(() => appLogger.warning(any(), any(), any())).called(1);
    });

    test('login with empty access token updates state with error', () async {
      // Arrange - token with empty access token
      const emptyToken = AuthToken(
        accessToken: '',
        tokenType: 'Bearer',
        scope: 'user',
        createdAt: 1640995200,
      );

      when(
        () => authService.login(testUsername, testPassword, testClientId, testClientSecret),
      ).thenAnswer((_) async => emptyToken);

      // Act
      await authNotifier.login(testUsername, testPassword);

      // Assert
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.error, 'Login failed. Please try again later.');

      // Verify analytics calls
      verify(
        () => analyticsFacade.logEvent('login_empty_token', parameters: any(named: 'parameters')),
      ).called(1);
    });

    test('login error calls error handler and updates state', () async {
      // Arrange
      final testException = Exception('Test login error');
      when(
        () => authService.login(testUsername, testPassword, testClientId, testClientSecret),
      ).thenThrow(testException);

      when(
        () => errorHandler.processError(
          testException,
          any(),
          context: 'Login',
          additionalData: any(named: 'additionalData'),
        ),
      ).thenAnswer((_) async => 'Custom error message');

      // Act
      await authNotifier.login(testUsername, testPassword);

      // Assert
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.error, 'Custom error message');

      // Verify analytics and error handling
      verify(() => analyticsService.trackLoginFailure(testUsername, any())).called(1);
      verify(
        () => errorHandler.processError(
          testException,
          any(),
          context: 'Login',
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);

      // Verify error logging
      verify(() => appLogger.error(any(), any(), any())).called(1);
    });

    test('state is set to loading during login process', () async {
      // Arrange - delay the login response to check loading state
      when(
        () => authService.login(testUsername, testPassword, testClientId, testClientSecret),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return testToken;
      });

      // Act - start login but don't await
      final loginFuture = authNotifier.login(testUsername, testPassword);

      // Assert - check loading state
      expect(authNotifier.state.isLoading, true);

      // Wait for login to complete
      await loginFuture;

      // Verify loading state is reset
      expect(authNotifier.state.isLoading, false);
    });
  });

  group('AuthNotifier - Logout', () {
    setUp(() {
      // Start with authenticated state for logout tests
      authNotifier = AuthNotifier(
        authService: authService,
        clientId: testClientId,
        clientSecret: testClientSecret,
        analyticsService: analyticsService,
        analyticsFacade: analyticsFacade,
        talker: talker,
        appLogger: appLogger,
        errorHandler: errorHandler,
      );

      // Manually set to authenticated state
      authNotifier = AuthNotifier(
        authService: authService,
        clientId: testClientId,
        clientSecret: testClientSecret,
        analyticsService: analyticsService,
        analyticsFacade: analyticsFacade,
        talker: talker,
        appLogger: appLogger,
        errorHandler: errorHandler,
      );
    });

    test('successful logout resets state and tracks analytics', () async {
      // Arrange
      when(() => authService.logout()).thenAnswer((_) async {});

      // Manually set authenticated state with token
      final initialState = AuthState(isAuthenticated: true, token: testToken);

      authNotifier = AuthNotifier(
        authService: authService,
        clientId: testClientId,
        clientSecret: testClientSecret,
        analyticsService: analyticsService,
        analyticsFacade: analyticsFacade,
        talker: talker,
        appLogger: appLogger,
        errorHandler: errorHandler,
      );

      // Use reflection or testing constructor to set state
      // This is a workaround since we can't directly set state
      // In a real scenario, we might add a testing constructor

      // Act
      await authNotifier.logout();

      // Assert
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.token, null);
      expect(authNotifier.state.error, null);

      // Verify analytics calls
      verify(() => analyticsService.trackLogout()).called(1);
      verify(() => analyticsFacade.trackLogout()).called(1);
      verify(
        () => analyticsFacade.logEvent('user_logout', parameters: any(named: 'parameters')),
      ).called(1);
      verify(() => analyticsFacade.setUserId(null)).called(1);
      verify(() => analyticsFacade.logScreenView('login', 'LoginScreen')).called(1);

      // Verify logging
      verify(() => appLogger.i(any())).called(2);
    });

    test('logout error calls error handler and maintains state', () async {
      // Arrange
      final testException = Exception('Test logout error');
      when(() => authService.logout()).thenThrow(testException);

      when(
        () => errorHandler.processError(
          testException,
          any(),
          context: 'Logout',
          additionalData: any(named: 'additionalData'),
        ),
      ).thenAnswer((_) async => 'Logout error message');

      // Act
      await authNotifier.logout();

      // Assert
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.error, 'Logout error message');

      // Verify error handling
      verify(
        () => errorHandler.processError(
          testException,
          any(),
          context: 'Logout',
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);

      // Verify error logging
      verify(() => appLogger.error(any(), any(), any())).called(1);
    });
  });

  group('AuthNotifier - State management', () {
    test('copyWith preserves unspecified values', () {
      // Arrange
      const initialState = AuthState(
        isAuthenticated: true,
        isLoading: false,
        token: testToken,
        error: 'Initial error',
      );

      // Act
      final newState = initialState.copyWith(isLoading: true);

      // Assert
      expect(newState.isAuthenticated, true);
      expect(newState.isLoading, true);
      expect(newState.token, testToken);
      expect(newState.error, 'Initial error');
    });

    test('copyWith updates error to null when specified', () {
      // Arrange
      const initialState = AuthState(
        isAuthenticated: false,
        isLoading: false,
        token: null,
        error: 'Initial error',
      );

      // Act
      final newState = initialState.copyWith(error: null);

      // Assert
      expect(newState.error, null);
    });

    test('copyWith updates all values when specified', () {
      // Arrange
      const initialState = AuthState(
        isAuthenticated: false,
        isLoading: false,
        token: null,
        error: null,
      );

      // Act
      final newState = initialState.copyWith(
        isAuthenticated: true,
        isLoading: true,
        token: testToken,
        error: 'New error',
      );

      // Assert
      expect(newState.isAuthenticated, true);
      expect(newState.isLoading, true);
      expect(newState.token, testToken);
      expect(newState.error, 'New error');
    });
  });
}
