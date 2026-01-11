import 'dart:developer' as developer;

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/monitoring/logger_analytics_client.dart';
import 'package:mocktail/mocktail.dart';

// Create a mock for dart:developer's log function using a custom function
typedef LogFunction = void Function(String message, {String? name, Object? error});

// A class to hold the mock function
class MockDeveloperLog {
  LogFunction logFunction = (String message, {String? name, Object? error}) {};
}

void main() {
  late LoggerAnalyticsClient loggerClient;
  late MockDeveloperLog mockLog;

  // The original log function to restore after tests
  late LogFunction originalLog;

  setUp(() {
    // Save original log function
    originalLog = developer.log;

    // Create mocks
    mockLog = MockDeveloperLog();
    loggerClient = const LoggerAnalyticsClient();

    // Replace developer.log with our mock
    developer.log = mockLog.logFunction;
  });

  tearDown(() {
    // Restore original log function
    developer.log = originalLog;
  });

  group('LoggerAnalyticsClient', () {
    test('trackLogin logs correct message', () async {
      // Arrange
      var wasCalled = false;
      var loggedName = '';
      var loggedMessage = '';

      mockLog.logFunction = (String message, {String? name, Object? error}) {
        wasCalled = true;
        loggedName = name ?? '';
        loggedMessage = message;
      };

      // Act
      await loggerClient.trackLogin();

      // Assert
      expect(wasCalled, isTrue);
      expect(loggedName, equals('Analytics'));
      expect(loggedMessage, equals('trackLogin'));
    });

    test('trackLogout logs correct message', () async {
      // Arrange
      var wasCalled = false;
      var loggedName = '';
      var loggedMessage = '';

      mockLog.logFunction = (String message, {String? name, Object? error}) {
        wasCalled = true;
        loggedName = name ?? '';
        loggedMessage = message;
      };

      // Act
      await loggerClient.trackLogout();

      // Assert
      expect(wasCalled, isTrue);
      expect(loggedName, equals('Analytics'));
      expect(loggedMessage, equals('trackLogout'));
    });

    test('trackSignUp logs correct message', () async {
      // Arrange
      var wasCalled = false;
      var loggedName = '';
      var loggedMessage = '';

      mockLog.logFunction = (String message, {String? name, Object? error}) {
        wasCalled = true;
        loggedName = name ?? '';
        loggedMessage = message;
      };

      // Act
      await loggerClient.trackSignUp();

      // Assert
      expect(wasCalled, isTrue);
      expect(loggedName, equals('Analytics'));
      expect(loggedMessage, equals('trackSignUp'));
    });

    test('trackVerseSessionStarted logs correct message', () async {
      // Arrange
      var wasCalled = false;
      var loggedName = '';
      var loggedMessage = '';

      mockLog.logFunction = (String message, {String? name, Object? error}) {
        wasCalled = true;
        loggedName = name ?? '';
        loggedMessage = message;
      };

      // Act
      await loggerClient.trackVerseSessionStarted();

      // Assert
      expect(wasCalled, isTrue);
      expect(loggedName, equals('Analytics'));
      expect(loggedMessage, equals('trackVerseSessionStarted'));
    });

    test('trackVerseSessionCompleted logs correct message with verse count', () async {
      // Arrange
      const verseCount = 5;
      var wasCalled = false;
      var loggedName = '';
      var loggedMessage = '';

      mockLog.logFunction = (String message, {String? name, Object? error}) {
        wasCalled = true;
        loggedName = name ?? '';
        loggedMessage = message;
      };

      // Act
      await loggerClient.trackVerseSessionCompleted(verseCount);

      // Assert
      expect(wasCalled, isTrue);
      expect(loggedName, equals('Analytics'));
      expect(loggedMessage, equals('trackVerseSessionCompleted(verseCount: $verseCount)'));
    });

    test('trackVerseAdded logs correct message', () async {
      // Arrange
      var wasCalled = false;
      var loggedName = '';
      var loggedMessage = '';

      mockLog.logFunction = (String message, {String? name, Object? error}) {
        wasCalled = true;
        loggedName = name ?? '';
        loggedMessage = message;
      };

      // Act
      await loggerClient.trackVerseAdded();

      // Assert
      expect(wasCalled, isTrue);
      expect(loggedName, equals('Analytics'));
      expect(loggedMessage, equals('trackVerseAdded'));
    });

    test('trackVerseSearch logs correct message with query', () async {
      // Arrange
      const query = 'John 3:16';
      var wasCalled = false;
      var loggedName = '';
      var loggedMessage = '';

      mockLog.logFunction = (String message, {String? name, Object? error}) {
        wasCalled = true;
        loggedName = name ?? '';
        loggedMessage = message;
      };

      // Act
      await loggerClient.trackVerseSearch(query);

      // Assert
      expect(wasCalled, isTrue);
      expect(loggedName, equals('Analytics'));
      expect(loggedMessage, equals('trackVerseSearch(query: $query)'));
    });

    test('trackVerseRated logs correct message with rating', () async {
      // Arrange
      const rating = 4;
      var wasCalled = false;
      var loggedName = '';
      var loggedMessage = '';

      mockLog.logFunction = (String message, {String? name, Object? error}) {
        wasCalled = true;
        loggedName = name ?? '';
        loggedMessage = message;
      };

      // Act
      await loggerClient.trackVerseRated(rating);

      // Assert
      expect(wasCalled, isTrue);
      expect(loggedName, equals('Analytics'));
      expect(loggedMessage, equals('trackVerseRated(rating: $rating)'));
    });

    test('trackError logs correct message with error details', () async {
      // Arrange
      const errorType = 'network_error';
      const errorMessage = 'Failed to connect to server';
      var wasCalled = false;
      var loggedName = '';
      var loggedMessage = '';

      mockLog.logFunction = (String message, {String? name, Object? error}) {
        wasCalled = true;
        loggedName = name ?? '';
        loggedMessage = message;
      };

      // Act
      await loggerClient.trackError(errorType, errorMessage);

      // Assert
      expect(wasCalled, isTrue);
      expect(loggedName, equals('Analytics'));
      expect(
        loggedMessage,
        equals('trackError(errorType: $errorType, errorMessage: $errorMessage)'),
      );
    });

    test('trackSettingChanged logs correct message with setting and value', () async {
      // Arrange
      const setting = 'darkMode';
      const value = true;
      var wasCalled = false;
      var loggedName = '';
      var loggedMessage = '';

      mockLog.logFunction = (String message, {String? name, Object? error}) {
        wasCalled = true;
        loggedName = name ?? '';
        loggedMessage = message;
      };

      // Act
      await loggerClient.trackSettingChanged(setting, value);

      // Assert
      expect(wasCalled, isTrue);
      expect(loggedName, equals('Analytics'));
      expect(loggedMessage, equals('trackSettingChanged(setting: $setting, value: $value)'));
    });
  });
}
