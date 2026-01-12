import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/src/common/interceptors/curl_logging_interceptor.dart';
import 'package:mini_memverse/src/constants/api_constants.dart';
import 'package:mini_memverse/src/features/auth/data/auth_api.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_token.dart';

// Client secret is now provided directly via the login method

/// Authentication service for handling login, token storage, and session management
///
/// IMPORTANT: Memverse API has different base URLs for different endpoints:
/// - OAuth endpoint (native): https://www.memverse.com/oauth/token (root level)
/// - OAuth endpoint (web): /oauth/token (Netlify proxy)
/// - Other API endpoints (native): https://www.memverse.com/api/v1/* (versioned path)
/// - Other API endpoints (web): /api/* (Netlify proxy)
///
/// This is why AuthApi uses different base URLs for web vs native platforms
class AuthService {
  /// Create a new AuthService
  AuthService({FlutterSecureStorage? secureStorage, Dio? dio, AuthApi? authApi})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
      _authApi =
          authApi ??
          // CRITICAL: OAuth endpoint routing depends on platform:
          // - Web: Uses Netlify proxy at /oauth/token (relative URL)
          // - Native: Uses direct HTTPS at https://www.memverse.com/oauth/token
          AuthApi(
            _createDioWithLogging(dio),
            baseUrl: kIsWeb ? webOAuthPrefix : 'https://www.memverse.com',
          );

  static Dio _createDioWithLogging(Dio? dio) {
    final dioInstance = dio ?? Dio();

    // Configure default settings to match successful curl request
    dioInstance.options.validateStatus = (status) => status! < 500;

    // CRITICAL: For OAuth token endpoint, we need to make the request exactly match the curl command
    dioInstance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // FIX: For OAuth endpoint, ensure we match the successful curl command exactly
          if (options.path.contains('/oauth/token')) {
            AppLogger.i('🔄 Applying special handling for OAuth token endpoint');

            // 1. CLEAR ALL QUERY PARAMETERS - they should only be in the form body
            if (options.queryParameters.isNotEmpty) {
              AppLogger.w(
                '⚠️ Clearing query parameters from OAuth request: ${options.queryParameters}',
              );
              options.queryParameters = {};
            }

            // 2. ENSURE CORRECT CONTENT TYPE
            options.contentType = 'application/x-www-form-urlencoded';
            options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

            // 3. VERIFY WE HAVE FORM DATA
            if (options.data == null || options.data is! Map) {
              AppLogger.e('❌ OAuth request data is not correctly formatted! ${options.data}');
            }
          }

          handler.next(options);
        },
      ),
    );

    // Add curl logging to see exactly what's sent
    dioInstance.interceptors.add(CurlLoggingInterceptor());

    // Add detailed request/response logging
    dioInstance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.i('🚀 OAuth Request: ${options.method} ${options.uri}');
          AppLogger.i('📝 Headers: ${options.headers}');
          if (kDebugMode) {
            AppLogger.i('📦 Data: ${options.data}');
          }
          AppLogger.i('📋 Content-Type: ${options.contentType}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.i('✅ OAuth Response: ${response.statusCode}');
          AppLogger.i('📝 Response Headers: ${response.headers}');
          if (kDebugMode) {
            AppLogger.i('📦 Response Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error('❌ OAuth Error: ${error.message}');
          AppLogger.error('🔍 Request: ${error.requestOptions.method} ${error.requestOptions.uri}');
          AppLogger.error('📝 Request Headers: ${error.requestOptions.headers}');
          if (kDebugMode) {
            AppLogger.error('📦 Request Data: ${error.requestOptions.data}');
          }
          if (error.response != null) {
            if (kDebugMode) {
              AppLogger.error('📥 Error Response: ${error.response?.data}');
            }
            AppLogger.error('🔢 Status Code: ${error.response?.statusCode}');
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
  static bool isDummyUser = false;

  /// Attempts to login with the provided credentials
  Future<AuthToken> login(
    String username,
    String password,
    String clientId,
    String clientSecret,
  ) async {
    // Dummy user fast-path (bypasses all real auth)
    if (username.toLowerCase() == 'dummysigninuser@dummy.com') {
      isDummyUser = true;
      AppLogger.i('Bypassing authentication: using dummysigninuser');
      final fakeToken = AuthToken(
        accessToken: 'fake_token',
        tokenType: 'bearer',
        scope: 'user',
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        userId: 0,
      );
      await saveToken(fakeToken);
      return fakeToken;
    }
    try {
      AppLogger.i('Attempting login with provided credentials');
      AppLogger.d(
        'LOGIN - Attempting to log in with username: $username and clientId is non-empty: ${clientId.isNotEmpty} and apiKey is non-empty: ${clientSecret.isNotEmpty}',
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
      return authToken;
    } catch (e) {
      AppLogger.error('Login failed with AuthApi/Retrofit exception', e);

      // Extract useful information from different error types
      String friendlyMessage;
      String technicalDetails;

      if (e is DioException) {
        // This is a network/HTTP error
        if (e.type == DioExceptionType.connectionTimeout) {
          friendlyMessage = 'Connection timeout - Please check your internet connection';
          technicalDetails = 'Network timeout: ${e.message}';
        } else if (e.type == DioExceptionType.connectionError) {
          friendlyMessage = 'Connection error - Unable to reach the Memverse server';
          technicalDetails = 'Connection error: ${e.message}';
        } else if (e.response != null) {
          // We have a server response with error
          final statusCode = e.response!.statusCode;
          final responseData = e.response!.data;

          // Handle specific status codes
          switch (statusCode) {
            case 401:
              friendlyMessage = 'Invalid username or password';
              technicalDetails = 'Authentication failed (401): $responseData';
              break;
            case 403:
              friendlyMessage = 'Access denied - Check your client ID and API key';
              technicalDetails = 'Authorization failed (403): $responseData';
              break;
            case 404:
              friendlyMessage = 'API endpoint not found - Contact support';
              technicalDetails = 'Endpoint not found (404): ${e.requestOptions.path}';
              break;
            case 302:
              friendlyMessage =
                  'Server redirected the request - Authentication endpoint configuration issue';
              technicalDetails = 'Redirect (302) to: ${e.response?.headers['location']}';
              break;
            default:
              friendlyMessage = 'Server error (Status ${statusCode}) - Please try again later';
              technicalDetails = 'HTTP ${statusCode}: $responseData';
          }
        } else {
          // Other Dio error without response
          friendlyMessage = 'Network error - Please check your connection';
          technicalDetails = 'Dio error (${e.type}): ${e.message}';
        }
      } else if (e.toString().contains('Null check operator used on a null value')) {
        // Handle null check errors which likely mean invalid response format
        friendlyMessage = 'Server returned an unexpected response format';
        technicalDetails = 'Null check error processing server response: $e';
      } else {
        // Generic error fallback
        friendlyMessage = 'Login failed - Please try again';
        technicalDetails = 'Unhandled exception: $e';
      }

      // Log both messages but only throw the user-friendly one
      AppLogger.error('FRIENDLY ERROR: $friendlyMessage');
      AppLogger.error('TECHNICAL DETAILS: $technicalDetails');

      // Rethrow with a user-friendly message
      throw Exception(friendlyMessage);
    }
  }

  /// Logs the user out by clearing stored token
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      AppLogger.error('Error during logout', e);
      rethrow;
    }
  }

  /// Checks if the user is logged in by verifying token existence
  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return token != null;
    } catch (e) {
      AppLogger.error('Error checking login status', e);
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
      AppLogger.error('Error retrieving token', e);
      return null;
    }
  }

  /// Saves the auth token to secure storage
  Future<void> saveToken(AuthToken token) async {
    try {
      final tokenJson = jsonEncode(token.toJson());
      await _secureStorage.write(key: _tokenKey, value: tokenJson);
    } catch (e) {
      AppLogger.error('Error saving token', e);
      rethrow;
    }
  }
}

class MockAuthService extends AuthService {
  MockAuthService();

  @override
  Future<bool> isLoggedIn() async => true;

  @override
  Future<AuthToken> login(
    String username,
    String password,
    String clientId,
    String clientSecret,
  ) async => AuthToken(
    accessToken: 'mock',
    tokenType: 'Bearer',
    scope: 'user',
    createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    userId: 0,
  );

  @override
  Future<void> logout() async {}

  @override
  Future<AuthToken?> getToken() async => AuthToken(
    accessToken: 'mock',
    tokenType: 'Bearer',
    scope: 'user',
    createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    userId: 0,
  );
}
