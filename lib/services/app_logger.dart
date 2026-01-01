import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'analytics_manager.dart';

/// Logging wrapper that outputs to both Logger (for development) and Crashlytics
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log a trace level message (verbose)
  static void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      trace(message, error, stackTrace);
    }
  }

  /// Log a trace level message
  static void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
    AnalyticsManager.instance.crashlytics.log('[TRACE] $message');
  }

  /// Log a debug level message (short form)
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debug(message, error, stackTrace);
    }
  }

  /// Log a debug level message
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
    AnalyticsManager.instance.crashlytics.log('[DEBUG] $message');
  }

  /// Log an info level message (short form)
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      info(message, error, stackTrace);
    }
  }

  /// Log an info level message
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    AnalyticsManager.instance.crashlytics.log('[INFO] $message');
  }

  /// Log a warning level message (short form)
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      warning(message, error, stackTrace);
    }
  }

  /// Log a warning level message
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    AnalyticsManager.instance.crashlytics.log('[WARNING] $message');
  }

  /// Log an error level message and optionally send to Crashlytics
  ///
  /// [recordToCrashlytics] - if true, the error will be recorded as a non-fatal error in Crashlytics
  /// [analyticsAttributes] - optional attributes to include in the analytics event
  static void error(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
    bool recordToCrashlytics = true,
    Map<String, Object?>? analyticsAttributes,
  ]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    AnalyticsManager.instance.crashlytics.log('[ERROR] $message');

    if (recordToCrashlytics) {
      final errorToRecord = error ?? message;
      AnalyticsManager.instance.recordNonFatalError(
        errorToRecord,
        stackTrace,
        customParameters: {'message': message.toString()},
        analyticsAttributes: analyticsAttributes,
      );
    }
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      error(message, error, stackTrace, true);

  /// Log a fatal error level message (short form)
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      fatal(message, error, stackTrace);
    }
  }

  /// Log a fatal error level message and send to Crashlytics
  ///
  /// [analyticsAttributes] - optional attributes to include in the analytics event
  static void fatal(
    dynamic message,
    dynamic error, [
    StackTrace? stackTrace,
    Map<String, Object?>? analyticsAttributes,
  ]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    AnalyticsManager.instance.crashlytics.log('[FATAL] $message');

    final errorToRecord = error ?? message;
    AnalyticsManager.instance.recordFatalError(
      errorToRecord,
      stackTrace,
      customParameters: {'message': message.toString()},
      analyticsAttributes: analyticsAttributes,
    );
  }
}
