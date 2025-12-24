import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:memverse_flutter/src/common/interceptors/curl_logging_interceptor.dart';
import 'package:memverse_flutter/src/constants/api_constants.dart';
import 'package:memverse_flutter/src/features/auth/data/auth_api.dart';
import 'package:memverse_flutter/src/features/auth/data/auth_service.dart';
import 'package:memverse_flutter/src/features/auth/domain/auth_token.dart';
import 'package:memverse_flutter/src/utils/app_logger.dart';

const String clientSecret = String.fromEnvironment('MEMVERSE_CLIENT_API_KEY');

class RealAuthService implements AuthService {
  RealAuthService({
    FlutterSecureStorage? secureStorage,
    Dio? dio,
    AuthApi? authApi,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _authApi =
            authApi ??
                AuthApi(
                  _createDioWithLogging(dio),
                  baseUrl: kIsWeb ? webOAuthPrefix : 'https://www.memverse.com',
                );

  static Dio _createDioWithLogging(Dio? dio) {
    final dioInstance = dio ?? Dio();

    // Add curl logging to see exactly what's sent
    dioInstance.interceptors.add(CurlLoggingInterceptor());

    // Add detailed request/response logging
    dioInstance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.i('🚀 OAuth Request: ${options.method} ${options.uri}');
          AppLogger.i('📝 Headers: ${options.headers}');
          AppLogger.i('📦 Data: ${options.data}');
          AppLogger.i('📋 Content-Type: ${options.contentType}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.i('✅ OAuth Response: ${response.statusCode}');
          AppLogger.i('📝 Response Headers: ${response.headers}');
          AppLogger.i('📦 Response Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.e('❌ OAuth Error: ${error.message}');
          AppLogger.e(
              '🔍 Request: ${error.requestOptions.method} ${error.requestOptions.uri}');
          AppLogger.e('📝 Request Headers: ${error.requestOptions.headers}');
          AppLogger.e('📦 Request Data: ${error.requestOptions.data}');
          if (error.response != null) {
            AppLogger.e('📥 Error Response: ${error.response?.data}');
            AppLogger.e('🔢 Status Code: ${error.response?.statusCode}');
          }
          handler.next(error);
        },
      ),
    );

    return dioInstance;
  }

  final FlutterSecureStorage _secureStorage;
  final AuthApi _authApi;

  static const _tokenKey = 'auth_token';
  bool _isLoggedIn = false; // In-memory state, should be updated by token presence
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  // No static isDummyUser here, it should be handled via environment or specific test setups

  @override
  Future<bool> login(String username, String password) async {
    // Check if the dummy user is explicitly requested, for testing purposes.
    // In a real app, this would be a mock or a separate test service.
    if (username.toLowerCase() == 'dummysigninuser@dummy.com') {
      AppLogger.i('Bypassing authentication: using dummysigninuser');
      final fakeToken = AuthToken(
        accessToken: 'fake_token',
        tokenType: 'bearer',
        scope: 'user',
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        userId: 0,
      );
      await saveToken(fakeToken);
      _isLoggedIn = true;
      _authStateController.add(true);
      return true;
    }

    try {
      AppLogger.i('Attempting login with provided credentials');
      // Client ID comes from somewhere, possibly another environment variable or hardcoded
      // For now, hardcode a dummy clientId or read from environment if available.
      const String clientId = String.fromEnvironment('MEMVERSE_CLIENT_ID'); // Assume this exists
      AppLogger.d(
        'LOGIN - Attempting to log in with username: $username, clientId present: ${clientId.isNotEmpty}, apiKey present: ${clientSecret.isNotEmpty}',
      );

      final authToken = await _authApi.getBearerToken(
        'password',
        username,
        password,
        clientId,
        clientSecret,
      );
      AppLogger.d('LOGIN - Received successful response with token $authToken');
      AppLogger.d('LOGIN - Raw token type: ${authToken.tokenType}');
      await saveToken(authToken);
      _isLoggedIn = true;
      _authStateController.add(true);
      return true;
    } catch (e) {
      AppLogger.e('Login failed with AuthApi/Retrofit exception', e);
      _isLoggedIn = false;
      _authStateController.add(false);
      return false;
      // Rethrow for error handling in UI
      // throw Exception('Login failed via Retrofit: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      _isLoggedIn = false;
      _authStateController.add(false);
    } catch (e) {
      AppLogger.e('Error during logout', e);
      rethrow;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final tokenJson = await _secureStorage.read(key: _tokenKey);
      _isLoggedIn = tokenJson != null;
      // Do not add to stream here, only when state truly changes (login/logout)
      return _isLoggedIn;
    } catch (e) {
      AppLogger.e('Error checking login status', e);
      _isLoggedIn = false;
      return false;
    }
  }

  /// Gets the stored auth token if available
  Future<AuthToken?> getToken() async {
    try {
      final tokenJson = await _secureStorage.read(key: _tokenKey);
      if (tokenJson == null) return null;

      final tokenMap = jsonDecode(tokenJson) as Map<String, dynamic>;
      return AuthToken.fromJson(tokenMap);
    } catch (e) {
      AppLogger.e('Error retrieving token', e);
      return null;
    }
  }

  /// Saves the auth token to secure storage
  Future<void> saveToken(AuthToken token) async {
    try {
      final tokenJson = jsonEncode(token.toJson());
      await _secureStorage.write(key: _tokenKey, value: tokenJson);
    } catch (e) {
      AppLogger.e('Error saving token', e);
      rethrow;
    }
  }

  @override
  Stream<bool> get authStateChanges async* {
    // Emit initial state
    yield await isAuthenticated();
    // Then emit subsequent changes
    yield* _authStateController.stream;
  }
}
