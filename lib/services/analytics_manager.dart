import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized analytics management for Firebase Analytics and Crashlytics
class AnalyticsManager {
  /// Private constructor for singleton
  AnalyticsManager._();

  /// The singleton instance
  static AnalyticsManager instance = AnalyticsManager._();

  /// The Firebase Analytics instance
  final _analytics = FirebaseAnalytics.instance;

  /// The Firebase Crashlytics instance
  final _crashlytics = FirebaseCrashlytics.instance;

  /// Getter for analytics
  FirebaseAnalytics get analytics => _analytics;

  /// Getter for crashlytics
  FirebaseCrashlytics get crashlytics => _crashlytics;

  /// Access to tester type environment variable
  static String get testerType => const String.fromEnvironment('TESTER_TYPE', defaultValue: '');

  /// Initializes the AnalyticsManager
  Future<void> initialize() async {
    // Set analytics collection enabled based on build mode
    await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);

    // Set Crashlytics collection enabled based on build mode
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Set environment variables as user properties for analytics
    final testerTypeValue = testerType;
    if (testerTypeValue.isNotEmpty) {
      await _analytics.setUserProperty(name: 'tester_type', value: testerTypeValue);
      _crashlytics.setCustomKey('tester_type', testerTypeValue);
    }

    // Log app_configuration event with environment variables
    await _analytics.logEvent(
      name: 'app_configuration',
      parameters: {
        'tester_type': testerTypeValue.isEmpty ? 'none' : testerTypeValue,
        'debug_mode': kDebugMode.toString(),
      },
    );

    // Log initialization success
    if (kDebugMode) {
      print('📊 Analytics initialized. Collection enabled: ${!kDebugMode}');
      print('🔥 Crashlytics initialized. Collection enabled: ${!kDebugMode}');

      if (testerTypeValue.isNotEmpty) {
        print('👤 Tester type: $testerTypeValue');
      }
    }
  }

  /// Sets user identifier for both Analytics and Crashlytics
  Future<void> setUserId(String? userId) async {
    if (userId != null && userId.isNotEmpty) {
      // Set user ID for Analytics
      await _analytics.setUserId(id: userId);

      // Set user ID for Crashlytics
      await _crashlytics.setUserIdentifier(userId);

      if (kDebugMode) {
        print('🔑 User ID set: $userId');
      }
    } else {
      // Clear user ID if null or empty
      await _analytics.setUserId(id: null);
      await _crashlytics.setUserIdentifier('');

      if (kDebugMode) {
        print('🔑 User ID cleared');
      }
    }
  }

  /// Records a non-fatal error to Crashlytics
  void recordNonFatalError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, String>? customParameters,
    Map<String, Object?>? analyticsAttributes,
  }) {
    // Set any custom keys for better error analysis
    if (customParameters != null) {
      for (final entry in customParameters.entries) {
        _crashlytics.setCustomKey(entry.key, entry.value);
      }
    }

    // Record the error
    _crashlytics.recordError(
      error,
      stackTrace,
      reason: customParameters?['message'] ?? 'Non-fatal error',
      fatal: false,
    );

    // Also log to analytics if attributes provided
    if (analyticsAttributes != null) {
      final Map<String, Object> firebaseParams = analyticsAttributes.map(
        (key, value) => MapEntry(key, value as Object),
      );
      _analytics.logEvent(name: 'app_error', parameters: firebaseParams);
    }
  }

  /// Records a fatal error to Crashlytics
  void recordFatalError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, String>? customParameters,
    Map<String, Object?>? analyticsAttributes,
  }) {
    // Set any custom keys for better error analysis
    if (customParameters != null) {
      for (final entry in customParameters.entries) {
        _crashlytics.setCustomKey(entry.key, entry.value);
      }
    }

    // Record the error as fatal
    _crashlytics.recordError(
      error,
      stackTrace,
      reason: customParameters?['message'] ?? 'Fatal error',
      fatal: true,
    );

    // Also log to analytics if attributes provided
    if (analyticsAttributes != null) {
      final Map<String, Object> firebaseParams = analyticsAttributes.map(
        (key, value) => MapEntry(key, value as Object),
      );
      _analytics.logEvent(name: 'app_fatal_error', parameters: firebaseParams);
    }
  }

  /// Logs a screen view to Firebase Analytics
  Future<void> logScreenView(String screenName, String screenClass) async {
    await _analytics.logScreenView(screenName: screenName, screenClass: screenClass);
  }

  /// Logs an event to Firebase Analytics
  Future<void> logEvent(String eventName, Map<String, dynamic>? parameters) async {
    // Convert to required Firebase parameter type
    final Map<String, Object>? firebaseParams = parameters != null
        ? parameters.map((key, value) => MapEntry(key, value as Object))
        : null;

    await _analytics.logEvent(name: eventName, parameters: firebaseParams);
  }
}
