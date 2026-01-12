import 'dart:convert';
import 'dart:io';

/// DEVELOPMENT UTILITY: Test Memverse API sign-up
/// This script is safe to commit to public repos as it uses environment variables.
///
/// USAGE: Set environment variables, then run:
///   export MEMVERSE_CLIENT_ID="your_client_id"
///   export MEMVERSE_CLIENT_API_KEY="your_api_key"
///   export MEMVERSE_TEST_EMAIL="neilwarner+unverified@gmail.com"
///   export MEMVERSE_TEST_PASSWORD="your_test_password"
///   export MEMVERSE_TEST_FIRST_NAME="Test"
///   export MEMVERSE_TEST_LAST_NAME="User"
///   dart test_api_signup.dart
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
    print('  export MEMVERSE_TEST_EMAIL="neilwarner+unverified@gmail.com"');
    print('  export MEMVERSE_TEST_PASSWORD="your_test_password"');
    print('  export MEMVERSE_TEST_FIRST_NAME="Test"');
    print('  export MEMVERSE_TEST_LAST_NAME="User"');
    exit(1);
  }

  print('🔧 [DEBUG] Testing Memverse API sign-up...');
  print('[DEBUG] Client ID: ${clientId.substring(0, 8)}...');
  print('[DEBUG] Test Email: $testEmail');

  // Create HTTP client
  final client = HttpClient();

  try {
    // Step 1: Create a new account
    print('\n📝 [DEBUG] Step 1: Creating a new account');

    // Since the signup endpoint might be different from the OAuth token one,
    // we'll first attempt to determine the correct endpoint
    print('[DEBUG] 🔍 Examining signup form to determine the correct endpoint...');

    final signupPageRequest = await client.getUrl(Uri.parse('https://www.memverse.com/user/new'));
    final signupPageResponse = await signupPageRequest.close();
    final signupPageContent = await signupPageResponse.transform(utf8.decoder).join();

    print('[DEBUG] 📥 Signup page response status: ${signupPageResponse.statusCode}');

    // Attempt to extract the form action URL from the signup page
    // This is a simple extraction and might need refinement
    String signupEndpoint = 'https://www.memverse.com/users';
    if (signupPageContent.contains('action="/users"')) {
      signupEndpoint = 'https://www.memverse.com/users';
      print('[DEBUG] 🔎 Found signup endpoint: $signupEndpoint');
    } else if (signupPageContent.contains('action="/user/create"')) {
      signupEndpoint = 'https://www.memverse.com/user/create';
      print('[DEBUG] 🔎 Found signup endpoint: $signupEndpoint');
    } else if (signupPageContent.contains('action="/api/v1/users"')) {
      signupEndpoint = 'https://www.memverse.com/api/v1/users';
      print('[DEBUG] 🔎 Found signup endpoint: $signupEndpoint');
    } else {
      print('[DEBUG] ⚠️ Could not determine exact signup endpoint, using default: $signupEndpoint');
    }

    // Now make the actual signup request
    print('[DEBUG] 📤 Sending signup request...');
    final signupRequest = await client.postUrl(Uri.parse(signupEndpoint));
    signupRequest.headers.set('Content-Type', 'application/x-www-form-urlencoded');

    // Form data for signup - format might need adjustment based on actual API
    final signupFormData =
        'user[email]=$testEmail&user[password]=$testPassword&user[password_confirmation]=$testPassword' +
        '&user[first_name]=$firstName&user[last_name]=$lastName' +
        '&client_id=$clientId&client_secret=$clientSecret';
    signupRequest.write(signupFormData);

    // Send signup request
    final signupResponse = await signupRequest.close();

    print('[DEBUG] 📥 Signup Response status: ${signupResponse.statusCode}');

    // Read response
    final signupResponseBody = await signupResponse.transform(utf8.decoder).join();
    print('[DEBUG] 📄 Raw Response Body: $signupResponseBody');

    // Try to parse the response as JSON, but handle if it's not JSON
    Map<String, dynamic> signupJson = {};
    try {
      signupJson = json.decode(signupResponseBody) as Map<String, dynamic>;
      print('[DEBUG] 📊 Parsed JSON Response: $signupJson');
    } catch (e) {
      print('[DEBUG] ⚠️ Response is not JSON. This might be expected if it returns HTML.');

      // Look for success indicators in non-JSON response
      if (signupResponseBody.contains('success') ||
          signupResponseBody.contains('successfully') ||
          signupResponseBody.contains('created') ||
          signupResponse.statusCode >= 200 && signupResponse.statusCode < 300) {
        print('[DEBUG] ✅ Signup appears successful based on response content or status code');
      } else if (signupResponseBody.contains('error') ||
          signupResponseBody.contains('already exists') ||
          signupResponseBody.contains('taken')) {
        print('[DEBUG] ❌ Signup failed - account may already exist or there was an error');
      }
    }

    // Step 2: Try to authenticate with the newly created account
    // This might work immediately or might require email verification first
    print('\n🔐 [DEBUG] Step 2: Attempting to authenticate with new account');
    final authRequest = await client.postUrl(Uri.parse('https://www.memverse.com/oauth/token'));
    authRequest.headers.set('Content-Type', 'application/x-www-form-urlencoded');

    // Form data for authentication
    final authFormData =
        'grant_type=password&username=$testEmail&password=$testPassword&client_id=$clientId&client_secret=$clientSecret';
    authRequest.write(authFormData);

    print('[DEBUG] 📤 Sending authentication request...');

    // Send auth request
    final authResponse = await authRequest.close();

    print('[DEBUG] 📥 Auth Response status: ${authResponse.statusCode}');

    // Read auth response
    final authResponseBody = await authResponse.transform(utf8.decoder).join();

    try {
      final authJson = json.decode(authResponseBody);

      if (authResponse.statusCode == 200) {
        final accessToken = authJson['access_token'];
        final tokenType = authJson['token_type'];
        print('[DEBUG] ✅ Authentication successful with new account!');
        print('[DEBUG] Access Token: ${accessToken.substring(0, 20)}...');
        print('[DEBUG] Token Type: $tokenType');

        // If we reach here, the account was created and is fully usable
      } else {
        print(
          '[DEBUG] ℹ️ Authentication failed, which might be expected if email verification is required',
        );
        print(
          '[DEBUG] Error: ${authJson['error_description'] ?? authJson['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('[DEBUG] ⚠️ Could not parse authentication response as JSON: $e');
      print('[DEBUG] Raw response: $authResponseBody');
    }
  } catch (e) {
    print('[DEBUG] ❌ Request failed: $e');
  } finally {
    client.close();
  }

  print('\n🎯 [DEBUG] API testing complete!');
}
