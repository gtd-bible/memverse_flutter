import 'dart:convert'; // Import for jsonEncode
import 'package:dio/dio.dart';
import 'package:memverse_flutter/src/utils/app_logger.dart';

/// A Dio interceptor that logs requests as curl commands.
/// Useful for debugging network requests by easily replaying them from the terminal.
class CurlLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final curl = _toCurl(options);
      AppLogger.d('CURL: $curl');
    } catch (e) {
      AppLogger.e('Error generating CURL command: $e');
    }
    super.onRequest(options, handler);
  }

  String _toCurl(RequestOptions options) {
    final method = options.method.toUpperCase();
    final uri = options.uri.toString();
    final headers = options.headers.entries
        .map((e) => '-H "${e.key}: ${e.value}"')
        .join(' ');
    String body = '';

    if (options.data != null) {
      if (options.data is FormData) {
        // Handle FormData separately as it's complex to represent in curl
        body = '--data-raw \'<FORM_DATA>\''; // Placeholder
        AppLogger.w('CURL command for FormData might be incomplete.');
      } else {
        body = '-d \'${jsonEncode(options.data)}\'';
      }
    }

    return 'curl -X $method $headers $body "$uri"';
  }
}