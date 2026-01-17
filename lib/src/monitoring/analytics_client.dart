import 'dart:async';

/// The interface for analytics tracking in the app.
///
/// This abstract class defines all events that can be tracked in the app,
/// providing a contract that all analytics implementations must follow.
abstract class AnalyticsClient {
  /// Initialize the analytics client
  Future<void> initialize();

  /// Set a user identifier for personalized analytics
  Future<void> setUserId(String? userId);

  /// Track when a user successfully logs in
  Future<void> trackLogin();

  /// Track when a user logs out
  Future<void> trackLogout();

  /// Track when a user signs up for a new account
  Future<void> trackSignUp();

  /// Track when a user starts a verse practice session
  Future<void> trackVerseSessionStarted();

  /// Track when a user completes a verse practice session
  Future<void> trackVerseSessionCompleted(int verseCount);

  /// Track when a user adds a new verse to memorize
  Future<void> trackVerseAdded();

  /// Track when a user searches for a verse
  Future<void> trackVerseSearch(String query);

  /// Track when a user rates their memory of a verse
  Future<void> trackVerseRated(int rating);

  /// Track when a user views the dashboard
  Future<void> trackDashboardView();

  /// Track when a user views the settings screen
  Future<void> trackSettingsView();

  /// Track when a user changes a setting
  Future<void> trackSettingChanged(String setting, dynamic value);

  /// Track when a user views the about screen
  Future<void> trackAboutView();

  /// Track when app encounters an error
  Future<void> trackError(String errorType, String errorMessage);

  /// Track when a user shares a verse
  Future<void> trackVerseShared();

  /// Record a non-fatal error with stack trace
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? additionalData,
  });

  /// Log a screen view
  Future<void> logScreenView(String screenName, String screenClass);

  /// Log a custom event with parameters
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters});
}
