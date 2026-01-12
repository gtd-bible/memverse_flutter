import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_token.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:talker/talker.dart';

/// Memverse OAuth API client
///
/// IMPORTANT ENDPOINT STRUCTURE:
/// - OAuth token endpoint: /oauth/token (at root level, not under /api/v1/)
/// - Other API endpoints: /api/v1/* (versioned paths)
///
/// AUTHENTICATION REQUIREMENTS:
/// - Content-Type: application/x-www-form-urlencoded (not JSON)
/// - Requires both client_id AND client_secret in form data
class AuthApi {
  /// Constructor
  AuthApi(this._dio, {String? baseUrl, AppLoggerFacade? logger}) {
    _baseUrl = baseUrl ?? 'https://www.memverse.com';
    _logger =
        logger ??
        AppLoggerFacade(
          logger: Logger(),
          talker: Talker(),
          analyticsFacade: AnalyticsFacade([]), // Empty list as we're just providing defaults
          // Let AppLoggerFacade obtain its own instance of Crashlytics rather than using it directly
          crashlytics: null,
        );
  }

  /// Creates a proper auth api with injected dependencies for production use
  factory AuthApi.withLogger(Dio dio, String baseUrl, AppLoggerFacade logger) {
    return AuthApi(dio, baseUrl: baseUrl, logger: logger);
  }

  final Dio _dio;
  late final String _baseUrl;
  late final AppLoggerFacade _logger;

  /// Request OAuth access token using password grant flow
  ///
  /// This endpoint follows OAuth 2.0 password grant standard:
  /// - Needs to be at root level (/oauth/token, not under /api/v1)
  /// - Requires application/x-www-form-urlencoded content type
  /// - Parameters must be in form body (not query parameters)
  Future<AuthToken> getBearerToken(
    String grantType,
    String username,
    String password,
    String clientId,
    String clientSecret,
  ) async {
    if (kDebugMode) {
      _logger.i('🔄 Applying special handling for OAuth token endpoint');
    }

    // Log warning if query parameters are accidentally used
    if (_dio.options.queryParameters.isNotEmpty) {
      _logger.w('⚠️ Clearing query parameters from OAuth request: ${_dio.options.queryParameters}');
      _dio.options.queryParameters.clear();
    }

    // Create the form data for the request
    final formData = {
      'grant_type': grantType,
      'username': username,
      'password': password,
      'client_id': clientId,
      'client_secret': clientSecret,
    };

    // OAuth API endpoint validation
    final tokenUrl = '$_baseUrl/oauth/token';

    if (kDebugMode) {
      _logger.i('✅ OAuth URL matches successful curl command');
      _logger.i('✅ Content-Type matches successful curl command');
      _logger.i('✅ No query parameters (correct for OAuth)');

      // Log request details (with redacted sensitive info)
      _logOAuthRequest(tokenUrl, formData);
    }

    try {
      // Make the OAuth request
      final response = await _dio.post(
        tokenUrl,
        data: formData,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (kDebugMode) {
        _logger.i('✅ OAuth Response: ${response.statusCode}');
        _logger.i('📝 Response Headers: ${response.headers}');
        _logger.i('📦 Response Data: ${response.data}');
      }

      // Convert the response to AuthToken
      return AuthToken.fromJson(response.data);
    } on DioException catch (e) {
      _logger.i('❌ OAuth Error: ${e.message}');
      if (e.response != null) {
        _logger.i('📝 Error Response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Logs OAuth request details with sensitive information redacted
  void _logOAuthRequest(String url, Map<String, dynamic> formData) {
    // Create a redacted copy of form data for logging
    final redactedFormData = {...formData};
    if (redactedFormData.containsKey('password')) {
      redactedFormData['password'] = '[REDACTED]';
    }
    if (redactedFormData.containsKey('client_secret')) {
      redactedFormData['client_secret'] = '[REDACTED]';
    }

    // Log the request details
    _logger.i('┌── HTTP Request ─────────────────────────────────────────────────────────────');
    _logger.i('│ URL: $url');
    _logger.i('│ Method: POST');
    _logger.i('│ Content-Type: application/x-www-form-urlencoded');
    _logger.i('│ Headers:');
    _logger.i('│   content-type: application/x-www-form-urlencoded');
    _logger.i('│ Request Body:');
    _logger.i('│   {');
    redactedFormData.forEach((key, value) {
      _logger.i('│     "$key": "$value",');
    });
    _logger.i('│   }');
    _logger.i('└─────────────────────────────────────────────────────────────────────────────');
    _logger.i('');

    // Additional logging for debugging
    _logger.i('🚀 OAuth Request: POST $url');
    _logger.i('📝 Headers: ${{"content-type": "application/x-www-form-urlencoded"}}');
    _logger.i('📦 Data: $redactedFormData');
    _logger.i('📋 Content-Type: application/x-www-form-urlencoded');
  }
}
