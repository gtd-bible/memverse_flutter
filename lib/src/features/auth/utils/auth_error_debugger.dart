import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/features/auth/providers/auth_error_handler_provider.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';

/// A utility class for debugging authentication errors
///
/// This class can be used in development to simulate various authentication errors
/// and verify that they are properly handled and reported to analytics and crashlytics.
class AuthErrorDebugger {
  /// Creates a new AuthErrorDebugger
  const AuthErrorDebugger({required this.errorHandler, required this.appLogger});

  /// The error handler to use for processing errors
  final AuthErrorHandler errorHandler;

  /// The app logger for additional logging
  final AppLoggerFacade appLogger;

  /// Simulate a HTTP error with a specific status code
  ///
  /// This method creates a DioException with the specified status code and response data
  /// and passes it to the error handler to verify proper handling.
  ///
  /// Parameters:
  /// - [statusCode]: The HTTP status code to simulate (e.g., 401, 404, 500)
  /// - [responseData]: Optional response data to include
  /// - [context]: The error context (e.g., 'Login', 'Logout')
  /// - [additionalData]: Additional data to include in error reporting
  Future<String> simulateHttpError({
    required int statusCode,
    dynamic responseData,
    required String context,
    Map<String, dynamic>? additionalData,
  }) async {
    // Create fake RequestOptions
    final requestOptions = RequestOptions(
      path: 'https://www.memverse.com/api/v1/auth',
      method: 'POST',
    );

    // Create fake Response object
    final response = Response(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: responseData,
    );

    // Create DioException with the response
    final dioException = DioException(
      requestOptions: requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );

    // Log that we're simulating an error
    if (kDebugMode) {
      print('🐞 SIMULATING HTTP $statusCode ERROR:');
      print('📌 Context: $context');
      print('🔴 Response Data: ${jsonEncode(responseData)}');
      print('📋 Additional Data: $additionalData');
    }

    // Process the error with the error handler
    return errorHandler.processError(
      dioException,
      StackTrace.current,
      context: context,
      additionalData: additionalData,
    );
  }

  /// Simulate a network error (e.g., timeout, connection failure)
  ///
  /// This method creates a DioException with the specified type
  /// and passes it to the error handler to verify proper handling.
  ///
  /// Parameters:
  /// - [type]: The type of DioException to simulate
  /// - [context]: The error context (e.g., 'Login', 'Logout')
  /// - [additionalData]: Additional data to include in error reporting
  Future<String> simulateNetworkError({
    required DioExceptionType type,
    required String context,
    Map<String, dynamic>? additionalData,
  }) async {
    // Create fake RequestOptions
    final requestOptions = RequestOptions(
      path: 'https://www.memverse.com/api/v1/auth',
      method: 'POST',
    );

    // Create DioException with the specified type
    final dioException = DioException(
      requestOptions: requestOptions,
      type: type,
      message: _getNetworkErrorMessage(type),
    );

    // Log that we're simulating a network error
    if (kDebugMode) {
      print('🐞 SIMULATING NETWORK ERROR:');
      print('📌 Context: $context');
      print('🔴 Error Type: $type');
      print('📋 Additional Data: $additionalData');
    }

    // Process the error with the error handler
    return errorHandler.processError(
      dioException,
      StackTrace.current,
      context: context,
      additionalData: additionalData,
    );
  }

  /// Simulate a socket exception (e.g., no internet connection)
  ///
  /// Parameters:
  /// - [message]: The error message
  /// - [context]: The error context (e.g., 'Login', 'Logout')
  /// - [additionalData]: Additional data to include in error reporting
  Future<String> simulateSocketException({
    required String message,
    required String context,
    Map<String, dynamic>? additionalData,
  }) async {
    // Create a SocketException
    final socketException = SocketException(message);

    // Log that we're simulating a socket exception
    if (kDebugMode) {
      print('🐞 SIMULATING SOCKET EXCEPTION:');
      print('📌 Context: $context');
      print('🔴 Message: $message');
      print('📋 Additional Data: $additionalData');
    }

    // Process the error with the error handler
    return errorHandler.processError(
      socketException,
      StackTrace.current,
      context: context,
      additionalData: additionalData,
    );
  }

  /// Simulate a format exception (e.g., invalid JSON response)
  ///
  /// Parameters:
  /// - [message]: The error message
  /// - [context]: The error context (e.g., 'Login', 'Logout')
  /// - [additionalData]: Additional data to include in error reporting
  Future<String> simulateFormatException({
    required String message,
    required String context,
    Map<String, dynamic>? additionalData,
  }) async {
    // Create a FormatException
    final formatException = FormatException(message);

    // Log that we're simulating a format exception
    if (kDebugMode) {
      print('🐞 SIMULATING FORMAT EXCEPTION:');
      print('📌 Context: $context');
      print('🔴 Message: $message');
      print('📋 Additional Data: $additionalData');
    }

    // Process the error with the error handler
    return errorHandler.processError(
      formatException,
      StackTrace.current,
      context: context,
      additionalData: additionalData,
    );
  }

  /// Run a comprehensive test of all error types
  ///
  /// This method simulates all possible error types to verify proper handling.
  Future<void> runComprehensiveTest() async {
    final results = <String, String>{};

    // Test HTTP errors
    final httpErrors = [400, 401, 403, 404, 422, 500, 503];
    for (final statusCode in httpErrors) {
      final userMessage = await simulateHttpError(
        statusCode: statusCode,
        responseData: {'error': 'Test error for HTTP $statusCode'},
        context: 'AuthTest_HTTP_$statusCode',
        additionalData: {'test_run': true, 'error_type': 'http_$statusCode'},
      );
      results['HTTP $statusCode'] = userMessage;
    }

    // Test network errors
    final networkErrors = [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ];
    for (final errorType in networkErrors) {
      final userMessage = await simulateNetworkError(
        type: errorType,
        context: 'AuthTest_Network_${errorType.name}',
        additionalData: {'test_run': true, 'error_type': 'network_${errorType.name}'},
      );
      results['Network ${errorType.name}'] = userMessage;
    }

    // Test socket exception
    final socketMessage = await simulateSocketException(
      message: 'Failed to connect to www.memverse.com',
      context: 'AuthTest_Socket',
      additionalData: {'test_run': true, 'error_type': 'socket'},
    );
    results['Socket Exception'] = socketMessage;

    // Test format exception
    final formatMessage = await simulateFormatException(
      message: 'Unexpected character at position 42',
      context: 'AuthTest_Format',
      additionalData: {'test_run': true, 'error_type': 'format'},
    );
    results['Format Exception'] = formatMessage;

    // Print the results
    if (kDebugMode) {
      print('\n📊 AUTH ERROR TEST RESULTS:');
      print('═════════════════════════════════════════');
      results.forEach((key, value) {
        print('✓ $key: "$value"');
      });
      print('═════════════════════════════════════════\n');
    }

    // Log comprehensive test complete
    appLogger.info(
      'Auth error testing complete - ${results.length} scenarios tested',
      null,
      StackTrace.current,
    );
  }

  /// Get a descriptive message for a network error type
  String _getNetworkErrorMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out';
      case DioExceptionType.sendTimeout:
        return 'Send operation timed out';
      case DioExceptionType.receiveTimeout:
        return 'Receive operation timed out';
      case DioExceptionType.badCertificate:
        return 'Bad SSL certificate';
      case DioExceptionType.badResponse:
        return 'Bad response';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      case DioExceptionType.unknown:
        return 'Unknown error';
    }
  }
}

/// Provider for the AuthErrorDebugger
final authErrorDebuggerProvider = Provider<AuthErrorDebugger>((ref) {
  final errorHandler = ref.watch(authErrorHandlerProvider);
  final appLogger = ref.watch(appLoggerFacadeProvider);

  return AuthErrorDebugger(errorHandler: errorHandler, appLogger: appLogger);
});
