import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/src/constants/app_constants.dart';

import 'analytics_client.dart';

/// A Firebase Analytics implementation of [AnalyticsClient].
class FirebaseAnalyticsClient implements AnalyticsClient {
  /// Creates a new [FirebaseAnalyticsClient]
  const FirebaseAnalyticsClient(this._analytics, this._crashlytics);

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> initialize() async {
    // Set analytics collection enabled based on build mode
    await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);

    // Set Crashlytics collection enabled based on build mode
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Set environment variables as user properties for analytics
    if (testerType.isNotEmpty) {
      await _analytics.setUserProperty(name: 'tester_type', value: testerType);
      _crashlytics.setCustomKey('tester_type', testerType);
    }

    // Log app_configuration event with environment variables
    await _analytics.logEvent(
      name: 'app_configuration',
      parameters: {
        'tester_type': testerType.isEmpty ? 'none' : testerType,
        'debug_mode': kDebugMode.toString(),
      },
    );

    // Log initialization success
    if (kDebugMode) {
      print('📊 Firebase Analytics initialized. Collection enabled: ${!kDebugMode}');
      print('🔥 Firebase Crashlytics initialized. Collection enabled: ${!kDebugMode}');

      if (testerType.isNotEmpty) {
        print('👤 Tester type: $testerType');
      }
    }
  }

  @override
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

  @override
  Future<void> trackLogin() => _analytics.logLogin();

  @override
  Future<void> trackLogout() => _analytics.logEvent(name: 'logout');

  @override
  Future<void> trackSignUp() => _analytics.logSignUp(signUpMethod: 'email');

  @override
  Future<void> trackVerseSessionStarted() => _analytics.logEvent(name: 'verse_session_started');

  @override
  Future<void> trackVerseSessionCompleted(int verseCount) =>
      _analytics.logEvent(name: 'verse_session_completed', parameters: {'verse_count': verseCount});

  @override
  Future<void> trackVerseAdded() => _analytics.logEvent(name: 'verse_added');

  @override
  Future<void> trackVerseSearch(String query) => _analytics.logSearch(searchTerm: query);

  @override
  Future<void> trackVerseRated(int rating) =>
      _analytics.logEvent(name: 'verse_rated', parameters: {'rating': rating});

  @override
  Future<void> trackDashboardView() =>
      _analytics.logScreenView(screenName: 'dashboard', screenClass: 'DashboardScreen');

  @override
  Future<void> trackSettingsView() =>
      _analytics.logScreenView(screenName: 'settings', screenClass: 'SettingsScreen');

  @override
  Future<void> trackSettingChanged(String setting, dynamic value) => _analytics.logEvent(
    name: 'setting_changed',
    parameters: {'setting': setting, 'value': value.toString()},
  );

  @override
  Future<void> trackAboutView() =>
      _analytics.logScreenView(screenName: 'about', screenClass: 'AboutScreen');

  @override
  Future<void> trackError(String errorType, String errorMessage) => _analytics.logEvent(
    name: 'app_error',
    parameters: {'error_type': errorType, 'error_message': errorMessage},
  );

  @override
  Future<void> trackVerseShared() =>
      _analytics.logShare(contentType: 'verse', itemId: 'verse_shared', method: 'share_sheet');

  @override
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? additionalData,
  }) async {
    // Set any custom keys for better error analysis
    if (additionalData != null) {
      for (final entry in additionalData.entries) {
        _crashlytics.setCustomKey(entry.key, entry.value.toString());
      }
    }

    // Record the error
    _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason ?? (fatal ? 'Fatal error' : 'Non-fatal error'),
      fatal: fatal,
    );

    // Also log to analytics
    if (additionalData != null) {
      await logEvent(fatal ? 'app_fatal_error' : 'app_error', parameters: additionalData);
    } else {
      await logEvent(
        fatal ? 'app_fatal_error' : 'app_error',
        parameters: {'error': error.toString(), 'reason': reason ?? 'Unknown'},
      );
    }
  }

  @override
  Future<void> logScreenView(String screenName, String screenClass) async {
    await _analytics.logScreenView(screenName: screenName, screenClass: screenClass);
  }

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    // Convert to required Firebase parameter type
    final Map<String, Object>? firebaseParams = parameters?.map(
      (key, value) => MapEntry(key, value as Object),
    );

    await _analytics.logEvent(name: eventName, parameters: firebaseParams);
  }
}

/// Provider for Firebase Analytics client
final firebaseAnalyticsClientProvider = Provider<FirebaseAnalyticsClient>(
  (ref) => FirebaseAnalyticsClient(FirebaseAnalytics.instance, FirebaseCrashlytics.instance),
);
