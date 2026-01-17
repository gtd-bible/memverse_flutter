import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:mini_memverse/src/common/providers/talker_provider.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:talker/talker.dart';

/// Improved logging wrapper that integrates with Talker and AnalyticsFacade
class AppLoggerFacade {
  /// Creates a new AppLoggerFacade
  AppLoggerFacade({
    required this.logger,
    required this.analyticsFacade,
    required this.talker,
    FirebaseCrashlytics? crashlytics,
  }) : crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  /// The logger instance
  final Logger logger;

  /// The analytics facade
  final AnalyticsFacade analyticsFacade;

  /// The talker instance
  final Talker talker;

  /// The crashlytics instance
  final FirebaseCrashlytics crashlytics;

  /// Log a trace level message (verbose)
  void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      trace(message, error, stackTrace);
    }
  }

  /// Log a trace level message
  void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.t(message, error: error, stackTrace: stackTrace);
    crashlytics.log('[TRACE] $message');

    // Add to talker for comprehensive log collection
    talker.verbose('$message', error, stackTrace);
  }

  /// Log a debug level message (short form)
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debug(message, error, stackTrace);
    }
  }

  /// Log a debug level message
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.d(message, error: error, stackTrace: stackTrace);
    crashlytics.log('[DEBUG] $message');

    // Add to talker for comprehensive log collection
    talker.debug('$message', error, stackTrace);
  }

  /// Log an info level message (short form)
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      info(message, error, stackTrace);
    }
  }

  /// Log an info level message
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.i(message, error: error, stackTrace: stackTrace);
    crashlytics.log('[INFO] $message');

    // Add to talker for comprehensive log collection
    talker.info('$message', error, stackTrace);
  }

  /// Log a warning level message (short form)
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      warning(message, error, stackTrace);
    }
  }

  /// Log a warning level message
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.w(message, error: error, stackTrace: stackTrace);
    crashlytics.log('[WARNING] $message');

    // Add to talker for comprehensive log collection
    talker.warning('$message', error, stackTrace);
  }

  /// Log an error level message and optionally send to Crashlytics
  ///
  /// [recordToCrashlytics] - if true, the error will be recorded as a non-fatal error in Crashlytics
  /// [analyticsAttributes] - optional attributes to include in the analytics event
  void error(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
    bool recordToCrashlytics = true,
    Map<String, dynamic>? analyticsAttributes,
  ]) {
    // Format a clean log message
    final String cleanMessage = message.toString().trim();

    // Log to console with pretty formatting
    logger.e(cleanMessage, error: error, stackTrace: stackTrace);

    // Add to Crashlytics logs (not a report yet, just for context)
    crashlytics.log('[ERROR] $cleanMessage');

    // Log to Talker for comprehensive log collection
    talker.error(cleanMessage, error, stackTrace);

    // Only send to Crashlytics if requested and we have an actual error
    if (recordToCrashlytics) {
      // Use the provided error, or the message if no error was provided
      final errorToRecord = error ?? message;

      // Record with analytics facade for complete coverage
      analyticsFacade.recordError(
        errorToRecord,
        stackTrace,
        reason: cleanMessage,
        fatal: false,
        additionalData: analyticsAttributes,
      );

      // Also track as an error event
      analyticsFacade.trackError('app_error', cleanMessage);
    }
  }

  /// Log an error level message (short form)
  void e(dynamic message, [dynamic err, StackTrace? stackTrace]) =>
      error(message, err, stackTrace, true);

  /// Log a fatal error level message (short form)
  void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      fatal(message, error, stackTrace);
    }
  }

  /// Log a fatal error level message and send to Crashlytics
  ///
  /// [analyticsAttributes] - optional attributes to include in the analytics event
  void fatal(
    dynamic message,
    dynamic error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? analyticsAttributes,
  ]) {
    logger.f(message, error: error, stackTrace: stackTrace);
    crashlytics.log('[FATAL] $message');

    // Log to Talker for comprehensive log collection
    talker.critical(message.toString(), error, stackTrace);

    // Record with analytics facade for complete coverage
    final errorToRecord = error ?? message;
    analyticsFacade.recordError(
      errorToRecord,
      stackTrace,
      reason: message.toString(),
      fatal: true,
      additionalData: analyticsAttributes,
    );

    // Also track as a fatal error event
    analyticsFacade.logEvent(
      'app_fatal_error',
      parameters: {'error': errorToRecord.toString(), 'reason': message.toString()},
    );
  }
}

/// Provider for the AppLoggerFacade
final appLoggerFacadeProvider = Provider<AppLoggerFacade>((ref) {
  // Get dependencies
  final analyticsFacade = ref.watch(analyticsFacadeProvider);
  final talker = ref.watch(talkerProvider);

  // Create a pretty logger
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  return AppLoggerFacade(
    logger: logger,
    analyticsFacade: analyticsFacade,
    talker: talker,
    crashlytics: FirebaseCrashlytics.instance,
  );
});
