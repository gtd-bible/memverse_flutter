import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

// Mock dependencies
class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}

class MockAppLoggerFacade extends Mock implements AppLoggerFacade {}

class MockTalker extends Mock implements Talker {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  group('AuthErrorHandler', () {
    late AuthErrorHandler errorHandler;
    late MockAnalyticsFacade mockAnalyticsFacade;
    late MockAppLoggerFacade mockAppLoggerFacade;
    late MockTalker mockTalker;

    setUp(() {
      mockAnalyticsFacade = MockAnalyticsFacade();
      mockAppLoggerFacade = MockAppLoggerFacade();
      mockTalker = MockTalker();

      // Set up mock behavior
      when(() => mockAnalyticsFacade.trackError(any(), any())).thenAnswer((_) => Future.value());
      when(
        () => mockAnalyticsFacade.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: any(named: 'fatal'),
          additionalData: any(named: 'additionalData'),
        ),
      ).thenAnswer((_) => Future.value());
      when(
        () => mockAnalyticsFacade.logEvent(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) => Future.value());
      when(() => mockAppLoggerFacade.error(any(), any(), any(), any(), any())).thenReturn(null);
      when(() => mockTalker.handle(any(), any(), any())).thenReturn(null);

      // Create the error handler
      errorHandler = AuthErrorHandler(
        analyticsFacade: mockAnalyticsFacade,
        appLogger: mockAppLoggerFacade,
        talker: mockTalker,
      );
    });

    test('processes DioException with HTTP 401 properly', () async {
      // Arrange
      final requestOptions = RequestOptions(
        path: 'https://www.memverse.com/api/v1/auth',
        method: 'POST',
      );
      final response = Response(
        requestOptions: requestOptions,
        statusCode: 401,
        data: {'error': 'Invalid credentials'},
      );
      final dioException = DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );

      // Act
      final userMessage = await errorHandler.processError(
        dioException,
        StackTrace.current,
        context: 'Login',
      );

      // Assert
      expect(userMessage, contains('Invalid username or password'));

      // Verify Crashlytics and Analytics received the error
      verify(() => mockAnalyticsFacade.trackError('network_error', any())).called(1);
      verify(
        () => mockAnalyticsFacade.recordError(
          dioException,
          any(),
          reason: 'Login failure',
          fatal: false,
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);

      // Verify analytics event for 401 error
      verify(
        () => mockAnalyticsFacade.logEvent('http_error_401', parameters: any(named: 'parameters')),
      ).called(1);
    });

    test('processes DioException with HTTP 404 properly', () async {
      // Arrange
      final requestOptions = RequestOptions(
        path: 'https://www.memverse.com/api/v1/auth',
        method: 'POST',
      );
      final response = Response(requestOptions: requestOptions, statusCode: 404, data: null);
      final dioException = DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );

      // Act
      final userMessage = await errorHandler.processError(
        dioException,
        StackTrace.current,
        context: 'Login',
      );

      // Assert
      expect(userMessage, contains('resource was not found'));

      // Verify Crashlytics and Analytics received the error
      verify(() => mockAnalyticsFacade.trackError('network_error', any())).called(1);
      verify(
        () => mockAnalyticsFacade.recordError(
          dioException,
          any(),
          reason: 'Login failure',
          fatal: false,
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);

      // Verify analytics event for 404 error
      verify(
        () => mockAnalyticsFacade.logEvent('http_error_404', parameters: any(named: 'parameters')),
      ).called(1);
    });

    test('processes DioException with HTTP 500 properly', () async {
      // Arrange
      final requestOptions = RequestOptions(
        path: 'https://www.memverse.com/api/v1/auth',
        method: 'POST',
      );
      final response = Response(
        requestOptions: requestOptions,
        statusCode: 500,
        data: {'error': 'Internal server error'},
      );
      final dioException = DioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );

      // Act
      final userMessage = await errorHandler.processError(
        dioException,
        StackTrace.current,
        context: 'Login',
      );

      // Assert
      expect(userMessage, contains('server encountered an error'));

      // Verify Crashlytics and Analytics received the error
      verify(() => mockAnalyticsFacade.trackError('network_error', any())).called(1);
      verify(
        () => mockAnalyticsFacade.recordError(
          dioException,
          any(),
          reason: 'Login failure',
          fatal: false,
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);

      // Verify analytics event for 500 error
      verify(
        () => mockAnalyticsFacade.logEvent('http_error_500', parameters: any(named: 'parameters')),
      ).called(1);
    });

    test('processes connection timeout DioException properly', () async {
      // Arrange
      final requestOptions = RequestOptions(
        path: 'https://www.memverse.com/api/v1/auth',
        method: 'POST',
      );
      final dioException = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timed out',
      );

      // Act
      final userMessage = await errorHandler.processError(
        dioException,
        StackTrace.current,
        context: 'Login',
      );

      // Assert
      expect(userMessage, contains('Connection timed out'));

      // Verify Crashlytics and Analytics received the error
      verify(() => mockAnalyticsFacade.trackError('network_error', any())).called(1);
      verify(
        () => mockAnalyticsFacade.recordError(
          dioException,
          any(),
          reason: 'Login failure',
          fatal: false,
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);

      // No specific HTTP error event for timeouts
      verifyNever(
        () => mockAnalyticsFacade.logEvent(
          any(that: startsWith('http_error_')),
          parameters: any(named: 'parameters'),
        ),
      );
    });

    test('processes SocketException properly', () async {
      // Arrange
      final socketException = SocketException('Failed to connect to www.memverse.com');

      // Act
      final userMessage = await errorHandler.processError(
        socketException,
        StackTrace.current,
        context: 'Login',
      );

      // Assert
      expect(userMessage, contains('check your internet connection'));

      // Verify Crashlytics and Analytics received the error
      verify(() => mockAnalyticsFacade.trackError('connection_error', any())).called(1);
      verify(
        () => mockAnalyticsFacade.recordError(
          socketException,
          any(),
          reason: 'Login failure',
          fatal: false,
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);
    });

    test('processes FormatException properly', () async {
      // Arrange
      final formatException = FormatException('Unexpected character');

      // Act
      final userMessage = await errorHandler.processError(
        formatException,
        StackTrace.current,
        context: 'Login',
      );

      // Assert
      expect(userMessage, contains('not in the expected format'));

      // Verify Crashlytics and Analytics received the error
      verify(() => mockAnalyticsFacade.trackError('format_error', any())).called(1);
      verify(
        () => mockAnalyticsFacade.recordError(
          formatException,
          any(),
          reason: 'Login failure',
          fatal: false,
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);
    });

    test('processes unknown exceptions properly', () async {
      // Arrange
      final unknownException = Exception('Something went wrong');

      // Act
      final userMessage = await errorHandler.processError(
        unknownException,
        StackTrace.current,
        context: 'Login',
      );

      // Assert
      expect(userMessage, contains('unexpected error occurred'));

      // Verify Crashlytics and Analytics received the error
      verify(() => mockAnalyticsFacade.trackError('general_error', any())).called(1);
      verify(
        () => mockAnalyticsFacade.recordError(
          unknownException,
          any(),
          reason: 'Login failure',
          fatal: false,
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);
    });

    test('includes additional data in error reports', () async {
      // Arrange
      final exception = Exception('Test error');
      final additionalData = {
        'user_id': '12345',
        'screen': 'login',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Act
      await errorHandler.processError(
        exception,
        StackTrace.current,
        context: 'TestContext',
        additionalData: additionalData,
      );

      // Assert
      verify(
        () => mockAnalyticsFacade.recordError(
          exception,
          any(),
          reason: 'TestContext failure',
          fatal: false,
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);

      verify(() => mockAppLoggerFacade.error(any(), any(), any(), any(), any())).called(1);
    });
  });
}
