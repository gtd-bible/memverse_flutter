import 'package:dio/dio.dart';
import 'package:mini_memverse/src/common/interceptors/curl_logging_interceptor.dart';

/// Utility class for testing auth-related functionality
///
/// This class provides shared utilities for testing authentication flows with
/// the actual app code but without the Flutter app context.
///
/// Usage examples:
///
/// 1. Create a Dio instance with logging:
///    ```dart
///    final dio = AuthTestUtils.createDioWithLogging();
///    ```
///
/// 2. Extract CSRF token from HTML:
///    ```dart
///    final csrfToken = AuthTestUtils.extractCsrfToken(htmlContent);
///    ```
///
/// 3. Create form data for signup:
///    ```dart
///    final formData = AuthTestUtils.createSignupFormData(
///      email: 'test@example.com',
///      password: 'test123',
///      clientId: 'client_id',
///      clientSecret: 'client_secret',
///    );
///    ```
///
/// 4. Extract error message from OAuth error:
///    ```dart
///    try {
///      // API call
///    } catch (e) {
///      if (e is DioException) {
///        final errorMessage = AuthTestUtils.extractOAuthError(e);
///        print('Error: $errorMessage');
///      }
///    }
///    ```
class AuthTestUtils {
  /// Creates a configured Dio instance with logging for auth tests
  static Dio createDioWithLogging({bool verbose = true}) {
    final dio = Dio();

    // Add curl logging to see exactly what's sent in curl format
    dio.interceptors.add(CurlLoggingInterceptor());

    // Add detailed request/response logging
    if (verbose) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            print('🚀 Request: ${options.method} ${options.uri}');
            print('📝 Headers: ${options.headers}');
            print('📦 Data: ${options.data}');
            print('📋 Content-Type: ${options.contentType}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            print('✅ Response: ${response.statusCode}');
            print('📝 Response Headers: ${response.headers}');
            print('📦 Response Data: ${response.data}');
            handler.next(response);
          },
          onError: (error, handler) {
            print('❌ Error: ${error.message}');
            print('🔍 Request: ${error.requestOptions.method} ${error.requestOptions.uri}');
            print('📝 Request Headers: ${error.requestOptions.headers}');
            print('📦 Request Data: ${error.requestOptions.data}');
            if (error.response != null) {
              print('📥 Error Response: ${error.response?.data}');
              print('🔢 Status Code: ${error.response?.statusCode}');
            }
            handler.next(error);
          },
        ),
      );
    }

    // Configure default settings
    dio.options.validateStatus = (status) => true; // Accept any status code
    dio.options.followRedirects = true;

    return dio;
  }

  /// Extracts a CSRF token from HTML content
  static String? extractCsrfToken(String htmlContent) {
    final csrfMatch = RegExp(r'csrf-token"\s+content="([^"]+)"').firstMatch(htmlContent);
    return csrfMatch?.group(1);
  }

  /// Safely gets a string value from an environment variable
  static String? getEnvString(String name) {
    return String.fromEnvironment(name, defaultValue: '');
  }

  /// Creates a signup form data payload
  static Map<String, dynamic> createSignupFormData({
    required String email,
    required String password,
    required String clientId,
    required String clientSecret,
    String firstName = 'Test',
    String lastName = 'User',
  }) {
    return {
      'user[email]': email,
      'user[password]': password,
      'user[password_confirmation]': password,
      'user[first_name]': firstName,
      'user[last_name]': lastName,
      'client_id': clientId,
      'client_secret': clientSecret,
    };
  }

  /// Safely redacts sensitive information for logging
  static String redactSensitiveData(String key, dynamic value) {
    if (key.toLowerCase().contains('token') ||
        key.toLowerCase().contains('secret') ||
        key.toLowerCase().contains('password')) {
      if (value is String && value.isNotEmpty) {
        return '${value.substring(0, 5)}...';
      }
      return '[REDACTED]';
    }
    return value.toString();
  }

  /// Handles OAuth error responses and extracts error messages
  static String extractOAuthError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      return data['error_description'] ??
          data['error'] ??
          data['message'] ??
          e.message ??
          'Unknown error';
    }
    return e.message ?? 'Unknown error';
  }

  /// Create a test data profile with appropriate values for Auth tests
  static Map<String, String> createTestProfile({
    String username = 'test_user',
    String email = 'test@example.com',
    String firstName = 'Test',
    String lastName = 'User',
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return {
      'username': '${username}_$timestamp',
      'email': '${timestamp}_$email',
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  /// Parse response data and return a readable summary
  static Map<String, dynamic> summarizeAuthResponse(dynamic responseData) {
    final result = <String, dynamic>{};

    if (responseData is Map) {
      // Extract OAuth token data
      if (responseData['access_token'] != null) {
        result['token'] = redactSensitiveData('access_token', responseData['access_token']);
        result['token_type'] = responseData['token_type'];
        result['expires_in'] = responseData['expires_in'];
      }

      // Extract user data if present
      if (responseData['user'] != null) {
        result['user_id'] = responseData['user']['id'];
        result['email'] = responseData['user']['email'];
      }

      // Extract error data if present
      if (responseData['error'] != null) {
        result['error'] = responseData['error'];
        result['error_description'] = responseData['error_description'];
      }
    }

    return result;
  }

  /// Test if credentials are valid by making a call to the /me endpoint
  static Future<bool> testCredentials(Dio dio, String accessToken) async {
    try {
      final response = await dio.get(
        'https://www.memverse.com/api/v1/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
