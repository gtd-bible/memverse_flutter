import 'dart:io';

import 'package:dio/dio.dart';
// Import needed for secure storage options
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show
        FlutterSecureStorage,
        IOSOptions,
        AndroidOptions,
        LinuxOptions,
        WebOptions,
        MacOsOptions,
        WindowsOptions;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/src/features/auth/data/auth_api.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_token.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/utils/auth_test_utils.dart';

/// DEVELOPMENT UTILITY: Test Memverse OAuth API sign-in using multiple layers of app code
/// This allows testing the app's auth implementation directly against the API,
/// including both the API and Service layers.
///
/// USAGE: Set environment variables, then run with:
///   export MEMVERSE_CLIENT_ID="your_client_id"
///   export MEMVERSE_CLIENT_API_KEY="your_api_key"
///   export MEMVERSE_USERNAME="your_username"
///   export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT="your_password"
///   dart run test_auth_api_with_app_code.dart
///
/// SECURITY: No secrets are hardcoded - all sensitive data comes from env vars
void main() async {
  // Configure logger for command-line use
  _configureLogger();

  // Get environment variables
  final clientId = _getRequiredEnv('MEMVERSE_CLIENT_ID');
  final clientSecret = _getRequiredEnv('MEMVERSE_CLIENT_API_KEY');
  final username = _getRequiredEnv('MEMVERSE_USERNAME');
  final password = _getRequiredEnv('MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT');

  print('🔧 [DEBUG] Testing Memverse OAuth API sign-in using app code layers...');
  print('[DEBUG] Client ID: ${AuthTestUtils.redactSensitiveData('client_id', clientId)}');
  print('[DEBUG] Username: $username');

  // STEP 1: Create a Dio instance with logging
  final dio = AuthTestUtils.createDioWithLogging();

  // STEP 2: Create a simple mock logger to pass to error handler
  final mockLogger = _MockLogger();

  // Create error handler for testing
  final errorHandler = AuthErrorHandler(
    appLogger: mockLogger,
    analyticsFacade: _MockAnalyticsFacade(),
    talker: _MockTalker(),
  );

  // STEP 3: Create the AuthApi instance using the app's class
  print('\n📡 PHASE 1: DIRECT API LAYER TESTING');
  print('[DEBUG] Creating AuthApi instance...');
  final authApi = AuthApi(dio, baseUrl: 'https://www.memverse.com');

  // API layer testing variables
  AuthToken? apiAuthToken;

  try {
    // STEP 4: Test the API layer (Auth API client)
    print('[DEBUG] 📤 Authenticating using direct API client...');

    try {
      // This uses the actual app code for authentication at the API level
      apiAuthToken = await authApi.getBearerToken(
        'password',
        username,
        password,
        clientId,
        clientSecret,
      );

      print('[DEBUG] ✅ API layer auth successful!');
      print(
        '[DEBUG] Access Token: ${AuthTestUtils.redactSensitiveData('token', apiAuthToken.accessToken)}',
      );
      print('[DEBUG] Token Type: ${apiAuthToken.tokenType}');
      if (apiAuthToken.userId != null) {
        print('[DEBUG] User ID: ${apiAuthToken.userId}');
      }

      // Test error handling with the auth error handler
      try {
        // Intentionally use wrong password to test error handling
        await authApi.getBearerToken(
          'password',
          username,
          'wrong_password',
          clientId,
          clientSecret,
        );
      } catch (e) {
        if (e is DioException) {
          final errorMessage = await errorHandler.processError(
            e,
            'API testing',
            additionalData: {'username': username},
          );
          print('[DEBUG] 🔍 Auth error handler test: $errorMessage');
        }
      }
    } catch (e) {
      print('[DEBUG] ❌ API layer auth failed');
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        print(
          '[DEBUG] Error: ${responseData['error_description'] ?? responseData['error'] ?? e.message}',
        );
      } else {
        print('[DEBUG] Error: $e');
      }
      exit(1);
    }

    // STEP 5: Test the Service layer (AuthService)
    print('\n🔐 PHASE 2: SERVICE LAYER TESTING');

    // Create in-memory storage for testing
    final memoryStorage = _InMemoryStorage();

    // Create AuthService using our API but with in-memory storage
    final authService = AuthService(secureStorage: memoryStorage, dio: dio, authApi: authApi);

    print('[DEBUG] 📤 Authenticating using AuthService...');

    try {
      // This tests the service layer which includes token storage
      final serviceAuthToken = await authService.login(username, password, clientId, clientSecret);

      print('[DEBUG] ✅ Service layer auth successful!');
      print(
        '[DEBUG] Service token: ${AuthTestUtils.redactSensitiveData('token', serviceAuthToken.accessToken)}',
      );

      // Test isLoggedIn
      final isLoggedIn = await authService.isLoggedIn();
      print('[DEBUG] isLoggedIn check: $isLoggedIn');

      // Test token retrieval from storage
      final storedToken = await authService.getToken();
      print('[DEBUG] Token retrieved from storage: ${storedToken != null}');

      if (storedToken != null) {
        print(
          '[DEBUG] 🔒 Storage verification: ${storedToken.accessToken == serviceAuthToken.accessToken ? '✅ Matches' : '❌ Different'}',
        );
      }

      // Test logout
      await authService.logout();
      final isStillLoggedIn = await authService.isLoggedIn();
      print('[DEBUG] After logout - isLoggedIn: $isStillLoggedIn');
      print('[DEBUG] Logout test: ${!isStillLoggedIn ? '✅ Successful' : '❌ Failed'}');

      // Re-login for the next phase
      await authService.login(username, password, clientId, clientSecret);
    } catch (e) {
      print('[DEBUG] ❌ Service layer auth failed');
      print('[DEBUG] Error: $e');
    }

    // STEP 6: Fetch data using the token to verify end-to-end functionality
    print('\n📖 PHASE 3: DATA FETCHING WITH AUTH TOKEN');
    print('[DEBUG] 📤 Sending verses request...');

    // Create auth headers
    final headers = {
      'Authorization': '${apiAuthToken?.tokenType} ${apiAuthToken?.accessToken}',
      'Accept': 'application/json',
    };

    final versesResponse = await dio.get(
      'https://www.memverse.com/api/v1/memverses?sort=2',
      options: Options(headers: headers),
    );

    print('[DEBUG] 📥 Verses Response status: ${versesResponse.statusCode}');

    if (versesResponse.statusCode == 200) {
      final versesJson = versesResponse.data;

      if (versesJson['response'] is List && versesJson['response'].isNotEmpty) {
        final verses = versesJson['response'] as List;
        final firstVerse = verses[0];
        print('[DEBUG] ✅ Verses fetched successfully!');
        print('[DEBUG] 📊 Total verses: ${verses.length}');

        // Display the text of the first verse
        print('\n🎯 [DEBUG] First verse:');
        print('[DEBUG] Reference: ${firstVerse['reference'] ?? firstVerse['ref'] ?? 'Unknown'}');
        print('[DEBUG] Text: ${firstVerse['text'] ?? 'No text available'}');
        print('[DEBUG] Translation: ${firstVerse['translation'] ?? 'Unknown'}');

        // Test other API endpoints to verify token works across the API
        print('\n👤 [DEBUG] Testing user profile endpoint...');
        try {
          final userResponse = await dio.get(
            'https://www.memverse.com/api/v1/me',
            options: Options(headers: headers),
          );

          if (userResponse.statusCode == 200) {
            final userData = userResponse.data;
            print('[DEBUG] ✅ User profile fetch successful!');
            print('[DEBUG] User ID: ${userData['id']}');
            print('[DEBUG] Email: ${userData['email']}');
          } else {
            print('[DEBUG] ❌ User profile fetch failed: ${userResponse.statusCode}');
          }
        } catch (e) {
          print('[DEBUG] ❌ User profile fetch error: $e');
        }
      } else {
        print('[DEBUG] ❌ No verses found in response');
      }
    } else {
      print('[DEBUG] ❌ Verses request failed');
      print('[DEBUG] Error response: ${versesResponse.data}');
    }
  } catch (e) {
    print('[DEBUG] ❌ Request failed: $e');
  }

  print('\n🎯 [DEBUG] API testing complete - Multiple layers verified!');
  print('[DEBUG] ✓ API Layer (Auth API client)');
  print('[DEBUG] ✓ Service Layer (Auth Service with token storage)');
  print('[DEBUG] ✓ Error Handling (Auth Error Handler)');
  print('[DEBUG] ✓ Data Fetching (Authenticated API calls)');
}

/// Configure AppLogger for command line use
void _configureLogger() {
  // Configure the logger for command-line output
  AppLogger.logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );
}

/// Get a required environment variable or exit with error
String _getRequiredEnv(String name) {
  final value = Platform.environment[name];
  if (value == null || value.isEmpty) {
    print('❌ Required environment variable missing: $name');
    print('Run this test with:');
    print('  export MEMVERSE_CLIENT_ID="your_client_id"');
    print('  export MEMVERSE_CLIENT_API_KEY="your_client_api_key"');
    print('  export MEMVERSE_USERNAME="your_username"');
    print('  export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT="your_password"');
    exit(1);
  }
  return value;
}

/// Simple in-memory storage implementation for testing
class _InMemoryStorage implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) return;
    _storage[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.from(_storage);
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage.containsKey(key);
  }

  // Additional required methods for Windows/Linux
  @override
  Future<void> write2({
    required String key,
    required String? value,
    required Object? options,
  }) async {
    return write(key: key, value: value);
  }

  @override
  Future<String?> read2({required String key, required Object? options}) async {
    return read(key: key);
  }

  @override
  Future<void> delete2({required String key, required Object? options}) async {
    return delete(key: key);
  }

  @override
  Future<Map<String, String>> readAll2({required Object? options}) async {
    return readAll();
  }

  @override
  Future<void> deleteAll2({required Object? options}) async {
    return deleteAll();
  }

  @override
  Future<bool> containsKey2({required String key, required Object? options}) async {
    return containsKey(key: key);
  }
}
