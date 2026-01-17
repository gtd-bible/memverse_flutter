import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_debugger.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mocktail/mocktail.dart';

// Mock dependencies
class MockAuthErrorHandler extends Mock implements AuthErrorHandler {}

class MockAppLoggerFacade extends Mock implements AppLoggerFacade {}

void main() {
  late AuthErrorDebugger authErrorDebugger;
  late MockAuthErrorHandler mockErrorHandler;
  late MockAppLoggerFacade mockAppLogger;

  setUp(() {
    mockErrorHandler = MockAuthErrorHandler();
    mockAppLogger = MockAppLoggerFacade();
    authErrorDebugger = AuthErrorDebugger(errorHandler: mockErrorHandler, appLogger: mockAppLogger);
  });

  group('AuthErrorDebugger', () {
    const testContext = 'TestContext';
    const testAdditionalData = {'test': 'value'};
    const expectedUserMessage = 'Test user message';

    test(
      'simulateHttpError passes DioException with correct status code to error handler',
      () async {
        // Arrange
        when(
          () => mockErrorHandler.processError(
            any(that: isA<DioException>()),
            any(),
            context: testContext,
            additionalData: testAdditionalData,
          ),
        ).thenAnswer((_) async => expectedUserMessage);

        // Act
        final result = await authErrorDebugger.simulateHttpError(
          statusCode: 401,
          responseData: {'error': 'Invalid credentials'},
          context: testContext,
          additionalData: testAdditionalData,
        );

        // Assert
        verify(
          () => mockErrorHandler.processError(
            any(that: isA<DioException>()),
            any(),
            context: testContext,
            additionalData: testAdditionalData,
          ),
        ).called(1);

        expect(result, equals(expectedUserMessage));
      },
    );

    test('simulateNetworkError passes DioException with correct type to error handler', () async {
      // Arrange
      when(
        () => mockErrorHandler.processError(
          any(that: isA<DioException>()),
          any(),
          context: testContext,
          additionalData: testAdditionalData,
        ),
      ).thenAnswer((_) async => expectedUserMessage);

      // Act
      final result = await authErrorDebugger.simulateNetworkError(
        type: DioExceptionType.connectionTimeout,
        context: testContext,
        additionalData: testAdditionalData,
      );

      // Assert
      verify(
        () => mockErrorHandler.processError(
          any(that: isA<DioException>()),
          any(),
          context: testContext,
          additionalData: testAdditionalData,
        ),
      ).called(1);

      expect(result, equals(expectedUserMessage));
    });

    test('simulateSocketException passes SocketException to error handler', () async {
      // Arrange
      when(
        () => mockErrorHandler.processError(
          any(that: isA<SocketException>()),
          any(),
          context: testContext,
          additionalData: testAdditionalData,
        ),
      ).thenAnswer((_) async => expectedUserMessage);

      // Act
      final result = await authErrorDebugger.simulateSocketException(
        message: 'Connection refused',
        context: testContext,
        additionalData: testAdditionalData,
      );

      // Assert
      verify(
        () => mockErrorHandler.processError(
          any(that: isA<SocketException>()),
          any(),
          context: testContext,
          additionalData: testAdditionalData,
        ),
      ).called(1);

      expect(result, equals(expectedUserMessage));
    });

    test('simulateFormatException passes FormatException to error handler', () async {
      // Arrange
      when(
        () => mockErrorHandler.processError(
          any(that: isA<FormatException>()),
          any(),
          context: testContext,
          additionalData: testAdditionalData,
        ),
      ).thenAnswer((_) async => expectedUserMessage);

      // Act
      final result = await authErrorDebugger.simulateFormatException(
        message: 'Invalid format',
        context: testContext,
        additionalData: testAdditionalData,
      );

      // Assert
      verify(
        () => mockErrorHandler.processError(
          any(that: isA<FormatException>()),
          any(),
          context: testContext,
          additionalData: testAdditionalData,
        ),
      ).called(1);

      expect(result, equals(expectedUserMessage));
    });

    test('runComprehensiveTest simulates all error types and logs completion', () async {
      // Arrange
      when(
        () => mockErrorHandler.processError(
          any(),
          any(),
          context: any(named: 'context'),
          additionalData: any(named: 'additionalData'),
        ),
      ).thenAnswer((_) async => 'Test message');

      when(() => mockAppLogger.info(any(), any(), any())).thenReturn(null);

      // Act
      await authErrorDebugger.runComprehensiveTest();

      // Assert - verify that error handler was called multiple times
      verify(
        () => mockErrorHandler.processError(
          any(),
          any(),
          context: any(named: 'context'),
          additionalData: any(named: 'additionalData'),
        ),
      ).called(greaterThan(10)); // Multiple error types tested

      // Verify completion logged
      verify(() => mockAppLogger.info(any(that: contains('complete')), any(), any())).called(1);
    });

  });
}
