import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/analytics_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

/// A testable version of AnalyticsManager that allows overriding Firebase instances
class TestableAnalyticsManager extends AnalyticsManager {
  TestableAnalyticsManager._() : super._();

  static final TestableAnalyticsManager instance = TestableAnalyticsManager._();

  MockFirebaseAnalytics? _mockAnalytics;
  MockFirebaseCrashlytics? _mockCrashlytics;

  @override
  FirebaseAnalytics get analytics => _mockAnalytics ?? super.analytics;

  @override
  FirebaseCrashlytics get crashlytics => _mockCrashlytics ?? super.crashlytics;

  void setMocks({MockFirebaseAnalytics? analytics, MockFirebaseCrashlytics? crashlytics}) {
    _mockAnalytics = analytics;
    _mockCrashlytics = crashlytics;
  }
}

void main() {
  late TestableAnalyticsManager analyticsManager;
  late MockFirebaseAnalytics mockAnalytics;
  late MockFirebaseCrashlytics mockCrashlytics;

  setUp(() {
    mockAnalytics = MockFirebaseAnalytics();
    mockCrashlytics = MockFirebaseCrashlytics();

    // Create a test instance of AnalyticsManager with our mocks
    analyticsManager = TestableAnalyticsManager.instance;
    analyticsManager.setMocks(analytics: mockAnalytics, crashlytics: mockCrashlytics);

    // Register fallback values for methods that need non-null arguments
    registerFallbackValue(false);
    registerFallbackValue('');
    registerFallbackValue(<String, Object>{});
    registerFallbackValue(StackTrace.empty);
    registerFallbackValue(FlutterErrorDetails(exception: Exception()));
  });

  group('AnalyticsManager', () {
    test(
      'initialize calls setAnalyticsCollectionEnabled and setCrashlyticsCollectionEnabled',
      () async {
        // Arrange
        when(() => mockAnalytics.setAnalyticsCollectionEnabled(any())).thenAnswer((_) async {});
        when(() => mockCrashlytics.setCrashlyticsCollectionEnabled(any())).thenAnswer((_) async {});
        when(
          () => mockAnalytics.setUserProperty(
            name: any(named: 'name'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockCrashlytics.setCustomKey(any(), any())).thenAnswer((_) async {});
        when(
          () => mockAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await analyticsManager.initialize();

        // Assert
        verify(() => mockAnalytics.setAnalyticsCollectionEnabled(any())).called(1);
        verify(() => mockCrashlytics.setCrashlyticsCollectionEnabled(any())).called(1);
        verify(
          () => mockAnalytics.logEvent(
            name: 'app_configuration',
            parameters: any(named: 'parameters'),
          ),
        ).called(1);
      },
    );

    test('setUserId sets user ID for analytics and crashlytics when ID provided', () async {
      // Arrange
      const userId = 'test-user-123';
      when(() => mockAnalytics.setUserId(id: any(named: 'id'))).thenAnswer((_) async {});
      when(() => mockCrashlytics.setUserIdentifier(any())).thenAnswer((_) async {});

      // Act
      await analyticsManager.setUserId(userId);

      // Assert
      verify(() => mockAnalytics.setUserId(id: userId)).called(1);
      verify(() => mockCrashlytics.setUserIdentifier(userId)).called(1);
    });

    test('setUserId clears user ID for analytics and crashlytics when null ID provided', () async {
      // Arrange
      when(() => mockAnalytics.setUserId(id: any(named: 'id'))).thenAnswer((_) async {});
      when(() => mockCrashlytics.setUserIdentifier(any())).thenAnswer((_) async {});

      // Act
      await analyticsManager.setUserId(null);

      // Assert
      verify(() => mockAnalytics.setUserId(id: null)).called(1);
      verify(() => mockCrashlytics.setUserIdentifier('')).called(1);
    });

    test('recordNonFatalError sets custom keys and records error to crashlytics', () {
      // Arrange
      final testError = Exception('Test error');
      final stackTrace = StackTrace.current;
      final customParameters = {'message': 'Test error message'};

      when(() => mockCrashlytics.setCustomKey(any(), any())).thenAnswer((_) async {});
      when(
        () => mockCrashlytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: any(named: 'fatal'),
          printDetails: any(named: 'printDetails'),
          information: any(named: 'information'),
        ),
      ).thenAnswer((_) async {});

      // Act
      analyticsManager.recordNonFatalError(
        testError,
        stackTrace,
        customParameters: customParameters,
      );

      // Assert
      verify(() => mockCrashlytics.setCustomKey('message', 'Test error message')).called(1);
      verify(
        () => mockCrashlytics.recordError(
          testError,
          stackTrace,
          reason: 'Test error message',
          fatal: false,
        ),
      ).called(1);
    });

    test('recordFatalError sets custom keys and records error as fatal to crashlytics', () {
      // Arrange
      final testError = Exception('Fatal error');
      final stackTrace = StackTrace.current;
      final customParameters = {'message': 'Fatal error message'};

      when(() => mockCrashlytics.setCustomKey(any(), any())).thenAnswer((_) async {});
      when(
        () => mockCrashlytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: any(named: 'fatal'),
          printDetails: any(named: 'printDetails'),
          information: any(named: 'information'),
        ),
      ).thenAnswer((_) async {});

      // Act
      analyticsManager.recordFatalError(testError, stackTrace, customParameters: customParameters);

      // Assert
      verify(() => mockCrashlytics.setCustomKey('message', 'Fatal error message')).called(1);
      verify(
        () => mockCrashlytics.recordError(
          testError,
          stackTrace,
          reason: 'Fatal error message',
          fatal: true,
        ),
      ).called(1);
    });

    test('logEvent converts parameters to required Firebase type', () async {
      // Arrange
      const eventName = 'test_event';
      final parameters = <String, dynamic>{
        'string_value': 'test',
        'int_value': 123,
        'bool_value': true,
        'double_value': 1.23,
      };

      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsManager.logEvent(eventName, parameters);

      // Assert
      verify(
        () => mockAnalytics.logEvent(
          name: eventName,
          parameters: any(named: 'parameters'),
        ),
      ).called(1);
    });

    test('logScreenView calls Firebase Analytics logScreenView', () async {
      // Arrange
      when(
        () => mockAnalytics.logScreenView(
          screenName: any(named: 'screenName'),
          screenClass: any(named: 'screenClass'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsManager.logScreenView('TestScreen', 'TestClass');

      // Assert
      verify(
        () => mockAnalytics.logScreenView(screenName: 'TestScreen', screenClass: 'TestClass'),
      ).called(1);
    });
  });
}
