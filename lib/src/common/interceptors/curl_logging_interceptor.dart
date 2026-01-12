import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mini_memverse/services/app_logger.dart';

class CurlLoggingInterceptor extends Interceptor {
  /// Whether to enable detailed curl logging (only in debug mode for security)
  static const bool _enableDetailedLogging = false; // Set to true only for debugging OAuth issues

  /// Headers that should be redacted in logs
  static const _sensitiveHeaders = {'authorization', 'cookie', 'set-cookie'};

  /// Data fields that should be redacted in logs
  static const _sensitiveFields = {'password', 'client_secret', 'token', 'secret'};

  /// Redacts sensitive header values
  String _redactHeaderValue(String key, String value) {
    final lowerKey = key.toLowerCase();
    if (_sensitiveHeaders.contains(lowerKey) ||
        lowerKey.contains('token') ||
        lowerKey.contains('secret') ||
        lowerKey.contains('password')) {
      return '[REDACTED]';
    }
    return value;
  }

  /// Redacts sensitive data fields in maps
  Map _redactSensitiveData(Map data) {
    final redacted = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      if (_sensitiveFields.contains(key) ||
          key.contains('token') ||
          key.contains('secret') ||
          key.contains('password')) {
        redacted[entry.key] = '[REDACTED]';
      } else {
        redacted[entry.key] = entry.value;
      }
    }
    return redacted;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _printCurlCommand(options);
    _logDetailedRequest(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logDetailedResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logDetailedError(err);
    super.onError(err, handler);
  }

  void _printCurlCommand(RequestOptions options) {
    try {
      // Extract the URI and make sure it doesn't have query parameters for OAuth
      var uri = options.uri.toString();

      // For OAuth token endpoint, make sure we're hitting the exact same URL as the curl command
      if (options.path.contains('oauth/token')) {
        // Remove any query parameters for comparison
        if (uri.contains('?')) {
          uri = uri.substring(0, uri.indexOf('?'));
          AppLogger.w('⚠️ Found query parameters in OAuth URL! Removing for curl comparison');
        }

        // Verify the URL matches exactly
        if (uri != 'https://www.memverse.com/oauth/token') {
          AppLogger.e('❌ MISMATCH! OAuth URL is different from working curl command:');
          AppLogger.e('App using: $uri');
          AppLogger.e('Curl using: https://www.memverse.com/oauth/token');
        } else {
          AppLogger.i('✅ OAuth URL matches successful curl command');
        }

        // First log an easy copy-paste command for environment variables (only if detailed logging enabled)
        if (_enableDetailedLogging) {
          final envCommand = '''
curl -X POST "https://www.memverse.com/oauth/token" \\
  -H "Content-Type: application/x-www-form-urlencoded" \\
  -d "grant_type=password&username=\$MEMVERSE_USERNAME&password=[REDACTED]&client_id=\$MEMVERSE_CLIENT_ID&client_secret=[REDACTED]" \\
  -v
''';
          AppLogger.i('🟢 COPY-PASTE CURL WITH ENV VARIABLES:');
          AppLogger.i(envCommand);
        }

        // Check content-type header
        final contentType = options.headers['Content-Type'] ?? options.contentType;
        if (contentType != 'application/x-www-form-urlencoded') {
          AppLogger.e('❌ MISMATCH! Content-Type is different from working curl command:');
          AppLogger.e('App using: $contentType');
          AppLogger.e('Curl using: application/x-www-form-urlencoded');
        } else {
          AppLogger.i('✅ Content-Type matches successful curl command');
        }

        // Check data format - only if detailed logging enabled
        if (_enableDetailedLogging) {
          if (options.data is! Map) {
            AppLogger.e('❌ Data is not a Map! It should be key-value pairs for form data');
          } else {
            AppLogger.i('✅ Data is a Map as expected');
            final dataMap = options.data as Map;

            // Check required fields (without logging values)
            final requiredFields = [
              'grant_type',
              'username',
              'password',
              'client_id',
              'client_secret',
            ];
            final missingFields = requiredFields
                .where((field) => !dataMap.containsKey(field))
                .toList();

            if (missingFields.isNotEmpty) {
              AppLogger.e('❌ MISSING REQUIRED FIELDS: ${missingFields.join(', ')}');
            } else {
              AppLogger.i('✅ All required fields are present in the request body');
            }

            // Check if there are any unexpected fields
            final unexpectedFields = dataMap.keys
                .where((key) => !requiredFields.contains(key))
                .toList();
            if (unexpectedFields.isNotEmpty) {
              AppLogger.w('⚠️ UNEXPECTED FIELDS IN BODY: ${unexpectedFields.join(', ')}');
            }
          }
        }

        // Check query parameters - should be empty for OAuth
        if (options.queryParameters.isNotEmpty) {
          AppLogger.e('❌ QUERY PARAMETERS FOUND! OAuth should only use form body:');
          AppLogger.e('${options.queryParameters}');
        } else {
          AppLogger.i('✅ No query parameters (correct for OAuth)');
        }
      }

      // Log the actual curl command based on the request (only if detailed logging enabled)
      if (_enableDetailedLogging) {
        // Log the actual curl command based on the request
        var curl = 'curl -X ${options.method.toUpperCase()} "$uri"';

        // Add headers
        options.headers.forEach((key, value) {
          curl += ' \\\n  -H "$key: ${_redactHeaderValue(key, value)}"';
        });

        // Add data if present
        if (options.data != null) {
          if (options.contentType?.toLowerCase().contains('application/x-www-form-urlencoded') ==
              true) {
            // For form-urlencoded, format as form data
            if (options.data is Map) {
              final redactedData = _redactSensitiveData(options.data);
              final formData = redactedData.entries
                  .map((e) => "${e.key}=${Uri.encodeComponent(e.value.toString())}")
                  .join('&');
              curl += " \\\n  -d \"$formData\"";
            } else {
              curl += " \\\n  -d \"${options.data.toString()}\"";
            }
          } else if (options.data is Map || options.data is List) {
            final redactedData = options.data is Map
                ? _redactSensitiveData(options.data)
                : options.data;
            final prettyJson = const JsonEncoder.withIndent('  ').convert(redactedData);
            curl += " \\\n  -d '$prettyJson'";
          } else if (options.data is String) {
            curl += " \\\n  -d '${options.data.toString()}'";
          } else {
            curl += " \\\n  -d '${options.data.toString()}'";
          }
        }

        curl += ' \\\n  -v';

        AppLogger.i('🟢 ACTUAL CURL COMMAND FROM REQUEST:');
        AppLogger.i(curl);
        AppLogger.i('---');
      }
    } catch (e) {
      AppLogger.e('Error creating curl command', e);
    }
  }

  /// Log detailed request information
  void _logDetailedRequest(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.writeln(
      '┌── HTTP Request ─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ URL: ${options.uri}');
    buffer.writeln('│ Method: ${options.method}');
    buffer.writeln('│ Content-Type: ${options.contentType}');
    buffer.writeln('│ Headers:');
    options.headers.forEach((key, value) {
      buffer.writeln('│   $key: ${_redactHeaderValue(key, value)}');
    });

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query Parameters:');
      options.queryParameters.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }

    if (options.data != null) {
      buffer.writeln('│ Request Body:');
      if (options.data is Map || options.data is List) {
        try {
          final redactedData = options.data is Map
              ? _redactSensitiveData(options.data)
              : options.data;
          final prettyJson = const JsonEncoder.withIndent('  ').convert(redactedData);
          prettyJson.split('\n').forEach((line) {
            buffer.writeln('│   $line');
          });
        } catch (e) {
          buffer.writeln('│   ${options.data}');
        }
      } else {
        buffer.writeln('│   ${options.data}');
      }
    }

    buffer.writeln(
      '└─────────────────────────────────────────────────────────────────────────────',
    );
    AppLogger.i(buffer.toString());
  }

  /// Log detailed response information
  void _logDetailedResponse(Response response) {
    final buffer = StringBuffer();
    buffer.writeln(
      '┌── HTTP Response ────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ URL: ${response.requestOptions.uri}');
    buffer.writeln('│ Status Code: ${response.statusCode}');
    buffer.writeln('│ Status Message: ${response.statusMessage}');
    buffer.writeln('│ Headers:');
    response.headers.forEach((name, values) {
      buffer.writeln('│   $name: ${values.join(', ')}');
    });

    if (response.data != null) {
      buffer.writeln('│ Response Body:');
      if (response.data is Map || response.data is List) {
        try {
          final prettyJson = const JsonEncoder.withIndent('  ').convert(response.data);
          prettyJson.split('\n').forEach((line) {
            buffer.writeln('│   $line');
          });
        } catch (e) {
          buffer.writeln('│   ${response.data}');
        }
      } else {
        buffer.writeln('│   ${response.data}');
      }
    }

    buffer.writeln(
      '└─────────────────────────────────────────────────────────────────────────────',
    );
    AppLogger.i(buffer.toString());
  }

  /// Log detailed error information
  void _logDetailedError(DioException err) {
    final buffer = StringBuffer();
    buffer.writeln(
      '┌── HTTP Error ───────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ URL: ${err.requestOptions.uri}');
    buffer.writeln('│ Error Type: ${err.type}');
    buffer.writeln('│ Error Message: ${err.message}');

    if (err.response != null) {
      buffer.writeln('│ Status Code: ${err.response?.statusCode}');
      buffer.writeln('│ Status Message: ${err.response?.statusMessage}');

      if (err.response?.headers != null) {
        buffer.writeln('│ Headers:');
        err.response?.headers.forEach((name, values) {
          buffer.writeln('│   $name: ${values.join(', ')}');
        });
      }

      if (err.response?.data != null) {
        buffer.writeln('│ Error Response Data:');
        if (err.response?.data is Map || err.response?.data is List) {
          try {
            final prettyJson = const JsonEncoder.withIndent('  ').convert(err.response?.data);
            prettyJson.split('\n').forEach((line) {
              buffer.writeln('│   $line');
            });
          } catch (e) {
            buffer.writeln('│   ${err.response?.data}');
          }
        } else {
          buffer.writeln('│   ${err.response?.data}');
        }
      }
    }

    if (err.error != null) {
      buffer.writeln('│ Underlying Error: ${err.error}');
    }

    buffer.writeln(
      '└─────────────────────────────────────────────────────────────────────────────',
    );
    AppLogger.e(buffer.toString());
  }
}
