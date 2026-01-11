import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/monitoring/firebase_analytics_client.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  late MockFirebaseAnalytics mockAnalytics;
  late FirebaseAnalyticsClient analyticsClient;

  setUp(() {
    mockAnalytics = MockFirebaseAnalytics();
    analyticsClient = FirebaseAnalyticsClient(mockAnalytics);

    // Register fallbacks for common parameter types
    registerFallbackValue(<String, Object>{}); // For parameters in logEvent
    registerFallbackValue(''); // For various string parameters
  });

  group('FirebaseAnalyticsClient', () {
    test('trackLogin calls logLogin on Firebase Analytics', () async {
      // Arrange
      when(() => mockAnalytics.logLogin()).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackLogin();

      // Assert
      verify(() => mockAnalytics.logLogin()).called(1);
    });

    test('trackLogout logs custom logout event', () async {
      // Arrange
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackLogout();

      // Assert
      verify(() => mockAnalytics.logEvent(name: 'logout', parameters: null)).called(1);
    });

    test('trackSignUp calls logSignUp on Firebase Analytics', () async {
      // Arrange
      when(
        () => mockAnalytics.logSignUp(signUpMethod: any(named: 'signUpMethod')),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackSignUp();

      // Assert
      verify(() => mockAnalytics.logSignUp(signUpMethod: 'email')).called(1);
    });

    test('trackVerseSessionStarted logs custom verse_session_started event', () async {
      // Arrange
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackVerseSessionStarted();

      // Assert
      verify(
        () => mockAnalytics.logEvent(name: 'verse_session_started', parameters: null),
      ).called(1);
    });

    test('trackVerseSessionCompleted logs event with verse count parameter', () async {
      // Arrange
      const verseCount = 5;
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackVerseSessionCompleted(verseCount);

      // Assert
      verify(
        () => mockAnalytics.logEvent(
          name: 'verse_session_completed',
          parameters: {'verse_count': verseCount},
        ),
      ).called(1);
    });

    test('trackVerseAdded logs custom verse_added event', () async {
      // Arrange
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackVerseAdded();

      // Assert
      verify(() => mockAnalytics.logEvent(name: 'verse_added', parameters: null)).called(1);
    });

    test('trackVerseSearch calls logSearch on Firebase Analytics', () async {
      // Arrange
      const query = 'John 3:16';
      when(
        () => mockAnalytics.logSearch(searchTerm: any(named: 'searchTerm')),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackVerseSearch(query);

      // Assert
      verify(() => mockAnalytics.logSearch(searchTerm: query)).called(1);
    });

    test('trackVerseRated logs event with rating parameter', () async {
      // Arrange
      const rating = 4;
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackVerseRated(rating);

      // Assert
      verify(
        () => mockAnalytics.logEvent(name: 'verse_rated', parameters: {'rating': rating}),
      ).called(1);
    });

    test('trackDashboardView calls logScreenView on Firebase Analytics', () async {
      // Arrange
      when(
        () => mockAnalytics.logScreenView(
          screenName: any(named: 'screenName'),
          screenClass: any(named: 'screenClass'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackDashboardView();

      // Assert
      verify(
        () => mockAnalytics.logScreenView(screenName: 'dashboard', screenClass: 'DashboardScreen'),
      ).called(1);
    });

    test('trackSettingsView calls logScreenView on Firebase Analytics', () async {
      // Arrange
      when(
        () => mockAnalytics.logScreenView(
          screenName: any(named: 'screenName'),
          screenClass: any(named: 'screenClass'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackSettingsView();

      // Assert
      verify(
        () => mockAnalytics.logScreenView(screenName: 'settings', screenClass: 'SettingsScreen'),
      ).called(1);
    });

    test('trackSettingChanged logs event with setting and value parameters', () async {
      // Arrange
      const setting = 'darkMode';
      const value = true;
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackSettingChanged(setting, value);

      // Assert
      verify(
        () => mockAnalytics.logEvent(
          name: 'setting_changed',
          parameters: {'setting': setting, 'value': value.toString()},
        ),
      ).called(1);
    });

    test('trackAboutView calls logScreenView on Firebase Analytics', () async {
      // Arrange
      when(
        () => mockAnalytics.logScreenView(
          screenName: any(named: 'screenName'),
          screenClass: any(named: 'screenClass'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackAboutView();

      // Assert
      verify(
        () => mockAnalytics.logScreenView(screenName: 'about', screenClass: 'AboutScreen'),
      ).called(1);
    });

    test('trackError logs event with error type and message parameters', () async {
      // Arrange
      const errorType = 'network_error';
      const errorMessage = 'Failed to connect to server';
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackError(errorType, errorMessage);

      // Assert
      verify(
        () => mockAnalytics.logEvent(
          name: 'app_error',
          parameters: {'error_type': errorType, 'error_message': errorMessage},
        ),
      ).called(1);
    });

    test('trackVerseShared calls logShare on Firebase Analytics', () async {
      // Arrange
      when(
        () => mockAnalytics.logShare(
          contentType: any(named: 'contentType'),
          itemId: any(named: 'itemId'),
          method: any(named: 'method'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await analyticsClient.trackVerseShared();

      // Assert
      verify(
        () => mockAnalytics.logShare(
          contentType: 'verse',
          itemId: 'verse_shared',
          method: 'share_sheet',
        ),
      ).called(1);
    });
  });
}
