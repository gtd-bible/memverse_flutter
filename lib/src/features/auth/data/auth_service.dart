import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/constants/api_constants.dart' as api_constants;
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
class AuthService {
  /// Creates a new AuthService
  ///
  /// [secureStorage] is used to persist auth tokens
  /// [dio] is used for network requests
  AuthService({
    required FlutterSecureStorage secureStorage,
    required Dio dio,
    required AppLoggerFacade appLogger,
    AuthApi? authApi,
  })  : _secureStorage = secureStorage,
        _dio = dio,
        _logger = appLogger {
    // Configure Dio default headers
    _dio.options.contentType = 'application/x-www-form-urlencoded';
    _dio.options.headers = {'Content-Type': 'application/x-www-form-urlencoded'};

    // Initialize API client with the dio instance
    _authApi = authApi ?? AuthApi(dio, baseUrl: api_constants.apiBaseUrl);
  }

  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  final AppLoggerFacade _logger;
  late final AuthApi _authApi;

  /// Used to track dummy user mode for development/testing
  bool isDummyUser = false;

  /// Key used to store the auth token in secure storage
  static const _tokenKey = 'auth_token';

  /// Saves an auth token to secure storage
  ///
  /// Encrypts the token for secure storage
  Future<void> saveToken(AuthToken token) async {
    final tokenJson = json.encode(token.toJson());
    await _secureStorage.write(key: _tokenKey, value: tokenJson);
  }

  /// Gets the saved auth token from secure storage
  ///
  /// Returns null if no token is found or if there's an error
  Future<AuthToken?> getToken() async {
    try {
      final tokenJson = await _secureStorage.read(key: _tokenKey);
      if (tokenJson == null || tokenJson.isEmpty) {
        return null;
      }

      final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
      return AuthToken.fromJson(tokenMap);
    } catch (e) {
      _logger.error('Error getting auth token from storage', e);
      return null;
    }
  }

  /// Clears any saved auth token from secure storage
  ///
  /// Used during logout
  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Checks if the auth token is valid and not expired
  ///
  /// Not currently implemented fully as API doesn't send expiry
  Future<bool> isTokenValid(AuthToken token) async {
    // Simple validation check
    return token.accessToken.isNotEmpty;

    // Implement proper token validation with expiry when API provides it
    // if (token.expiresAt != null) {
    //   final now = DateTime.now();
    //   final expiryDate = DateTime.fromMillisecondsSinceEpoch(token.expiresAt! * 1000);
    //   return now.isBefore(expiryDate);
    // }
  }

  /// Adds auth headers to an HTTP request
  ///
  /// Used to authenticate API requests
  Options addAuthHeaders(Options? options, AuthToken token) {
    final headers = {
      ...(options?.headers ?? {}),
      'Authorization': '${token.tokenType} ${token.accessToken}',
    };

    return Options(
      headers: headers,
      contentType: options?.contentType,
      responseType: options?.responseType,
      // Add more options as needed
    );
  }

  /// Logs a user in with the given credentials
  ///
  /// Throws an exception if authentication fails
  Future<AuthToken> login(
    String username,
    String password,
    String clientId,
    String clientSecret,
  ) async {
    // Dummy user fast-path (bypasses all real auth)
    if (username.toLowerCase() == 'dummysigninuser@dummy.com') {
      isDummyUser = true;
      _logger.i('Bypassing authentication: using dummysigninuser');
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
    
    // Validate credentials before even attempting API call
    if (clientId.isEmpty || clientId == '\$MEMVERSE_CLIENT_ID') {
      _logger.error('Invalid client ID value', 'Client ID is empty or unsubstituted variable');
      throw Exception('Configuration error - Client ID not properly set');
    }
    
    if (clientSecret.isEmpty || clientSecret == '\$MEMVERSE_CLIENT_API_KEY') {
      _logger.error(
        'Invalid client secret value',
        'Client secret is empty or unsubstituted variable',
      );
      throw Exception('Configuration error - Client secret not properly set');
    }
    
    try {
      _logger.i('Attempting login with provided credentials');
      _logger.d(
        'LOGIN - Attempting to log in with username: $username and clientId is non-empty: $clientId.isNotEmpty and apiKey is non-empty: $clientSecret.isNotEmpty',
      );

      final authToken = await _authApi.getBearerToken(
        'password',
        username,
        password,
        clientId,
        clientSecret,
      );
      
      // Validate token before proceeding
      // Note: With non-nullable return type, we don't need this check
      // But keeping it commented for future reference
      // if (authToken == null) {
      //   _logger.error('Received null token from API', 'API returned null instead of AuthToken');
      //   throw Exception('Server returned an invalid response - null token');
      // }
      
      if (authToken.accessToken.isEmpty) {
        _logger.error('Received empty access token', 'API returned token with empty accessToken');
        throw Exception('Server returned an invalid token');
      }
      
      _logger.d(
        'LOGIN - Received successful response with token ${authToken.accessToken.substring(0, 5)}...',
      );
      _logger.d('LOGIN - Token type: ${authToken.tokenType}');
      await saveToken(authToken);
      return authToken;
    } catch (e) {
      _logger.error('Login failed with AuthApi/Retrofit exception', e);

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
              friendlyMessage = 'Server error (Status $statusCode) - Please try again later';
              technicalDetails = 'HTTP $statusCode: $responseData';
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
      _logger.error('FRIENDLY ERROR: $friendlyMessage');
      _logger.error('TECHNICAL DETAILS: $technicalDetails');

      // Rethrow with a user-friendly message
      throw Exception(friendlyMessage);
    }
  }

  /// Logs the user out by clearing stored token
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      _logger.error('Error during logout', e);
      rethrow;
    }
  }

  /// Checks if the user is logged in by verifying token existence
  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return token != null;
    } catch (e) {
      _logger.error('Error checking login status', e);
      return false;
    }
  }
}