import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Wrapper/manager for Analytics and Crashlytics
/// Handles both analytics events and crash reporting with automatic correlation
class AnalyticsManager {
  static AnalyticsManager? _instance;
  static AnalyticsManager get instance => _instance ??= AnalyticsManager._();

  AnalyticsManager._();

  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;

  /// Flag to indicate if the app is running in integration test mode
  bool isIntegrationTest = false;

  /// Set the integration test flag
  /// This will add `is_integration_test: true` to all analytics events
  void setIntegrationTestMode(bool value) {
    isIntegrationTest = value;
  }

  /// Get default analytics properties that should be included with every event
  Map<String, Object> _getDefaultProperties() {
    final now = DateTime.now();
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthYear = '${now.year}${monthNames[now.month - 1]}';

    final properties = <String, Object>{
      'flutter': 'true',
      'debug_mode': kDebugMode.toString(),
      'month_year': monthYear,
    };

    if (isIntegrationTest) {
      properties['is_integration_test'] = 'true';
    }

    return properties;
  }

  /// Log an analytics event with the given name and parameters
  Future<void> logEvent(String eventName, Map<String, Object?>? parameters) async {
    final defaultParams = _getDefaultProperties();
    final mergedParams = <String, Object>{...defaultParams};
    if (parameters != null) {
      mergedParams.addAll(parameters.cast<String, Object>());
    }

    if (kDebugMode) {
      debugPrint('AnalyticsManager: Sending analytics event: $eventName');
      debugPrint('  Parameters: $mergedParams');
    }
    await analytics.logEvent(name: eventName, parameters: mergedParams);
    if (kDebugMode) {
      debugPrint('AnalyticsManager: Analytics event sent: $eventName');
    }
  }

  /// Record a non-fatal error to Crashlytics and send a corresponding analytics event
  Future<void> recordNonFatalError(
    dynamic error,
    StackTrace? stack, {
    Map<String, Object?>? customParameters,
    Map<String, Object?>? analyticsAttributes,
  }) async {
    final errorType = error.runtimeType.toString();
    final errorMessage = error.toString();

    if (kDebugMode) {
      debugPrint('AnalyticsManager: Recording non-fatal error');
      debugPrint('  Error type: $errorType');
      debugPrint('  Error message: $errorMessage');
    }

    // Send to Crashlytics
    await crashlytics.recordError(
      error,
      stack,
      fatal: false,
      information: customParameters?.entries.map<Object>((e) => '${e.key}: ${e.value}') ?? [],
    );

    // Send analytics event for the error
    final analyticsParams = <String, Object?>{
      'error_type': errorType,
      'error_message': errorMessage,
      'is_fatal': 'false',
    };
    if (analyticsAttributes != null) {
      analyticsParams.addAll(analyticsAttributes);
    }

    await logEvent('non_fatal_error', analyticsParams.cast<String, Object?>());

    if (kDebugMode) {
      debugPrint('AnalyticsManager: Non-fatal error recorded');
    }
  }

  /// Record a fatal error to Crashlytics and send a corresponding analytics event
  Future<void> recordFatalError(
    dynamic error,
    StackTrace? stack, {
    Map<String, Object?>? customParameters,
    Map<String, Object?>? analyticsAttributes,
  }) async {
    final errorType = error.runtimeType.toString();
    final errorMessage = error.toString();

    if (kDebugMode) {
      debugPrint('AnalyticsManager: Recording fatal error');
      debugPrint('  Error type: $errorType');
      debugPrint('  Error message: $errorMessage');
    }

    // Send to Crashlytics
    await crashlytics.recordError(
      error,
      stack,
      fatal: true,
      information: customParameters?.entries.map<Object>((e) => '${e.key}: ${e.value}') ?? [],
    );

    // Send analytics event for the error
    final analyticsParams = <String, Object?>{
      'error_type': errorType,
      'error_message': errorMessage,
      'is_fatal': 'true',
    };
    if (analyticsAttributes != null) {
      analyticsParams.addAll(analyticsAttributes);
    }

    await logEvent('fatal_error', analyticsParams.cast<String, Object?>());

    if (kDebugMode) {
      debugPrint('AnalyticsManager: Fatal error recorded');
    }
  }

  /// Force an immediate crash and send analytics event
  void forceCrash({Map<String, Object?>? analyticsAttributes}) async {
    if (kDebugMode) {
      debugPrint('AnalyticsManager: Forcing crash');
    }

    // Send analytics event before crashing
    final analyticsParams = <String, Object?>{'crash_method': 'force_crash', 'is_fatal': 'true'};
    if (analyticsAttributes != null) {
      analyticsParams.addAll(analyticsAttributes);
    }

    await logEvent('forced_crash', analyticsParams.cast<String, Object?>());

    // Force the crash
    crashlytics.crash();
  }

  /// Set a user identifier for Crashlytics and Analytics
  Future<void> setUserId(String userId) async {
    if (kDebugMode) {
      debugPrint('AnalyticsManager: Setting user ID: $userId');
    }
    await crashlytics.setUserIdentifier(userId);
    await analytics.setUserId(id: userId);
    if (kDebugMode) {
      debugPrint('AnalyticsManager: User ID set');
    }
  }

  /// Set a custom key-value pair for the current crash report
  Future<void> setCustomKey(String key, String value) async {
    if (kDebugMode) {
      debugPrint('AnalyticsManager: Setting custom key: $key=$value');
    }
    await crashlytics.setCustomKey(key, value);
  }

  /// Log a custom crash attribute
  Future<void> log(String message) async {
    if (kDebugMode) {
      debugPrint('AnalyticsManager: Logging message: $message');
    }
    await crashlytics.log(message);
  }
}
