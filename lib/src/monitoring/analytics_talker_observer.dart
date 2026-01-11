import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_client.dart';
import 'analytics_facade.dart';

/// An observer that sends Talker error and exception events to Firebase Analytics
///
/// Unlike CrashlyticsTalkerObserver which focuses on crash reporting,
/// this observer records errors as regular analytics events for easier
/// tracking and visualization in the Firebase Analytics dashboard.
class AnalyticsTalkerObserver extends TalkerObserver {
  /// Creates a new [AnalyticsTalkerObserver]
  const AnalyticsTalkerObserver({
    required this.analyticsClient,
    this.enableInDebugMode = false,
  });

  /// The analytics client to use for reporting errors
  final AnalyticsClient analyticsClient;

  /// Whether to enable analytics reporting in debug mode
  final bool enableInDebugMode;

  @override
  void onError(TalkerError err) {
    // Skip reporting in debug mode unless explicitly enabled
    if (!enableInDebugMode && kDebugMode) return;

    // Send error to analytics
    final Map<String, dynamic> errorData = {
      'error_type': 'error',
      'title': err.title,
      'message': err.message ?? 'No message',
      'exception': err.error.toString(),
      'stack_trace_available': err.stackTrace != null,
      'time': DateTime.now().toIso8601String(),
    };

    analyticsClient.logEvent('talker_error', parameters: errorData);
    analyticsClient.trackError('talker_error', err.error.toString());

    super.onError(err);
  }

  @override
  void onException(TalkerException exception) {
    // Skip reporting in debug mode unless explicitly enabled
    if (!enableInDebugMode && kDebugMode) return;

    // Send exception to analytics
    final Map<String, dynamic> exceptionData = {
      'error_type': 'exception',
      'title': exception.title,
      'message': exception.message ?? 'No message',
      'exception': exception.exception.toString(),
      'stack_trace_available': exception.stackTrace != null,
      'time': DateTime.now().toIso8601String(),
    };

    analyticsClient.logEvent('talker_exception', parameters: exceptionData);
    analyticsClient.trackError('talker_exception', exception.exception.toString());

    super.onException(exception);
  }
}

/// Provider for AnalyticsTalkerObserver
final analyticsTalkerObserverProvider = Provider<AnalyticsTalkerObserver>((ref) {
  final analytics = ref.watch(analyticsFacadeProvider);

  return AnalyticsTalkerObserver(
    analyticsClient: analytics,
    enableInDebugMode: false, // Only enable in production by default
  );
});