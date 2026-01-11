import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/monitoring/analytics_client.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsClient extends Mock implements AnalyticsClient {}

void main() {
  late AnalyticsFacade analyticsFacade;
  late MockAnalyticsClient mockClient1;
  late MockAnalyticsClient mockClient2;

  setUp(() {
    mockClient1 = MockAnalyticsClient();
    mockClient2 = MockAnalyticsClient();
    analyticsFacade = AnalyticsFacade([mockClient1, mockClient2]);

    // Register fallbacks for common parameter types
    registerFallbackValue(0); // For verseCount, rating
    registerFallbackValue(''); // For query, setting, errorType, errorMessage
  });

  group('AnalyticsFacade', () {
    test('forwards trackLogin to all clients', () async {
      // Arrange
      when(() => mockClient1.trackLogin()).thenAnswer((_) async {});
      when(() => mockClient2.trackLogin()).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackLogin();

      // Assert
      verify(() => mockClient1.trackLogin()).called(1);
      verify(() => mockClient2.trackLogin()).called(1);
    });

    test('forwards trackLogout to all clients', () async {
      // Arrange
      when(() => mockClient1.trackLogout()).thenAnswer((_) async {});
      when(() => mockClient2.trackLogout()).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackLogout();

      // Assert
      verify(() => mockClient1.trackLogout()).called(1);
      verify(() => mockClient2.trackLogout()).called(1);
    });

    test('forwards trackSignUp to all clients', () async {
      // Arrange
      when(() => mockClient1.trackSignUp()).thenAnswer((_) async {});
      when(() => mockClient2.trackSignUp()).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackSignUp();

      // Assert
      verify(() => mockClient1.trackSignUp()).called(1);
      verify(() => mockClient2.trackSignUp()).called(1);
    });

    test('forwards trackVerseSessionStarted to all clients', () async {
      // Arrange
      when(() => mockClient1.trackVerseSessionStarted()).thenAnswer((_) async {});
      when(() => mockClient2.trackVerseSessionStarted()).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackVerseSessionStarted();

      // Assert
      verify(() => mockClient1.trackVerseSessionStarted()).called(1);
      verify(() => mockClient2.trackVerseSessionStarted()).called(1);
    });

    test('forwards trackVerseSessionCompleted to all clients with correct parameters', () async {
      // Arrange
      const verseCount = 5;
      when(() => mockClient1.trackVerseSessionCompleted(any())).thenAnswer((_) async {});
      when(() => mockClient2.trackVerseSessionCompleted(any())).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackVerseSessionCompleted(verseCount);

      // Assert
      verify(() => mockClient1.trackVerseSessionCompleted(verseCount)).called(1);
      verify(() => mockClient2.trackVerseSessionCompleted(verseCount)).called(1);
    });

    test('forwards trackVerseAdded to all clients', () async {
      // Arrange
      when(() => mockClient1.trackVerseAdded()).thenAnswer((_) async {});
      when(() => mockClient2.trackVerseAdded()).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackVerseAdded();

      // Assert
      verify(() => mockClient1.trackVerseAdded()).called(1);
      verify(() => mockClient2.trackVerseAdded()).called(1);
    });

    test('forwards trackVerseSearch to all clients with correct query', () async {
      // Arrange
      const query = 'John 3:16';
      when(() => mockClient1.trackVerseSearch(any())).thenAnswer((_) async {});
      when(() => mockClient2.trackVerseSearch(any())).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackVerseSearch(query);

      // Assert
      verify(() => mockClient1.trackVerseSearch(query)).called(1);
      verify(() => mockClient2.trackVerseSearch(query)).called(1);
    });

    test('forwards trackVerseRated to all clients with correct rating', () async {
      // Arrange
      const rating = 4;
      when(() => mockClient1.trackVerseRated(any())).thenAnswer((_) async {});
      when(() => mockClient2.trackVerseRated(any())).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackVerseRated(rating);

      // Assert
      verify(() => mockClient1.trackVerseRated(rating)).called(1);
      verify(() => mockClient2.trackVerseRated(rating)).called(1);
    });

    test('forwards trackDashboardView to all clients', () async {
      // Arrange
      when(() => mockClient1.trackDashboardView()).thenAnswer((_) async {});
      when(() => mockClient2.trackDashboardView()).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackDashboardView();

      // Assert
      verify(() => mockClient1.trackDashboardView()).called(1);
      verify(() => mockClient2.trackDashboardView()).called(1);
    });

    test('forwards trackSettingsView to all clients', () async {
      // Arrange
      when(() => mockClient1.trackSettingsView()).thenAnswer((_) async {});
      when(() => mockClient2.trackSettingsView()).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackSettingsView();

      // Assert
      verify(() => mockClient1.trackSettingsView()).called(1);
      verify(() => mockClient2.trackSettingsView()).called(1);
    });

    test('forwards trackSettingChanged to all clients with correct parameters', () async {
      // Arrange
      const setting = 'darkMode';
      const value = true;
      when(() => mockClient1.trackSettingChanged(any(), any())).thenAnswer((_) async {});
      when(() => mockClient2.trackSettingChanged(any(), any())).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackSettingChanged(setting, value);

      // Assert
      verify(() => mockClient1.trackSettingChanged(setting, value)).called(1);
      verify(() => mockClient2.trackSettingChanged(setting, value)).called(1);
    });

    test('forwards trackAboutView to all clients', () async {
      // Arrange
      when(() => mockClient1.trackAboutView()).thenAnswer((_) async {});
      when(() => mockClient2.trackAboutView()).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackAboutView();

      // Assert
      verify(() => mockClient1.trackAboutView()).called(1);
      verify(() => mockClient2.trackAboutView()).called(1);
    });

    test('forwards trackError to all clients with correct parameters', () async {
      // Arrange
      const errorType = 'network_error';
      const errorMessage = 'Failed to connect to server';
      when(() => mockClient1.trackError(any(), any())).thenAnswer((_) async {});
      when(() => mockClient2.trackError(any(), any())).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackError(errorType, errorMessage);

      // Assert
      verify(() => mockClient1.trackError(errorType, errorMessage)).called(1);
      verify(() => mockClient2.trackError(errorType, errorMessage)).called(1);
    });

    test('forwards trackVerseShared to all clients', () async {
      // Arrange
      when(() => mockClient1.trackVerseShared()).thenAnswer((_) async {});
      when(() => mockClient2.trackVerseShared()).thenAnswer((_) async {});

      // Act
      await analyticsFacade.trackVerseShared();

      // Assert
      verify(() => mockClient1.trackVerseShared()).called(1);
      verify(() => mockClient2.trackVerseShared()).called(1);
    });

    test('handles errors from one client without affecting others', () async {
      // Arrange
      when(() => mockClient1.trackLogin()).thenAnswer((_) async {});
      when(() => mockClient2.trackLogin()).thenThrow(Exception('Analytics error'));

      // Act & Assert
      // The exception from the second client should be propagated
      expect(() => analyticsFacade.trackLogin(), throwsException);

      // But the first client should still have been called
      verify(() => mockClient1.trackLogin()).called(1);
    });
  });
}