import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';

class MockAppLoggerFacade extends Mock implements AppLoggerFacade {}

class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}

void main() {
  group('AuthErrorHandler - Common Scenarios', () {
    late AuthErrorHandler errorHandler;
    late MockAppLoggerFacade mockLogger;
    late MockAnalyticsFacade mockAnalytics;

    setUp(() {
      mockLogger = MockAppLoggerFacade();
      mockAnalytics = MockAnalyticsFacade();

      when(() => mockLogger.error(any(), any(), any(), any(), any())).thenReturn(null);
      when(() => mockLogger.w(any())).thenReturn(null);
      when(() => mockLogger.i(any())).thenReturn(null);
      when(
        () => mockAnalytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: any(named: 'fatal'),
          additionalData: any(named: 'additionalData'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockAnalytics.trackError(any(), any())).thenAnswer((_) async {});

      errorHandler = AuthErrorHandler(appLogger: mockLogger, analyticsFacade: mockAnalytics);
    });

    test('handles common OAuth 2.0 error responses correctly', () async {
      // OAuth errors typically come as structured JSON responses
      final oauthErrorData = {
        'error': 'invalid_grant',
        'error_description': 'The provided authorization grant is invalid',
      };

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/oauth/token'),
        response: Response(
          requestOptions: RequestOptions(path: '/oauth/token'),
          statusCode: 400,
          data: oauthErrorData,
        ),
        type: DioExceptionType.badResponse,
      );

      final errorMessage = await errorHandler.processError(
        dioError,
        StackTrace.current,
        context: 'Login',
      );

      // Should extract the readable error description from the response
      expect(errorMessage, contains('invalid'));
      expect(errorMessage, contains('authorization grant'));

      // Verify error was logged and tracked
      verify(() => mockLogger.error(any(), any(), any(), any(), any())).called(1);
      verify(
        () => mockAnalytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);
    });

    test('handles form validation error responses correctly', () async {
      // Form validation errors typically come as structured JSON responses
      final validationErrorData = {
        'errors': {
          'username': ['Username is already taken'],
          'email': ['Email format is invalid'],
        },
      };

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/users'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/users'),
          statusCode: 422,
          data: validationErrorData,
        ),
        type: DioExceptionType.badResponse,
      );

      final errorMessage = await errorHandler.processError(
        dioError,
        StackTrace.current,
        context: 'Registration',
      );

      // Should extract validation errors from the response
      expect(errorMessage, contains('Username is already taken'));
      expect(errorMessage, contains('Email format is invalid'));

      // Verify error was logged and tracked
      verify(() => mockLogger.error(any(), any(), any(), any(), any())).called(1);
      verify(
        () => mockAnalytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);
    });

    test('handles error with additional context data correctly', () async {
      final error = Exception('Test error');
      final additionalData = {
        'username': 'test@example.com',
        'timestamp': DateTime.now().toString(),
        'screen': 'login',
      };

      final errorMessage = await errorHandler.processError(
        error,
        StackTrace.current,
        context: 'Authentication',
        additionalData: additionalData,
      );

      expect(errorMessage, contains('Test error'));

      // Verify error was logged with the additional data
      verify(() => mockLogger.error(any(), any(), any(), any(), any())).called(1);

      // Verify error was tracked with the additional data
      verify(
        () => mockAnalytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: false,
          additionalData: additionalData,
        ),
      ).called(1);
    });

    test('handles error with custom error message overriding', () async {
      // Simulate a common error that we want to make more user-friendly
      final error = DioException(
        requestOptions: RequestOptions(path: '/api'),
        error: 'Connection refused',
        type: DioExceptionType.connectionError,
      );

      final errorMessage = await errorHandler.processError(
        error,
        StackTrace.current,
        context: 'Login',
      );

      // Should return a user-friendly message
      expect(errorMessage, contains('connect'));
      expect(errorMessage, contains('internet'));

      // Should not contain the technical details
      expect(errorMessage.contains('Connection refused'), isFalse);

      // Verify error was logged and tracked
      verify(() => mockLogger.error(any(), any(), any(), any(), any())).called(1);
      verify(
        () => mockAnalytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);
    });

    test('handles nested errors inside parent exceptions', () async {
      // Create a nested error structure
      final innerError = FormatException('Invalid JSON format');
      final outerError = Exception('API error: ${innerError.toString()}');

      final errorMessage = await errorHandler.processError(
        outerError,
        StackTrace.current,
        context: 'Data parsing',
      );

      // Should extract meaningful message
      expect(errorMessage, contains('API error'));
      expect(errorMessage, contains('Invalid JSON format'));

      // Verify error was logged and tracked
      verify(() => mockLogger.error(any(), any(), any(), any(), any())).called(1);
      verify(
        () => mockAnalytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          additionalData: any(named: 'additionalData'),
        ),
      ).called(1);
    });
  });
}
