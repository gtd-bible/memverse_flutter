import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/services/analytics_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Mocks for Firebase dependencies
class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}
class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}
class MockAndroidDeviceInfo extends Mock implements AndroidDeviceInfo {}
class MockIosDeviceInfo extends Mock implements IosDeviceInfo {}
class MockWebBrowserInfo extends Mock implements WebBrowserInfo {}
class MockDeviceInfoPlugin extends Mock implements DeviceInfoPlugin {}

// Mock for AnalyticsManager (to control its Firebase dependencies)
class MockAnalyticsManager extends Mock implements AnalyticsManager {
  // We need to override the getters for analytics and crashlytics
  // These will return our specific mocks
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

  // Since AnalyticsManager's constructor calls _initializeUserProperties,
  // we need to mock that behavior or prevent it from running the real logic.
  // The simplest is to ensure the mocks are already set when its called.
  // But since we are mocking the *instance* of AnalyticsManager, its constructor won't run.
}

void main() {
  late MockFirebaseCrashlytics mockCrashlytics;
  late MockFirebaseAnalytics mockAnalytics;
  late MockAnalyticsManager mockAnalyticsManager;

  // Register fallbacks for `any()` if needed for methods with non-nullable parameters
  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    mockCrashlytics = MockFirebaseCrashlytics();
    mockAnalytics = MockFirebaseAnalytics();

    // Stub methods called by AppLogger and AnalyticsManager
    when(() => mockCrashlytics.log(any())).thenAnswer((_) async {});
    when(() => mockCrashlytics.recordError(
          any(),
          any(),
          fatal: any(named: 'fatal'),
          information: any(named: 'information'),
        )).thenAnswer((_) async {});
    when(() => mockAnalytics.logEvent(name: any(named: 'name'), parameters: any(named: 'parameters'))).thenAnswer((_) async {});
    when(() => mockAnalytics.setUserProperty(name: any(named: 'name'), value: any(named: 'value'))).thenAnswer((_) async {});

    // Create a mock AnalyticsManager that returns our mock Firebase instances
    mockAnalyticsManager = MockAnalyticsManager(
      analytics: mockAnalytics,
      crashlytics: mockCrashlytics,
    );

    // Replace the global singleton instance for testing
    // Store the original instance to restore it after the test
    final originalAnalyticsManagerInstance = AnalyticsManager.instance;
    AnalyticsManager.instance = mockAnalyticsManager;

    // Restore the original instance after each test
    addTearDown(() {
      AnalyticsManager.instance = originalAnalyticsManagerInstance;
    });
  });

  group('AppLogger Tests', () {
    test('AppLogger should have all logging methods', () {
      expect(() => AppLogger.t('test'), returnsNormally);
      expect(() => AppLogger.d('test'), returnsNormally);
      expect(() => AppLogger.i('test'), returnsNormally);
      expect(() => AppLogger.w('test'), returnsNormally);
      expect(() => AppLogger.e('test'), returnsNormally);

      // Verify that the underlying crashlytics.log was called for each log level
      verify(() => mockCrashlytics.log('[TRACE] test')).called(1);
      verify(() => mockCrashlytics.log('[DEBUG] test')).called(1);
      verify(() => mockCrashlytics.log('[INFO] test')).called(1);
      verify(() => mockCrashlytics.log('[WARNING] test')).called(1);
      verify(() => mockCrashlytics.log('[ERROR] test')).called(1);
    });

    test('AppLogger short form methods should exist', () {
      expect(() => AppLogger.debug('test'), returnsNormally);
      expect(() => AppLogger.info('test'), returnsNormally);
      expect(() => AppLogger.warning('test'), returnsNormally);
      expect(() => AppLogger.f('test'), returnsNormally);

      // Verify that the underlying crashlytics.log was called for each log level
      verify(() => mockCrashlytics.log('[DEBUG] test')).called(1);
      verify(() => mockCrashlytics.log('[INFO] test')).called(1);
      verify(() => mockCrashlytics.log('[WARNING] test')).called(1);
      verify(() => mockCrashlytics.log('[FATAL] test')).called(1);
    });

    test('AppLogger.error should record non-fatal error to Crashlytics and Analytics', () async {
      final error = Exception('Test Error');
      final stackTrace = StackTrace.current;
      AppLogger.error(error.toString(), error, stackTrace, true); // Removed await

      verify(() => mockCrashlytics.log('[ERROR] ${error.toString()}')).called(1);
      verify(() => mockCrashlytics.recordError(
            error,
            stackTrace,
            fatal: false,
            information: any(named: 'information'),
          )).called(1);
      verify(() => mockAnalytics.logEvent(
            name: 'non_fatal_error',
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('AppLogger.fatal should record fatal error to Crashlytics and Analytics', () async {
      final error = Exception('Fatal Error');
      final stackTrace = StackTrace.current;
      AppLogger.fatal(error.toString(), error, stackTrace); // Removed await

      verify(() => mockCrashlytics.log('[FATAL] ${error.toString()}')).called(1);
      verify(() => mockCrashlytics.recordError(
            error,
            stackTrace,
            fatal: true,
            information: any(named: 'information'),
          )).called(1);
      verify(() => mockAnalytics.logEvent(
            name: 'fatal_error',
            parameters: any(named: 'parameters'),
          )).called(1);
    });
  });
}