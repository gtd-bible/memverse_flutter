import 'dart:convert';
import 'dart:io';

/// DEVELOPMENT UTILITY: Test Memverse OAuth API sign-in and verse fetching
/// This script is safe to commit to public repos as it uses environment variables.
///
/// USAGE: Set environment variables, then run:
///   export MEMVERSE_CLIENT_ID="your_client_id"
///   export MEMVERSE_CLIENT_API_KEY="your_api_key"
///   export MEMVERSE_USERNAME="your_username"
///   export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT="your_password"
///   dart test_api_signin.dart
///
/// SECURITY: No secrets are hardcoded - all sensitive data comes from env vars
void main() async {
  // Get environment variables
  final clientId = Platform.environment['MEMVERSE_CLIENT_ID'];
  final clientSecret = Platform.environment['MEMVERSE_CLIENT_API_KEY'];
  final username = Platform.environment['MEMVERSE_USERNAME'];
  final password = Platform.environment['MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT'];

  if (clientId == null || clientSecret == null || username == null || password == null) {
    print('❌ Missing environment variables');
    print(
      'Required: MEMVERSE_CLIENT_ID, MEMVERSE_CLIENT_API_KEY, MEMVERSE_USERNAME, MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT',
    );
    print('\n🔧 Set them like:');
    print('  export MEMVERSE_CLIENT_ID="your_client_id"');
    print('  export MEMVERSE_CLIENT_API_KEY="your_api_key"');
    print('  export MEMVERSE_USERNAME="your_username"');
    print('  export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT="your_password"');
    exit(1);
  }

  print('🔧 [DEBUG] Testing Memverse OAuth API sign-in and verse fetching...');
  print('[DEBUG] Client ID: ${clientId.substring(0, 8)}...');
  print('[DEBUG] Username: $username');

  // Create HTTP client
  final client = HttpClient();
  String? accessToken;
  String? tokenType;

  try {
    // Step 1: Authenticate
    print('\n🔐 [DEBUG] Step 1: Authentication');
    final authRequest = await client.postUrl(Uri.parse('https://www.memverse.com/oauth/token'));
    authRequest.headers.set('Content-Type', 'application/x-www-form-urlencoded');

    // Form data - SENSITIVE: Password is redacted in logs
    final formData =
        'grant_type=password&username=$username&password=$password&client_id=$clientId&client_secret=$clientSecret';
    authRequest.write(formData);

    print('[DEBUG] 📤 Sending OAuth request...');

    // Send auth request
    final authResponse = await authRequest.close();

    print('[DEBUG] 📥 Auth Response status: ${authResponse.statusCode}');

    // Read auth response
    final authResponseBody = await authResponse.transform(utf8.decoder).join();
    final authJson = json.decode(authResponseBody);

    if (authResponse.statusCode == 200) {
      accessToken = authJson['access_token'];
      tokenType = authJson['token_type'];
      print('[DEBUG] ✅ Sign-in successful!');
      print('[DEBUG] Access Token: ${accessToken?.substring(0, 20)}...');
      print('[DEBUG] Token Type: $tokenType');
    } else {
      print('[DEBUG] ❌ Sign-in failed');
      print('[DEBUG] Error: ${authJson['error_description'] ?? authJson['error']}');
      exit(1);
    }

    // Step 2: Fetch verses
    print('\n📖 [DEBUG] Step 2: Fetching verses');
    if (accessToken != null && tokenType != null) {
      final versesRequest = await client.getUrl(
        Uri.parse('https://www.memverse.com/api/v1/memverses?sort=2'),
      );
      versesRequest.headers.set('Authorization', '$tokenType $accessToken');
      versesRequest.headers.set('Accept', 'application/json');

      print('[DEBUG] 📤 Sending verses request...');

      // Send verses request
      final versesResponse = await versesRequest.close();

      print('[DEBUG] 📥 Verses Response status: ${versesResponse.statusCode}');

      if (versesResponse.statusCode == 200) {
        // Read verses response
        final versesResponseBody = await versesResponse.transform(utf8.decoder).join();
        final versesJson = json.decode(versesResponseBody);

        if (versesJson['response'] is List && versesJson['response'].isNotEmpty) {
          final firstVerse = versesJson['response'][0];
          print('[DEBUG] ✅ Verses fetched successfully!');
          print('[DEBUG] 📊 Total verses: ${versesJson['response'].length}');

          // DEBUG OUTPUT: Print the text of the first verse
          print('\n🎯 [DEBUG] FIRST VERSE TEXT:');
          print('[DEBUG] Reference: ${firstVerse['reference'] ?? firstVerse['ref'] ?? 'Unknown'}');
          print('[DEBUG] Text: ${firstVerse['text'] ?? 'No text available'}');
          print('[DEBUG] Translation: ${firstVerse['translation'] ?? 'Unknown'}');

          // Also print a sample of the raw response for debugging
          print('\n🔍 [DEBUG] First verse raw data (complete):');
          for (final key in firstVerse.keys) {
            final value = firstVerse[key];
            // Redact sensitive data in debug output
            final displayValue =
                key.toString().toLowerCase().contains('token') ||
                    key.toString().toLowerCase().contains('secret') ||
                    key.toString().toLowerCase().contains('password')
                ? '[REDACTED]'
                : value.toString();
            print('[DEBUG]   $key: $displayValue');
          }
        } else {
          print('[DEBUG] ❌ No verses found in response');
        }
      } else {
        print('[DEBUG] ❌ Verses request failed');
        final errorBody = await versesResponse.transform(utf8.decoder).join();
        print('[DEBUG] Error response: $errorBody');
      }
    }
  } catch (e) {
    print('[DEBUG] ❌ Request failed: $e');
  } finally {
    client.close();
  }

  print('\n🎯 [DEBUG] API testing complete - Full authentication + verse fetching verified!');
}
