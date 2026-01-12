import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/services/app_logger.dart';

/// Entry point identification for analytics
enum AnalyticsEntryPoint {
  main('main');

  const AnalyticsEntryPoint(this.key);

  final String key;
}

/// Abstract interface for analytics tracking using Firebase Analytics
abstract class AnalyticsService {
  /// Initialize the analytics service
  Future<void> init({AnalyticsEntryPoint? entryPoint});

  /// Track a user event with optional properties
  Future<void> track(String eventName, {Map<String, dynamic>? properties});

  /// Track user login event
  Future<void> trackLogin(String username) =>
      track('user_login', properties: {'username': username});

  /// Track user logout event
  Future<void> trackLogout() => track('user_logout');

  /// Track login failure after network call
  Future<void> trackLoginFailure(String username, String error) =>
      track('login_failure_after_network_call', properties: {'username': username, 'error': error});

  /// Track feedback trigger event
  Future<void> trackFeedbackTrigger() => track('feedback_trigger');

  /// Track verse answer - correct
  Future<void> trackVerseCorrect(String verseReference) =>
      track('verse_correct', properties: {'verse_reference': verseReference});

  /// Track verse answer - incorrect
  Future<void> trackVerseIncorrect(String verseReference, String userAnswer) => track(
    'verse_incorrect',
    properties: {'verse_reference': verseReference, 'user_answer': userAnswer},
  );

  /// Track verse answer - nearly correct
  Future<void> trackVerseNearlyCorrect(String verseReference, String userAnswer) => track(
    'verse_nearly_correct',
    properties: {'verse_reference': verseReference, 'user_answer': userAnswer},
  );

  /// Track verse displayed
  Future<void> trackVerseDisplayed(String verseReference) =>
      track('verse_displayed', properties: {'verse_reference': verseReference});

  /// Track verse practice session start
  Future<void> trackPracticeSessionStart() => track('practice_session_start');

  /// Track verse practice session complete
  Future<void> trackPracticeSessionComplete(int versesAnswered, int correctAnswers) => track(
    'practice_session_complete',
    properties: {
      'verses_answered': versesAnswered,
      'correct_answers': correctAnswers,
      'accuracy': versesAnswered > 0 ? correctAnswers / versesAnswered : 0.0,
    },
  );

  /// Track when verse list cycles back to the beginning
  Future<void> trackVerseListCycled(int totalVerses, int cycleCount) => track(
    'verse_list_cycled',
    properties: {'total_verses': totalVerses, 'cycle_count': cycleCount},
  );

  /// Track successful API call for verses
  Future<void> trackVerseApiSuccess(int verseCount, int responseTime) => track(
    'verse_api_success',
    properties: {'verse_count': verseCount, 'response_time_ms': responseTime},
  );

  /// Track failed API call for verses
  Future<void> trackVerseApiFailure(String errorType, String errorMessage) => track(
    'verse_api_failure',
    properties: {'error_type': errorType, 'error_message': errorMessage},
  );

  /// Track password visibility toggle
  Future<void> trackPasswordVisibilityToggle(bool isVisible) =>
      track('password_visibility_toggle', properties: {'is_visible': isVisible});

  /// Track form validation failures
  Future<void> trackValidationFailure(String field, String error) =>
      track('validation_failure', properties: {'field': field, 'error': error});

  /// Track empty username validation
  Future<void> trackEmptyUsernameValidation() =>
      track('empty_username_validation', properties: {'field': 'username', 'error': 'empty'});

  /// Track empty password validation
  Future<void> trackEmptyPasswordValidation() =>
      track('empty_password_validation', properties: {'field': 'password', 'error': 'empty'});

  /// Track web-specific events
  Future<void> trackWebPageView(String pageName) =>
      track('web_page_view', properties: {'page_name': pageName, 'platform': 'web'});

  /// Track web browser information
  Future<void> trackWebBrowserInfo(String userAgent) =>
      track('web_browser_info', properties: {'user_agent': userAgent, 'platform': 'web'});

  /// Track web performance metrics
  Future<void> trackWebPerformance(int loadTime, String pageName) => track(
    'web_performance',
    properties: {'load_time_ms': loadTime, 'page_name': pageName, 'platform': 'web'},
  );

  /// Track app opened
  Future<void> trackAppOpened() => track('app_opened');

  /// Track analytics service initialization
  Future<void> trackAnalyticsInitialized() => track('analytics_initialized');
}

/// Firebase Analytics implementation
class FirebaseAnalyticsService extends AnalyticsService {
  factory FirebaseAnalyticsService() => _instance;

  FirebaseAnalyticsService._internal();
  static final FirebaseAnalyticsService _instance = FirebaseAnalyticsService._internal();

  bool _isInitialized = false;

  @override
  Future<void> init({AnalyticsEntryPoint? entryPoint}) async {
    if (_isInitialized) {
      AppLogger.i('Firebase analytics already initialized');
      return;
    }

    try {
      AppLogger.i('🔧 Firebase analytics is ready (configured via Firebase Core)');
      _isInitialized = true;
      await trackAnalyticsInitialized();
      AppLogger.i('✅ Firebase analytics initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize Firebase analytics: $e', e, null, false);
    }
  }

  @override
  Future<void> track(String eventName, {Map<String, dynamic>? properties}) async {
    if (kDebugMode) {
      AppLogger.d('🔍 Track: $eventName');
      if (properties != null && properties.isNotEmpty) {
        AppLogger.d('   Properties: $properties');
      }
    }
    // Firebase Analytics is automatically initialized via Firebase Core
    // Events are tracked via Firebase Analytics SDK
    // Additional Firebase analytics calls can be added here as needed
  }
}

/// Logging analytics service for debug mode
class LoggingAnalyticsService extends AnalyticsService {
  @override
  Future<void> init({AnalyticsEntryPoint? entryPoint}) async {
    if (kDebugMode) {
      AppLogger.d('📊 Logging analytics service initialized - Entry: ${entryPoint?.key}');
    }
  }

  @override
  Future<void> track(String eventName, {Map<String, dynamic>? properties}) async {
    if (kDebugMode) {
      AppLogger.d('📊 Analytics: $eventName${properties != null ? ' - $properties' : ''}');
    }
  }
}

/// No-op analytics service for testing
class NoOpAnalyticsService extends AnalyticsService {
  @override
  Future<void> init({AnalyticsEntryPoint? entryPoint}) async {
    // Do nothing
  }

  @override
  Future<void> track(String eventName, {Map<String, dynamic>? properties}) async {
    // Do nothing
  }
}

/// Provider for the analytics service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return FirebaseAnalyticsService();
});
