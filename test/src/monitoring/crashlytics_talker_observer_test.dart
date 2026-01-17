import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/monitoring/analytics_client.dart';
import 'package:mini_memverse/src/monitoring/crashlytics_talker_observer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

class MockAnalyticsClient extends Mock implements AnalyticsClient {}

void main() {
  late CrashlyticsTalkerObserver observer;
  late MockAnalyticsClient mockAnalyticsClient;

  setUp(() {
    mockAnalyticsClient = MockAnalyticsClient();
    observer = CrashlyticsTalkerObserver(analyticsClient: mockAnalyticsClient);
  });

  group('CrashlyticsTalkerObserver', () {
    test('onError calls analytics client in release mode', () async {
      // Enable release mode for this test
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      kDebugMode = false;

      // Arrange
      final error = TalkerError(Exception('Test error'));

      when(
        () => mockAnalyticsClient.logEvent(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async {});
      when(() => mockAnalyticsClient.trackError(any(), any())).thenAnswer((_) async {});

      // Act
      observer.onError(error);

      // Assert
      verify(
        () => mockAnalyticsClient.logEvent('talker_error', parameters: any(named: 'parameters')),
      ).called(1);
      verify(() => mockAnalyticsClient.trackError('talker_error', any())).called(1);

      // Reset
      debugDefaultTargetPlatformOverride = null;
      kDebugMode = true;
    });

    test('onError skips reporting in debug mode by default', () async {
      // Arrange
      final error = TalkerError(Exception('Test error'));

      // Act
      observer.onError(error);

      // Assert - should not call analytics client
      verifyNever(() => mockAnalyticsClient.logEvent(any(), parameters: any(named: 'parameters')));
      verifyNever(() => mockAnalyticsClient.trackError(any(), any()));
    });

    test('onException calls analytics client in release mode', () async {
      // Enable release mode for this test
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      kDebugMode = false;

      // Arrange
      final exception = TalkerException(Exception('Test exception'));

      when(
        () => mockAnalyticsClient.logEvent(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async {});
      when(() => mockAnalyticsClient.trackError(any(), any())).thenAnswer((_) async {});

      // Act
      observer.onException(exception);

      // Assert
      verify(
        () =>
            mockAnalyticsClient.logEvent('talker_exception', parameters: any(named: 'parameters')),
      ).called(1);
      verify(() => mockAnalyticsClient.trackError('talker_exception', any())).called(1);

      // Reset
      debugDefaultTargetPlatformOverride = null;
      kDebugMode = true;
    });

    test('onException skips reporting in debug mode by default', () async {
      // Arrange
      final exception = TalkerException(Exception('Test exception'));

      // Act
      observer.onException(exception);

      // Assert - should not call analytics client
      verifyNever(() => mockAnalyticsClient.logEvent(any(), parameters: any(named: 'parameters')));
      verifyNever(() => mockAnalyticsClient.trackError(any(), any()));
    });

    test('enableInDebugMode allows reporting in debug mode', () async {
      // Arrange
      final observerWithDebugEnabled = CrashlyticsTalkerObserver(
        analyticsClient: mockAnalyticsClient,
        enableInDebugMode: true,
      );

      final error = TalkerError(Exception('Test error'));

      when(
        () => mockAnalyticsClient.logEvent(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async {});
      when(() => mockAnalyticsClient.trackError(any(), any())).thenAnswer((_) async {});

      // Act
      observerWithDebugEnabled.onError(error);

      // Assert
      verify(
        () => mockAnalyticsClient.logEvent('talker_error', parameters: any(named: 'parameters')),
      ).called(1);
      verify(() => mockAnalyticsClient.trackError('talker_error', any())).called(1);
    });
  });
}
