import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

/// An observer that sends Talker error and exception events to Firebase Crashlytics
class CrashlyticsTalkerObserver extends TalkerObserver {
  /// Creates a new [CrashlyticsTalkerObserver]
  const CrashlyticsTalkerObserver({this.enableInDebugMode = false});

  /// Whether to enable Crashlytics reporting in debug mode
  final bool enableInDebugMode;

  /// Reference to the Crashlytics instance for easier access
  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  @override
  void onError(TalkerError err) {
    // Skip reporting in debug mode unless explicitly enabled
    if (!enableInDebugMode && kDebugMode) return;

    // Record the error and add context to Crashlytics
    _crashlytics.recordError(err.error, err.stackTrace, reason: err.message);
    _crashlytics.log('[${err.title}] ${err.generateTextMessage()}');

    super.onError(err);
  }

  @override
  void onException(TalkerException exception) {
    // Skip reporting in debug mode unless explicitly enabled
    if (!enableInDebugMode && kDebugMode) return;

    // Record the exception and add context to Crashlytics
    _crashlytics.recordError(exception.exception, exception.stackTrace, reason: exception.message);
    _crashlytics.log('[${exception.title}] ${exception.generateTextMessage()}');

    super.onException(exception);
  }

  @override
  void onLog(TalkerData log) {
    // Only process errors and exceptions, skip other logs to avoid noise
    if (log is! TalkerError && log is! TalkerException) return;

    // Add context to Crashlytics logs
    _crashlytics.log('[${log.title}] ${log.generateTextMessage()}');

    super.onLog(log);
  }
}
