import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/monitoring/crashlytics_talker_observer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

class MockTalkerError extends Mock implements TalkerError {
  @override
  final dynamic error = Exception('Test error');
  
  @override
  final StackTrace stackTrace = StackTrace.current;
  
  @override
  final String message = 'Test error message';
  
  @override
  final String title = 'ERROR';
  
  @override
  String generateTextMessage() => 'Test error message';
}

class MockTalkerException extends Mock implements TalkerException {
  @override
  final dynamic exception = Exception('Test exception');
  
  @override
  final StackTrace stackTrace = StackTrace.current;
  
  @override
  final String message = 'Test exception message';
  
  @override
  final String title = 'EXCEPTION';
  
  @override
  String generateTextMessage() => 'Test exception message';
}

class MockTalkerLog extends Mock implements TalkerLog {
  @override
  final String message = 'Test log message';
  
  @override
  final String title = 'LOG';
  
  @override
  String generateTextMessage() => 'Test log message';
}

class TestCrashlyticsTalkerObserver extends CrashlyticsTalkerObserver {
  TestCrashlyticsTalkerObserver({super.enableInDebugMode, required this.mockCrashlytics});

  final MockFirebaseCrashlytics mockCrashlytics;

  @override
  FirebaseCrashlytics get _crashlytics => mockCrashlytics;
}

void main() {
  late MockFirebaseCrashlytics mockCrashlytics;
  late CrashlyticsTalkerObserver observer;
  
  setUp(() {
    mockCrashlytics = MockFirebaseCrashlytics();
    observer = TestCrashlyticsTalkerObserver(
      enableInDebugMode: true,
      mockCrashlytics: mockCrashlytics,
    );
    
    // Setup common mocks
    when(() => mockCrashlytics.recordError(
      any(), any(), 
      reason: any(named: 'reason'),
      fatal: any(named: 'fatal'),
      printDetails: any(named: 'printDetails'),
      information: any(named: 'information'),
    )).thenAnswer((_) async {});
    
    when(() => mockCrashlytics.log(any())).thenAnswer((_) async {});
  });
  
  group('CrashlyticsTalkerObserver', () {
    test('onError records error to Crashlytics', () {
      // Arrange
      final mockError = MockTalkerError();
      
      // Act
      observer.onError(mockError);
      
      // Assert
      verify(() => mockCrashlytics.recordError(
        mockError.error,
        mockError.stackTrace,
        reason: mockError.message,
        fatal: any(named: 'fatal'),
        printDetails: any(named: 'printDetails'),
        information: any(named: 'information'),
      )).called(1);
      
      verify(() => mockCrashlytics.log('[${mockError.title}] ${mockError.generateTextMessage()}')).called(1);
    });
    
    test('onException records exception to Crashlytics', () {
      // Arrange
      final mockException = MockTalkerException();
      
      // Act
      observer.onException(mockException);
      
      // Assert
      verify(() => mockCrashlytics.recordError(
        mockException.exception,
        mockException.stackTrace,
        reason: mockException.message,
        fatal: any(named: 'fatal'),
        printDetails: any(named: 'printDetails'),
        information: any(named: 'information'),
      )).called(1);
      
      verify(() => mockCrashlytics.log('[${mockException.title}] ${mockException.generateTextMessage()}')).called(1);
    });
    
    test('onLog adds logs for errors and exceptions but not regular logs', () {
      // Arrange
      final mockError = MockTalkerError();
      final mockException = MockTalkerException();
      final mockLog = MockTalkerLog();
      
      // Act
      observer.onLog(mockError);
      observer.onLog(mockException);
      observer.onLog(mockLog);
      
      // Assert
      verify(() => mockCrashlytics.log('[${mockError.title}] ${mockError.generateTextMessage()}')).called(1);
      verify(() => mockCrashlytics.log('[${mockException.title}] ${mockException.generateTextMessage()}')).called(1);
      
      // Regular logs should not be sent to Crashlytics
      verifyNever(() => mockCrashlytics.log('[${mockLog.title}] ${mockLog.generateTextMessage()}'));
    });
    
    test('disables reporting in debug mode by default', () {
      // Arrange
      // Set enableInDebugMode to false and make sure we're in debug mode
      debugDefaultTargetPlatformOverride = TargetPlatform.android; // For kDebugMode detection
      final debugObserver = TestCrashlyticsTalkerObserver(
        enableInDebugMode: false,
        mockCrashlytics: mockCrashlytics,
      );
      final mockError = MockTalkerError();
      
      // Act
      debugObserver.onError(mockError);
      
      // Assert
      // Should not call Crashlytics when in debug mode with enableInDebugMode=false
      verifyNever(() => mockCrashlytics.recordError(any(), any(), reason: any(named: 'reason')));
      verifyNever(() => mockCrashlytics.log(any()));
      
      // Restore default
      debugDefaultTargetPlatformOverride = null;
    });
  });
}