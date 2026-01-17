import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/services/analytics_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode

// Mocks for dependencies
class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}
class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}
class MockLogger extends Mock implements Logger {}

// Mock for AnalyticsManager
class MockAnalyticsManager extends Mock implements AnalyticsManager {
  @override
  final FirebaseAnalytics analytics;
  @override
  final FirebaseCrashlytics crashlytics;

  MockAnalyticsManager({
    required this.analytics,
    required this.crashlytics,
  });

  @override
  Future<void> recordNonFatalError(
    dynamic error,
    StackTrace? stack, {
    Map<String, Object?>? customParameters,
    Map<String, Object?>? analyticsAttributes,
  }) async => Future.value();

  @override
  Future<void> recordFatalError(
    dynamic error,
    StackTrace? stack, {
    Map<String, Object?>? customParameters,
    Map<String, Object?>? analyticsAttributes,
  }) async => Future.value();

  @override
  Future<void> logEvent(String eventName, Map<String, Object?>? parameters) async => Future.value();
}

void main() {
  late MockFirebaseCrashlytics mockCrashlytics;
  late MockFirebaseAnalytics mockAnalytics;
  late MockAnalyticsManager mockAnalyticsManager;
  late MockLogger mockLogger;

  // Store original instances globally to restore later
  late Logger originalAppLogger;
  late AnalyticsManager originalAnalyticsManager;

  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
    registerFallbackValue(<Object>[]); // Fallback for Iterable<Object>
    registerFallbackValue(<String, Object?>{}); // Fallback for Map<String, Object?>
    registerFallbackValue(''); // Fallback for String (for log message)
    registerFallbackValue(null); // Fallback for dynamic/nullable error/stacktrace

    // Initialize mocks
    mockCrashlytics = MockFirebaseCrashlytics();
    mockAnalytics = MockFirebaseAnalytics();
    mockLogger = MockLogger();
    mockAnalyticsManager = MockAnalyticsManager(
      analytics: mockAnalytics,
      crashlytics: mockCrashlytics,
    );

    // Save original instances (if they were already initialized)
    originalAppLogger = AppLogger.logger;
    originalAnalyticsManager = AnalyticsManager.instance; // This might trigger the real constructor

    // Inject mocks as early as possible (before any test runs)
    AppLogger.logger = mockLogger;
    AnalyticsManager.instance = mockAnalyticsManager;

    // Stub FirebaseCrashlytics methods
    when(() => mockCrashlytics.log(any())).thenAnswer((_) async => Future.value());
    when(() => mockCrashlytics.recordError(
          any(),
          any(),
          fatal: any(named: 'fatal'),
          information: any(named: 'information'),
        )).thenAnswer((_) async => Future.value());

    // Stub FirebaseAnalytics methods
    when(() => mockAnalytics.logEvent(name: any(named: 'name'), parameters: any(named: 'parameters'))).thenAnswer((_) async => Future.value());
    when(() => mockAnalytics.setUserProperty(name: any(named: 'name'), value: any(named: 'value'))).thenAnswer((_) async => Future.value());

    // Stub Logger methods (all levels)
    when(() => mockLogger.t(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).thenAnswer((_) {});
    when(() => mockLogger.d(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).thenAnswer((_) {});
    when(() => mockLogger.i(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).thenAnswer((_) {});
    when(() => mockLogger.w(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).thenAnswer((_) {});
    when(() => mockLogger.e(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).thenAnswer((_) {});
    when(() => mockLogger.f(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).thenAnswer((_) {});
  });

  tearDownAll(() {
    // Restore original instances after all tests are done
    AppLogger.logger = originalAppLogger;
    AnalyticsManager.instance = originalAnalyticsManager;
  });

  group('AppLogger Tests', () {
    test('AppLogger should have all logging methods', () {
      AppLogger.t('test');
      AppLogger.d('test');
      AppLogger.i('test');
      AppLogger.w('test');
      AppLogger.e('test');

      // Verify that the underlying mockLogger was called
      verify(() => mockLogger.t('test', error: null, stackTrace: null)).called(1);
      verify(() => mockLogger.d('test', error: null, stackTrace: null)).called(1);
      verify(() => mockLogger.i('test', error: null, stackTrace: null)).called(1);
      verify(() => mockLogger.w('test', error: null, stackTrace: null)).called(1);
      verify(() => mockLogger.e('test', error: null, stackTrace: null)).called(1);

      // Verify that the underlying mockCrashlytics.log was called
      verify(() => mockCrashlytics.log('[TRACE] test')).called(1);
      verify(() => mockCrashlytics.log('[DEBUG] test')).called(1);
      verify(() => mockCrashlytics.log('[INFO] test')).called(1);
      verify(() => mockCrashlytics.log('[WARNING] test')).called(1);
      verify(() => mockCrashlytics.log('[ERROR] test')).called(1);
    });

    test('AppLogger short form methods should exist', () {
      AppLogger.debug('test');
      AppLogger.info('test');
      AppLogger.warning('test');
      AppLogger.f('test');

      // Verify that the underlying mockLogger was called
      verify(() => mockLogger.d('test', error: null, stackTrace: null)).called(1);
      verify(() => mockLogger.i('test', error: null, stackTrace: null)).called(1);
      verify(() => mockLogger.w('test', error: null, stackTrace: null)).called(1);
      verify(() => mockLogger.f('test', error: null, stackTrace: null)).called(1);

      // Verify that the underlying mockCrashlytics.log was called
      verify(() => mockCrashlytics.log('[DEBUG] test')).called(1);
      verify(() => mockCrashlytics.log('[INFO] test')).called(1);
      verify(() => mockCrashlytics.log('[WARNING] test')).called(1);
      verify(() => mockCrashlytics.log('[FATAL] test')).called(1);
    });

    test('AppLogger.error should record non-fatal error to Crashlytics and Analytics', () async {
      final error = Exception('Test Error');
      final stackTrace = StackTrace.current;
      AppLogger.error(error.toString(), error, stackTrace, true);

      verify(() => mockLogger.e(error.toString(), error: error, stackTrace: stackTrace)).called(1);
      verify(() => mockCrashlytics.log('[ERROR] ${error.toString()}')).called(1);
      verify(() => mockAnalyticsManager.recordNonFatalError(
            error,
            stackTrace,
            customParameters: any(), // Corrected named argument matching
            analyticsAttributes: any(), // Corrected named argument matching
          )).called(1);
    });

    test('AppLogger.fatal should record fatal error to Crashlytics and Analytics', () async {
      final error = Exception('Fatal Error');
      final stackTrace = StackTrace.current;
      AppLogger.fatal(error.toString(), error, stackTrace);

      verify(() => mockLogger.f(error.toString(), error: error, stackTrace: stackTrace)).called(1);
      verify(() => mockCrashlytics.log('[FATAL] ${error.toString()}')).called(1);
      verify(() => mockAnalyticsManager.recordFatalError(
            error,
            stackTrace,
            customParameters: any(), // Corrected named argument matching
            analyticsAttributes: any(), // Corrected named argument matching
          )).called(1);
    });
  });
}