import 'package:memverse_flutter/src/utils/app_logger.dart';
import 'package:dio/dio.dart'; // Import Dio for RequestOptions

/// Abstract class defining an interface for logging parsing errors.
/// This is used by generated Retrofit clients.
abstract class ParseErrorLogger {
  void logError(dynamic error, StackTrace stackTrace, RequestOptions options, [String? message]);
}

/// Concrete implementation of [ParseErrorLogger] that uses [AppLogger].
class AppParseErrorLogger implements ParseErrorLogger {
  @override
  void logError(dynamic error, StackTrace stackTrace, RequestOptions options, [String? message]) {
    // Log the error using AppLogger.e
    // The 'options' object (likely RequestOptions from Dio) can be stringified if needed for context.
    AppLogger.e(
      message ?? 'Auth API Parsing Error: ${error.toString()} (Path: ${options.path})',
      error,
      stackTrace,
    );
  }
}
