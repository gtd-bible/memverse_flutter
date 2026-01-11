import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_client.dart';

/// A Firebase Analytics implementation of [AnalyticsClient].
class FirebaseAnalyticsClient implements AnalyticsClient {
  /// Creates a new [FirebaseAnalyticsClient]
  const FirebaseAnalyticsClient(this._analytics);

  final FirebaseAnalytics _analytics;

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
  Future<void> trackVerseShared() => _analytics.logShare(
    contentType: 'verse',
    itemId: 'verse_shared', // Fixed: changed from null to a string value
    method: 'share_sheet',
  );
}

/// Provider for Firebase Analytics client
final firebaseAnalyticsClientProvider = Provider<FirebaseAnalyticsClient>(
  (ref) => FirebaseAnalyticsClient(FirebaseAnalytics.instance),
);
