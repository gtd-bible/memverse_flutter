import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/src/common/providers/bootstrap_provider.dart';
import 'package:mini_memverse/src/common/providers/talker_provider.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_token.dart';
import 'package:mini_memverse/src/monitoring/analytics_client.dart';
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

  return AuthNotifier(
    authService,
    clientId,
    clientSecret,
    analyticsService,
    analyticsFacade,
    talker,
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
  AuthNotifier(
    this._authService,
    this._clientId,
    this._clientSecret,
    this._analyticsService,
    this._analyticsFacade,
    this._talker,
  ) : super(const AuthState()) {
    _init();
  }

  final AuthService _authService;
  final String _clientId;
  final String _clientSecret;
  final AnalyticsService _analyticsService;
  final AnalyticsFacade _analyticsFacade;
  final Talker _talker;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final token = await _authService.getToken();
      state = state.copyWith(isAuthenticated: true, isLoading: false, token: token);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true);

      // Log authentication attempt (not exposing sensitive details)
      AppLogger.i(
        '***Attempting login with client ID: ${_clientId.isNotEmpty ? "PRESENT" : "MISSING"}',
      );
      AppLogger.i(
        '***Attempting login with client secret: ${_clientSecret.isNotEmpty ? "PRESENT" : "MISSING"}',
      );

      // Send analytics event for login attempt (before network call)
      // This helps track how many users attempt to log in
      _analyticsFacade.logEvent(
        'login_attempt',
        parameters: {'has_username': username.isNotEmpty, 'username_length': username.length},
      );

      final token = await _authService.login(username, password, _clientId, _clientSecret);

      // Log token information (non-sensitive parts)
      if (token.accessToken.isNotEmpty) {
        AppLogger.i('Successfully authenticated');

        // Track successful login with both analytics systems
        await _analyticsService.trackLogin(username);
        await _analyticsFacade.trackLogin();

        // Log successful authentication with detailed user data
        _analyticsFacade.logEvent(
          'login_success',
          parameters: {
            'user_id': token.userId.toString(),
            'token_type': token.tokenType,
            'authenticated': true,
          },
        );
      } else {
        AppLogger.i('Authentication failed by access token not being present');

        // Log empty token error
        _analyticsFacade.logEvent(
          'login_empty_token',
          parameters: {'has_username': username.isNotEmpty, 'authenticated': false},
        );

        // Log this error with Talker for detailed error reporting
        _talker.error('Login failed - Empty access token received');
      }

      state = state.copyWith(isAuthenticated: true, isLoading: false, token: token);
    } catch (e, stackTrace) {
      AppLogger.error('Login failed', e);

      // Track login failure with both analytics systems
      await _analyticsService.trackLoginFailure(username, e.toString());

      // Use Talker for comprehensive error reporting with stack traces
      _talker.handle(e, stackTrace, 'Login failed');

      // Log detailed error information to crashlytics
      _analyticsFacade.recordError(
        e,
        stackTrace,
        reason: 'Login failure',
        fatal: false,
        additionalData: {
          'username_provided': username.isNotEmpty,
          'username_length': username.length,
          'client_id_provided': _clientId.isNotEmpty,
          'client_secret_provided': _clientSecret.isNotEmpty,
        },
      );

      // Send error analytics
      _analyticsFacade.trackError('auth_error', 'Login failed: ${e.toString()}');

      // Extract friendly error message if available
      String userFriendlyError;

      if (e.toString().contains('Exception: ')) {
        // Extract the message from our improved error handling in auth_service.dart
        userFriendlyError = e.toString().replaceFirst('Exception: ', '');
      } else {
        // Fallback for unexpected errors
        userFriendlyError = 'Login failed. Please check your credentials and try again.';
      }

      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.logout();

      // Track logout with both analytics systems
      await _analyticsService.trackLogout();
      await _analyticsFacade.trackLogout();

      // Log detailed logout information
      _analyticsFacade.logEvent(
        'user_logout',
        parameters: {
          'user_id': state.token?.userId?.toString() ?? 'unknown',
          'session_active': state.isAuthenticated,
        },
      );

      state = const AuthState();
    } catch (e, stackTrace) {
      // Log the error with Talker
      _talker.handle(e, stackTrace, 'Logout failed');

      // Record the error in Crashlytics
      _analyticsFacade.recordError(e, stackTrace, reason: 'Logout failure', fatal: false);

      // Send error analytics
      _analyticsFacade.trackError('auth_error', 'Logout failed: ${e.toString()}');

      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
