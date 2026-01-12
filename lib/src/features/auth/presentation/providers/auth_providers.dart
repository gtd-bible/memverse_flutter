import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/common/providers/bootstrap_provider.dart';
import 'package:mini_memverse/src/common/providers/talker_provider.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_token.dart';
import 'package:mini_memverse/src/features/auth/providers/auth_error_handler_provider.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:talker/talker.dart';

/// Provider to check if user is logged in
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.isLoggedIn();
});

/// Provider for accessing the access token across the app
final accessTokenProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.token?.accessToken ?? '';
});

/// Provider for accessing the formatted bearer token for Authorization header
final bearerTokenProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState.token?.accessToken == null || authState.token!.accessToken.isEmpty) {
    return '';
  }
  return '${authState.token!.tokenType} ${authState.token!.accessToken}';
});

/// Provider for the client id
final clientIdProvider = Provider<String>((ref) {
  return ref.watch(bootstrapProvider).clientId;
});

/// Provider for the client secret
final clientSecretProvider = Provider<String>((ref) {
  return ref.watch(bootstrapProvider).clientSecret;
});

/// Provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Authentication state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final clientId = ref.watch(clientIdProvider);
  final clientSecret = ref.watch(clientSecretProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  final analyticsFacade = ref.watch(analyticsFacadeProvider);
  final talker = ref.watch(talkerProvider);
  final appLogger = ref.watch(appLoggerFacadeProvider);
  final errorHandler = ref.watch(authErrorHandlerProvider);

  return AuthNotifier(
    authService: authService,
    clientId: clientId,
    clientSecret: clientSecret,
    analyticsService: analyticsService,
    analyticsFacade: analyticsFacade,
    talker: talker,
    appLogger: appLogger,
    errorHandler: errorHandler,
  );
});

/// Authentication state
class AuthState {
  /// Creates an authentication state
  const AuthState({this.isAuthenticated = false, this.isLoading = false, this.token, this.error});

  final bool isAuthenticated;
  final bool isLoading;
  final AuthToken? token;
  final String? error;

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, AuthToken? token, String? error}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      error: error,
    );
  }
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required AuthService authService,
    required String clientId,
    required String clientSecret,
    required AnalyticsService analyticsService,
    required AnalyticsFacade analyticsFacade,
    required Talker talker,
    required AppLoggerFacade appLogger,
    required AuthErrorHandler errorHandler,
  }) : _authService = authService,
       _clientId = clientId,
       _clientSecret = clientSecret,
       _analyticsService = analyticsService,
       _analyticsFacade = analyticsFacade,
       _talker = talker,
       _appLogger = appLogger,
       _errorHandler = errorHandler,
       super(const AuthState()) {
    _init();
  }

  final AuthService _authService;
  final String _clientId;
  final String _clientSecret;
  final AnalyticsService _analyticsService;
  final AnalyticsFacade _analyticsFacade;
  final Talker _talker;
  final AppLoggerFacade _appLogger;
  final AuthErrorHandler _errorHandler;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final token = await _authService.getToken();
      state = state.copyWith(
        isAuthenticated: token != null && token.accessToken.isNotEmpty,
        isLoading: false,
        token: token,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Log authentication attempt with sensitive details protected
      _appLogger.i(
        '***Attempting login with client ID: ${_clientId.isNotEmpty ? "PRESENT" : "MISSING"}',
      );
      _appLogger.i(
        '***Attempting login with client secret: ${_clientSecret.isNotEmpty ? "PRESENT" : "MISSING"}',
      );

      // Send analytics event for login attempt (before network call)
      // This helps track how many users attempt to log in
      await _analyticsFacade.logEvent(
        'login_attempt',
        parameters: {
          'has_username': username.isNotEmpty,
          'username_length': username.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Attempt login with credentials
      final token = await _authService.login(username, password, _clientId, _clientSecret);

      // Handle successful login vs empty token response
      if (token?.accessToken?.isNotEmpty == true) {
        _appLogger.i('Successfully authenticated');

        // Track successful login with both analytics systems
        await _analyticsService.trackLogin(username);
        await _analyticsFacade.trackLogin();

        // Set user ID in analytics for future events
        if (token.userId != null) {
          await _analyticsFacade.setUserId(token.userId.toString());
        }

        // Log successful authentication with detailed user data
        await _analyticsFacade.logEvent(
          'login_success',
          parameters: {
            'user_id': token.userId?.toString() ?? 'unknown',
            'token_type': token.tokenType,
            'authenticated': true,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        // Track screen view for the next screen
        await _analyticsFacade.logScreenView('dashboard', 'DashboardScreen');
      } else {
        // Handle empty token response (API returned 200 but no valid token)
        _appLogger.warning(
          'Authentication failed: Empty or invalid token received',
          null,
          StackTrace.current,
        );

        // Log empty token error with context
        await _analyticsFacade.logEvent(
          'login_empty_token',
          parameters: {
            'has_username': username.isNotEmpty,
            'authenticated': false,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        // Record as an error for better tracking
        await _errorHandler.processError(
          Exception('Empty access token received'),
          StackTrace.current,
          context: 'Login',
          additionalData: {
            'username_provided': username.isNotEmpty,
            'username_length': username.length,
            'empty_token': true,
          },
        );

        // Update UI with user-friendly message
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          error: 'Login failed. Please try again later.',
        );
        return;
      }

      // Update state with authentication result
      state = state.copyWith(
        isAuthenticated: token != null && token.accessToken.isNotEmpty,
        isLoading: false,
        token: token,
      );
    } catch (e, stackTrace) {
      _appLogger.error('Login failed', e, stackTrace);

      // Track login failure with legacy analytics
      await _analyticsService.trackLoginFailure(username, e.toString());

      // Use our comprehensive error handler for consistent processing
      final userFriendlyError = await _errorHandler.processError(
        e,
        stackTrace,
        context: 'Login',
        additionalData: {
          'username_provided': username.isNotEmpty,
          'username_length': username.length,
          'client_id_provided': _clientId.isNotEmpty,
          'client_secret_provided': _clientSecret.isNotEmpty,
          'auth_method': 'password',
        },
      );

      // Update state with error message
      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Log logout attempt
      _appLogger.i(
        'Attempting to log out user ID: ${state.token?.userId?.toString() ?? "unknown"}',
      );

      // Perform logout operation
      await _authService.logout();

      // Track logout with both analytics systems
      await _analyticsService.trackLogout();
      await _analyticsFacade.trackLogout();

      // Log detailed logout information
      await _analyticsFacade.logEvent(
        'user_logout',
        parameters: {
          'user_id': state.token?.userId?.toString() ?? 'unknown',
          'session_active': state.isAuthenticated,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Clear user ID in analytics
      await _analyticsFacade.setUserId(null);

      // Track screen view for login screen
      await _analyticsFacade.logScreenView('login', 'LoginScreen');

      // Log successful logout
      _appLogger.i('Successfully logged out');

      // Reset auth state completely
      state = const AuthState();
    } catch (e, stackTrace) {
      _appLogger.error('Logout failed', e, stackTrace);

      // Use our comprehensive error handler
      final userFriendlyError = await _errorHandler.processError(
        e,
        stackTrace,
        context: 'Logout',
        additionalData: {
          'user_id': state.token?.userId?.toString() ?? 'unknown',
          'was_authenticated': state.isAuthenticated,
        },
      );

      // Update state with error, but maintain authentication status
      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }
}
