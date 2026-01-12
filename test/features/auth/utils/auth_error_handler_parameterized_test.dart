import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}

class MockAppLoggerFacade extends Mock implements AppLoggerFacade {}

class MockTalker extends Mock implements Talker {}

void main() {
  late AuthErrorHandler errorHandler;
  late MockAnalyticsFacade mockAnalyticsFacade;
  late MockAppLoggerFacade mockAppLogger;
  late MockTalker mockTalker;

  setUp(() {
    mockAnalyticsFacade = MockAnalyticsFacade();
    mockAppLogger = MockAppLoggerFacade();
    mockTalker = MockTalker();

    errorHandler = AuthErrorHandler(
      analyticsFacade: mockAnalyticsFacade,
      appLogger: mockAppLogger,
      talker: mockTalker,
    );

    // Set up default mock behavior
    when(() => mockAnalyticsFacade.trackError(any(), any())).thenAnswer((_) async {});
    when(
      () => mockAnalyticsFacade.recordError(
        any(),
        any(),
        reason: any(named: 'reason'),
        fatal: any(named: 'fatal'),
        additionalData: any(named: 'additionalData'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockAnalyticsFacade.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});

    when(() => mockAppLogger.error(any(), any(), any(), any(), any()))
        .thenReturn(null);

    when(() => mockTalker.handle(any(), any(), any())).thenReturn(null);
  });

  group('AuthErrorHandler - Parameterized HTTP Status Code Tests', () {
    // Test parameters: status code, expected message fragment, analytics event name
    final httpErrorTestCases = [
      // 4xx errors
      (400, 'server couldn\'t process your request', 'http_error_400'),
      (401, 'Invalid username or password', 'http_error_401'),
      (403, 'don\'t have permission', 'http_error_403'),
      (404, 'not found', 'http_error_404'),
      (422, 'validation errors', 'http_error_422'),
      // 5xx errors
      (500, 'server encountered an error', 'http_error_500'),
      (501, 'server encountered an error', 'http_error_501'),
      (502, 'server encountered an error', 'http_error_502'),
      (503, 'server encountered an error', 'http_error_503'),
      // Other codes
      (418, 'unexpected server error', 'http_error_418'), // I'm a teapot :)
      (429, 'unexpected server error', 'http_error_429'),
    ];

    for (final testCase in httpErrorTestCases) {
      final statusCode = testCase.$1;
      final expectedMessageFragment = testCase.$2;
      final expectedEventName = testCase.$3;

      test('handles $statusCode status code correctly', () async {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: statusCode,
          ),
        );

        // Act
        final message = await errorHandler.processError(
          dioError,
          StackTrace.current,
          context: 'Login',
        );

        // Assert
        expect(
          message,
          contains(expectedMessageFragment),
          reason:
              'Status code $statusCode should produce a message containing: $expectedMessageFragment',
        );

        verify(() => mockAnalyticsFacade.trackError(any(), any())).called(1);
        verify(
          () =>
              mockAnalyticsFacade.logEvent(expectedEventName, parameters: any(named: 'parameters')),
        ).called(1);
      });
    }
  });

  group('AuthErrorHandler - Parameterized DioExceptionType Tests', () {
    // Test parameters: exception type, expected message fragment, error type
    final dioExceptionTestCases = [
      (DioExceptionType.connectionTimeout, 'Connection timed out', 'network_error'),
      (DioExceptionType.sendTimeout, 'Unable to send data', 'network_error'),
      (DioExceptionType.receiveTimeout, 'taking too long to respond', 'network_error'),
      (DioExceptionType.connectionError, 'Cannot connect to the server', 'network_error'),
      (DioExceptionType.badCertificate, 'network error', 'network_error'),
      (DioExceptionType.badResponse, 'network error', 'network_error'),
      (DioExceptionType.cancel, 'network error', 'network_error'),
      (DioExceptionType.unknown, 'network error', 'network_error'),
    ];

    for (final testCase in dioExceptionTestCases) {
      final exceptionType = testCase.$1;
      final expectedMessageFragment = testCase.$2;
      final errorType = testCase.$3;

      test('handles ${exceptionType.toString()} correctly', () async {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: exceptionType,
        );

        // Act
        final message = await errorHandler.processError(
          dioError,
          StackTrace.current,
          context: 'Login',
        );

        // Assert
        expect(
          message,
          contains(expectedMessageFragment),
          reason:
              '${exceptionType.toString()} should produce a message containing: $expectedMessageFragment',
        );

        verify(() => mockAnalyticsFacade.trackError(any(), any())).called(1);

        // Network errors should be tracked with the appropriate error type
        expect(
          message.toLowerCase(),
          anyOf(contains('network'), contains('connect'), contains('server')),
          reason: 'Network errors should have network-related message',
        );
      });
    }
  });

  group('AuthErrorHandler - Parameterized Exception Type Tests', () {
    // Test parameters: exception factory, expected message fragment, error type
    final exceptionTestCases = [
      (() => SocketException('Connection failed'), 'Unable to connect', 'connection_error'),
      (() => HttpException('HTTP error occurred'), 'problem communicating', 'http_error'),
      (() => FormatException('Invalid format'), 'expected format', 'format_error'),
      (() => Exception('General error'), 'unexpected error', 'general_error'),
      (() => ArgumentError('Invalid argument'), 'unexpected error', 'general_error'),
      (() => StateError('Bad state'), 'unexpected error', 'general_error'),
      (() => UnsupportedError('Not supported'), 'unexpected error', 'general_error'),
      (() => TypeError(), 'unexpected error', 'general_error'),
    ];

    for (final testCase in exceptionTestCases) {
      final exceptionFactory = testCase.$1;
      final expectedMessageFragment = testCase.$2;
      final errorType = testCase.$3;

      final exception = exceptionFactory();
      final exceptionType = exception.runtimeType.toString();

      test('handles $exceptionType correctly', () async {
        // Act
        final message = await errorHandler.processError(
          exception,
          StackTrace.current,
          context: 'Login',
        );

        // Assert
        expect(
          message,
          contains(expectedMessageFragment),
          reason: '$exceptionType should produce a message containing: $expectedMessageFragment',
        );

        verify(() => mockAnalyticsFacade.trackError(errorType, any())).called(1);
      });
    }
  });

  group('AuthErrorHandler - Parameterized Response Data Tests', () {
    // Test parameters: response data, expected extracted message
    final responseDataTestCases = [
      (
        {'error_description': 'Custom error from error_description'},
        'Custom error from error_description',
      ),
      ({'message': 'Custom error from message field'}, 'Custom error from message field'),
      ({'error': 'Custom error from error field'}, 'Custom error from error field'),
      ('Plain string error message', 'Plain string error message'),
      ({'unknown_field': 'No recognizable error field'}, null), // Should use default message
      ({}, null), // Should use default message
    ];

    for (final testCase in responseDataTestCases) {
      final responseData = testCase.$1;
      final expectedMessage = testCase.$2;

      final dataDescription = responseData is Map
          ? 'Map with ${responseData.keys.join(', ')}'
          : 'String data';

      test('extracts error message correctly from $dataDescription', () async {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: responseData,
          ),
        );

        // Act
        final message = await errorHandler.processError(
          dioError,
          StackTrace.current,
          context: 'Login',
        );

        // Assert
        if (expectedMessage != null) {
          expect(
            message,
            contains(expectedMessage),
            reason: 'Should extract message from $dataDescription',
          );
        } else {
          // Should fall back to default message for the status code
          expect(
            message,
            contains('server couldn\'t process your request'),
            reason: 'Should use default message when no error message is available',
          );
        }
      });
    }
  });

  group('AuthErrorHandler - Additional Context Tests', () {
    // Test parameters: context string, context-specific data
    final contextTestCases = [
      ('Login', {'username_provided': true, 'auth_method': 'password'}),
      ('Registration', {'email_provided': true, 'has_accepted_terms': true}),
      ('PasswordReset', {'email_provided': true, 'reset_token_provided': false}),
      ('Logout', {'user_id': '12345', 'session_active': true}),
      (
        'ProfileUpdate',
        {
          'fields_updated': ['name', 'email'],
          'user_id': '12345',
        },
      ),
      ('VerseSync', {'verse_count': 5, 'last_sync_time': '2026-01-11T12:34:56Z'}),
    ];

    for (final testCase in contextTestCases) {
      final context = testCase.$1;
      final contextData = testCase.$2;

      test('includes correct context and data for $context flow', () async {
        // Arrange
        final error = Exception('Test error');

        // Act
        await errorHandler.processError(
          error,
          StackTrace.current,
          context: context,
          additionalData: contextData,
        );

        // Assert
        verify(
          () => mockAnalyticsFacade.recordError(
            any(),
            any(),
            reason: '$context failure',
            additionalData: any(
              named: 'additionalData',
              that: predicate((Map<String, dynamic> data) {
                // Check that error_context is set correctly
                if (data['error_context'] != context) return false;

                // Check that all context-specific data is included
                for (final entry in contextData.entries) {
                  if (data[entry.key] != entry.value) return false;
                }

                return true;
              }),
            ),
          ),
        ).called(1);

        // Verify the error is also tracked as an analytics event
        verify(
          () => mockAnalyticsFacade.trackError('general_error', any(that: contains(context))),
        ).called(1);
      });
    }
  });
}
