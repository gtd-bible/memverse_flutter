import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mini_memverse/src/features/auth/data/auth_api.dart';
import 'package:mini_memverse/src/utils/auth_test_utils.dart';

/// DEVELOPMENT UTILITY: Test Memverse API sign-up using the app code
/// This allows testing the app's registration functionality directly with the API.
///
/// USAGE: Set environment variables, then run:
///   export MEMVERSE_CLIENT_ID="your_client_id"
///   export MEMVERSE_CLIENT_API_KEY="your_api_key"
///   export MEMVERSE_TEST_EMAIL="test_user@example.com"
///   export MEMVERSE_TEST_PASSWORD="test_password"
///   export MEMVERSE_TEST_FIRST_NAME="Test"  (optional)
///   export MEMVERSE_TEST_LAST_NAME="User"   (optional)
///   dart test_signup_api_with_app_code.dart
///
/// SECURITY: No secrets are hardcoded - all sensitive data comes from env vars
void main() async {
  // Get environment variables
  final clientId = Platform.environment['MEMVERSE_CLIENT_ID'];
  final clientSecret = Platform.environment['MEMVERSE_CLIENT_API_KEY'];
  final testEmail =
      Platform.environment['MEMVERSE_TEST_EMAIL'] ?? 'neilwarner+unverified@gmail.com';
  final testPassword = Platform.environment['MEMVERSE_TEST_PASSWORD'];
  final firstName = Platform.environment['MEMVERSE_TEST_FIRST_NAME'] ?? 'Test';
  final lastName = Platform.environment['MEMVERSE_TEST_LAST_NAME'] ?? 'User';

  if (clientId == null || clientSecret == null || testPassword == null) {
    print('❌ Missing environment variables');
    print('Required: MEMVERSE_CLIENT_ID, MEMVERSE_CLIENT_API_KEY, MEMVERSE_TEST_PASSWORD');
    print('Optional: MEMVERSE_TEST_EMAIL, MEMVERSE_TEST_FIRST_NAME, MEMVERSE_TEST_LAST_NAME');
    print('\n🔧 Set them like:');
    print('  export MEMVERSE_CLIENT_ID="your_client_id"');
    print('  export MEMVERSE_CLIENT_API_KEY="your_api_key"');
    print('  export MEMVERSE_TEST_EMAIL="test_user@example.com"');
    print('  export MEMVERSE_TEST_PASSWORD="test_password"');
    exit(1);
  }

  print('🔧 [DEBUG] Testing Memverse API sign-up using app code...');
  print('[DEBUG] Client ID: ${clientId.substring(0, 8)}...');
  print('[DEBUG] Test Email: $testEmail');

  // STEP 1: Create a Dio instance with logging
  final dio = AuthTestUtils.createDioWithLogging();

  // STEP 2: Create the AuthApi instance using the app's class
  print('\n🔐 [DEBUG] Creating AuthApi instance...');
  final authApi = AuthApi(dio, baseUrl: 'https://www.memverse.com');

  try {
    // STEP 3: Attempt to get signup endpoint by examining the signup page
    print('\n📝 [DEBUG] Step 1: Examining signup form to determine the correct endpoint');

    final signupPageResponse = await dio.get('https://www.memverse.com/user/new');
    print('[DEBUG] 📥 Signup page response status: ${signupPageResponse.statusCode}');

    // Determine the correct endpoint from the response
    // (This would typically be in the app code in a real implementation)
    String signupEndpoint = 'https://www.memverse.com/users';

    if (signupPageResponse.data.toString().contains('action="/users"')) {
      signupEndpoint = 'https://www.memverse.com/users';
      print('[DEBUG] 🔎 Found signup endpoint: $signupEndpoint');
    } else if (signupPageResponse.data.toString().contains('action="/user/create"')) {
      signupEndpoint = 'https://www.memverse.com/user/create';
      print('[DEBUG] 🔎 Found signup endpoint: $signupEndpoint');
    } else if (signupPageResponse.data.toString().contains('action="/api/v1/users"')) {
      signupEndpoint = 'https://www.memverse.com/api/v1/users';
      print('[DEBUG] 🔎 Found signup endpoint: $signupEndpoint');
    } else {
      print('[DEBUG] ⚠️ Could not determine exact signup endpoint, using default: $signupEndpoint');
    }

    // STEP 4: Extract CSRF token if present
    final responseText = signupPageResponse.data.toString();
    final csrfToken = AuthTestUtils.extractCsrfToken(responseText);

    if (csrfToken != null) {
      print('[DEBUG] 🔑 Found CSRF token: ${csrfToken.substring(0, 10)}...');
    } else {
      print('[DEBUG] ⚠️ No CSRF token found');
    }

    // STEP 5: Submit the signup form
    print('\n📝 [DEBUG] Step 2: Submitting signup form');

    final formData = {
      'user[email]': testEmail,
      'user[password]': testPassword,
      'user[password_confirmation]': testPassword,
      'user[first_name]': firstName,
      'user[last_name]': lastName,
      'client_id': clientId,
      'client_secret': clientSecret,
    };

    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};

    if (csrfToken != null) {
      headers['X-CSRF-Token'] = csrfToken;
    }

    print('[DEBUG] 📤 Sending signup request to $signupEndpoint');

    Response<dynamic> signupResponse;
    try {
      signupResponse = await dio.post(
        signupEndpoint,
        data: formData,
        options: Options(
          headers: headers,
          followRedirects: true,
          validateStatus: (status) => true, // Accept any status code
        ),
      );

      print('[DEBUG] 📥 Signup response status: ${signupResponse.statusCode}');

      // Check for success indicators in the response
      final responseBody = signupResponse.data.toString();
      
      // Check for success status code (200-299)
      final bool successByStatus = false; // Ignore status code temporarily
      if (successByStatus ||
          responseBody.contains('success') ||
          responseBody.contains('successfully') ||
          responseBody.contains('created')) {
        print('[DEBUG] ✅ Signup appears successful based on response');
      } else if (responseBody.contains('error') ||
          responseBody.contains('already exists') ||
          responseBody.contains('taken')) {
        print(
          '[DEBUG] ⚠️ Signup may have failed - account may already exist or there was an error',
        );
      }
    } catch (e) {
      print('[DEBUG] ❌ Signup request failed: $e');
    }

    // STEP 6: Try to authenticate with the newly created account
    print('\n🔐 [DEBUG] Step 3: Attempting to authenticate with new account');

    try {
      final authToken = await authApi.getBearerToken(
        'password',
        testEmail,
        testPassword,
        clientId,
        clientSecret,
      );

      print('[DEBUG] ✅ Authentication successful with new account!');
      print('[DEBUG] Access Token: ${authToken.accessToken.substring(0, 20)}...');
      print('[DEBUG] Token Type: ${authToken.tokenType}');
      if (authToken.userId != null) {
        print('[DEBUG] User ID: ${authToken.userId}');
      }

      print('[DEBUG] ✨ Full signup and authentication flow successful!');
    } catch (e) {
      print('[DEBUG] ℹ️ Authentication failed with new account');
      if (e is DioException) {
        final errorMessage = AuthTestUtils.extractOAuthError(e);
        print('[DEBUG] Error: $errorMessage');

        if (errorMessage.toString().contains('unconfirmed') ||
            errorMessage.toString().contains('verify') ||
            errorMessage.toString().contains('confirm')) {
          print('[DEBUG] 📧 Email verification appears to be required');
        }
      } else {
        print('[DEBUG] Error: $e');
      }
    }
  } catch (e) {
    print('[DEBUG] ❌ Overall request failed: $e');
  }

  print('\n🎯 [DEBUG] API signup testing complete!');
}
