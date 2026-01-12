import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:talker/talker.dart';

/// A comprehensive error handler for authentication errors
///
/// This utility helps process auth errors consistently across the app,
/// sending them to Crashlytics, Firebase Analytics, and local logs.
class AuthErrorHandler {
  /// Creates a new AuthErrorHandler
  const AuthErrorHandler({
    required this.analyticsFacade,
    required this.appLogger,
    required this.talker,
  });

  /// The analytics facade for tracking errors
  final AnalyticsFacade analyticsFacade;

  /// The app logger facade for local logging
  final AppLoggerFacade appLogger;

  /// The talker instance for UI error reporting
  final Talker talker;

  /// Process an authentication error with comprehensive tracking
  ///
  /// This method:
  /// 1. Logs the error to Crashlytics with context
  /// 2. Tracks the error in Firebase Analytics with proper attributes
  /// 3. Logs detailed error information in debug mode
  /// 4. Returns a user-friendly error message
  Future<String> processError(
    dynamic error,
    StackTrace? stackTrace, {
    required String context,
    Map<String, dynamic>? additionalData,
  }) async {
    // Prepare the error message
    String userFriendlyMessage = '';
    String errorType = 'unknown_error';
    bool isFatal = false;
    final Map<String, dynamic> errorData = {
      'error_context': context,
      'timestamp': DateTime.now().toIso8601String(),
      ...?additionalData,
    };

    // Extract error details based on type
    if (error is DioException) {
      await _processDioError(error, stackTrace, errorData, context);
      userFriendlyMessage = _extractUserFriendlyMessage(error);
      errorType = 'network_error';
    } else if (error is SocketException) {
      errorType = 'connection_error';
      errorData['error_code'] = 'socket_exception';
      errorData['error_message'] = error.message;
      userFriendlyMessage =
          'Unable to connect to the server. Please check your internet connection.';
    } else if (error is HttpException) {
      errorType = 'http_error';
      errorData['error_message'] = error.message;
      userFriendlyMessage =
          'There was a problem communicating with the server. Please try again later.';
    } else if (error is FormatException) {
      errorType = 'format_error';
      errorData['error_message'] = error.message;
      userFriendlyMessage = 'The server response was not in the expected format.';
    } else {
      // Handle general exceptions
      errorType = 'general_error';
      errorData['error_message'] = error.toString();
      userFriendlyMessage = 'An unexpected error occurred. Please try again later.';
    }

    // Log comprehensive error information
    appLogger.error(
      '[$context] $errorType: $userFriendlyMessage',
      error,
      stackTrace,
      true,
      errorData,
    );

    // Track in Firebase Analytics
    await analyticsFacade.trackError(errorType, '$context: ${error.toString()}');

    // Record detailed error in Crashlytics
    await analyticsFacade.recordError(
      error,
      stackTrace,
      reason: '$context failure',
      fatal: isFatal,
      additionalData: errorData,
    );

    // Add to talker for UI display
    talker.handle(error, stackTrace, '$context failed');

    // Log detailed diagnostics in debug mode
    if (kDebugMode) {
      print('🔍 AUTH ERROR DIAGNOSTICS:');
      print('📋 Context: $context');
      print('⚠️ Error Type: $errorType');
      print('🔴 Error: ${error.toString()}');
      print('📱 User Message: $userFriendlyMessage');
      print('📊 Analytics Data: $errorData');
    }

    return userFriendlyMessage;
  }

  /// Process a DioException with detailed HTTP error analysis
  Future<void> _processDioError(
    DioException error,
    StackTrace? stackTrace,
    Map<String, dynamic> errorData,
    String context,
  ) async {
    final response = error.response;

    if (response != null) {
      // Extract HTTP status code and response data
      final statusCode = response.statusCode;
      errorData['status_code'] = statusCode;
      errorData['headers'] = response.headers.map.toString();

      // Include redacted response body - be careful not to include sensitive data
      try {
        final dynamic responseData = response.data;
        if (responseData is Map) {
          // Redact any potentially sensitive fields
          final redactedData = Map<String, dynamic>.from(responseData as Map);
          _redactSensitiveFields(redactedData);
          errorData['response_data'] = redactedData;
        } else if (responseData is String) {
          // Limit string length to avoid huge error reports
          errorData['response_data'] = responseData.substring(
            0,
            responseData.length > 500 ? 500 : responseData.length,
          );
        }
      } catch (e) {
        errorData['response_parse_error'] = e.toString();
      }

      // Log specific HTTP errors to Analytics
      final httpEvent = 'http_error_$statusCode';
      await analyticsFacade.logEvent(
        httpEvent,
        parameters: {
          'url': error.requestOptions.path,
          'method': error.requestOptions.method,
          'context': context,
        },
      );
    } else {
      // Handle cases where response is null (e.g., no internet, timeout)
      errorData['error_type'] = error.type.toString();
      errorData['message'] = error.message ?? 'Unknown error';
    }
  }

  /// Extract a user-friendly error message from a DioException
  String _extractUserFriendlyMessage(DioException error) {
    final response = error.response;

    if (response == null) {
      // Connection errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timed out. Please try again later.';
        case DioExceptionType.sendTimeout:
          return 'Unable to send data to the server. Please try again.';
        case DioExceptionType.receiveTimeout:
          return 'The server is taking too long to respond. Please try again later.';
        case DioExceptionType.connectionError:
          return 'Cannot connect to the server. Please check your internet connection.';
        default:
          return 'A network error occurred. Please try again later.';
      }
    }

    // HTTP status code based messages
    final statusCode = response.statusCode;
    switch (statusCode) {
      case 400:
        return _extractServerErrorMessage(response.data) ??
            'The server couldn\'t process your request. Please try again.';
      case 401:
        return 'Invalid username or password. Please try again.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return _extractServerErrorMessage(response.data) ??
            'The server couldn\'t process your request due to validation errors.';
      case 500:
      case 501:
      case 502:
      case 503:
        return 'The server encountered an error. Please try again later.';
      default:
        return 'An unexpected server error occurred (Status $statusCode).';
    }
  }

  /// Extract server error message from response data if available
  String? _extractServerErrorMessage(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        // Try common API error formats
        return data['error_description'] as String? ??
            data['message'] as String? ??
            data['error'] as String?;
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Redact sensitive fields from error data to avoid logging credentials
  void _redactSensitiveFields(Map<String, dynamic> data) {
    final sensitiveFields = [
      'password',
      'token',
      'secret',
      'key',
      'credentials',
      'auth',
      'access_token',
      'refresh_token',
      'id_token',
      'session',
    ];

    for (final key in data.keys.toList()) {
      final keyLower = key.toLowerCase();
      if (sensitiveFields.any((field) => keyLower.contains(field))) {
        data[key] = '[REDACTED]';
      } else if (data[key] is Map) {
        _redactSensitiveFields(data[key] as Map<String, dynamic>);
      }
    }
  }
}
