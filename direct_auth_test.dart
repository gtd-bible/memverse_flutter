import 'dart:convert';
import 'dart:io';

/// Direct authentication test that exactly matches the curl command
///
/// This test doesn't use Flutter or the app's code - it's a pure Dart test
/// that uses HttpClient to directly test the OAuth endpoint, just like the curl script.
void main() async {
  print('\n=== DIRECT AUTH TEST ===');

  // Get environment variables
  final clientId = Platform.environment['MEMVERSE_CLIENT_ID'];
  final clientSecret = Platform.environment['MEMVERSE_CLIENT_API_KEY'];
  final username = Platform.environment['MEMVERSE_USERNAME'];
  final password = Platform.environment['MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT'];

  // Validate credentials
  if (clientId == null || clientSecret == null || username == null || password == null) {
    print('❌ Missing environment variables');
    print(
      'Required: MEMVERSE_CLIENT_ID, MEMVERSE_CLIENT_API_KEY, MEMVERSE_USERNAME, MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT',
    );
    exit(1);
  }

  print('🔧 Testing Memverse OAuth API sign-in directly...');
  print('👤 Username: $username');
  print('🔑 Client ID: ${clientId.substring(0, 4)}...');

  // Create HTTP client
  final client = HttpClient();
  try {
    // Step 1: Authenticate
    print('\n🔐 Step 1: Authentication');
    final authRequest = await client.postUrl(Uri.parse('https://www.memverse.com/oauth/token'));

    // CRITICAL: Must set correct content type - exactly like the curl command
    authRequest.headers.set('Content-Type', 'application/x-www-form-urlencoded');

    // Form data - formatted exactly like the curl command
    final formData =
        'grant_type=password&username=$username&password=$password&client_id=$clientId&client_secret=$clientSecret';
    authRequest.write(formData);

    print('📤 Sending OAuth request with form-urlencoded data...');

    // Send auth request
    final authResponse = await authRequest.close();
    print('📥 Auth Response status: ${authResponse.statusCode}');

    // Read auth response
    final authResponseBody = await authResponse.transform(utf8.decoder).join();

    try {
      // Try to parse as JSON
      final authJson = json.decode(authResponseBody);

      if (authResponse.statusCode == 200) {
        final accessToken = authJson['access_token'];
        final tokenType = authJson['token_type'];

        print('✅ Sign-in successful!');
        print('🎫 Access Token: ${accessToken.substring(0, 20)}...');
        print('📊 Token Type: $tokenType');
        print('🎯 The authentication API request worked correctly!');

        // Step 2: Verify token by fetching verses
        print('\n📖 Step 2: Verifying token with a verse fetch');
        final versesRequest = await client.getUrl(
          Uri.parse('https://www.memverse.com/api/v1/memverses?sort=2'),
        );
        versesRequest.headers.set('Authorization', '$tokenType $accessToken');
        versesRequest.headers.set('Accept', 'application/json');

        print('📤 Sending verse request with token...');
        final versesResponse = await versesRequest.close();
        print('📥 Verse Response status: ${versesResponse.statusCode}');

        if (versesResponse.statusCode == 200) {
          print('✅ Successfully fetched verses with the token!');
          print('🎉 AUTHENTICATION TEST PASSED! This confirms the API is working correctly.');
        } else {
          print('❌ Failed to fetch verses. Status: ${versesResponse.statusCode}');
          exit(1);
        }
      } else {
        print('❌ Sign-in failed');
        print('Error: ${authJson['error_description'] ?? authJson['error']}');
        exit(1);
      }
    } catch (e) {
      print('❌ Failed to parse response as JSON: $e');
      print('Raw response: $authResponseBody');
      exit(1);
    }
  } catch (e) {
    print('❌ Request failed: $e');
    exit(1);
  } finally {
    client.close();
  }
}
