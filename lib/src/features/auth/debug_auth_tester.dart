// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Simple, direct auth test using raw Dio (no Retrofit)
/// This lets us bypass any Retrofit-generated code issues and
/// directly compare with the working curl command
class DebugAuthTester {
  /// Test authentication with direct Dio client
  /// This bypasses Retrofit and makes a direct API call
  static Future<void> testDirectAuth({
    required String username,
    required String password,
    required String clientId,
    required String clientSecret,
  }) async {
    print('\n=== 🧪 DIRECT AUTH TEST ===');
    print('Testing with direct Dio client (no Retrofit)');

    try {
      // 1. Create a fresh Dio instance
      final dio = Dio();

      // 2. Configure it exactly like the working curl command
      dio.options.baseUrl = 'https://www.memverse.com';
      dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      dio.options.validateStatus = (_) => true; // Accept any status code for debugging

      // 3. Log the request we're about to make
      print('🚀 Making request to: ${dio.options.baseUrl}/oauth/token');
      print('📋 Content-Type: ${dio.options.headers['Content-Type']}');

      // 4. Prepare form data exactly like curl
      final formData = {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'client_id': clientId,
        'client_secret': clientSecret,
      };

      print('📦 Request Body: $formData');

      // 5. Send the request
      print('⏳ Sending request...');
      final response = await dio.post(
        '/oauth/token',
        data: formData,
        // No query parameters!
      );

      // 6. Check response
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ AUTH SUCCESS! Response looks good.');
      } else {
        print('❌ AUTH FAILED with status ${response.statusCode}');
      }

      // 7. Generate curl command for comparison
      final curlCommand =
          '''
curl -X POST "https://www.memverse.com/oauth/token" \\
  -H "Content-Type: application/x-www-form-urlencoded" \\
  -d "grant_type=password&username=$username&password=[REDACTED]&client_id=$clientId&client_secret=$clientSecret" \\
  -v
''';

      print('\n📋 EQUIVALENT CURL COMMAND:');
      print(curlCommand);
    } catch (e, stackTrace) {
      print('❌ ERROR during direct auth test: $e');
      print('Stack trace: $stackTrace');
    }

    print('=== 🧪 DIRECT AUTH TEST COMPLETE ===\n');
  }

  /// Test using actual curl command via Process
  /// This is the closest we can get to the working curl command
  static Future<void> testWithActualCurl({
    required String username,
    required String password,
    required String clientId,
    required String clientSecret,
  }) async {
    if (kIsWeb) {
      print('❌ Cannot run curl command in web mode');
      return;
    }

    print('\n=== 🧪 ACTUAL CURL TEST ===');
    print('Testing with actual curl command via Process');

    try {
      // 1. Create the curl command
      final command = 'curl';
      final args = [
        '-X',
        'POST',
        'https://www.memverse.com/oauth/token',
        '-H',
        'Content-Type: application/x-www-form-urlencoded',
        '-d',
        'grant_type=password&username=$username&password=$password&client_id=$clientId&client_secret=$clientSecret',
        '-v',
      ];

      // 2. Log what we're about to do
      print('🚀 Running curl command...');

      // 3. Run the curl command
      final process = await Process.run(command, args);

      // 4. Check results
      print('📤 Exit code: ${process.exitCode}');
      print('📤 Stdout: ${process.stdout}');

      if (process.exitCode != 0) {
        print('📤 Stderr: ${process.stderr}');
        print('❌ CURL FAILED with exit code ${process.exitCode}');
      } else {
        try {
          // Try to parse the JSON response from stdout
          final output = process.stdout.toString();
          final jsonStartIndex = output.lastIndexOf('{');
          final jsonEndIndex = output.lastIndexOf('}') + 1;

          if (jsonStartIndex >= 0 && jsonEndIndex > jsonStartIndex) {
            final jsonStr = output.substring(jsonStartIndex, jsonEndIndex);
            final responseJson = json.decode(jsonStr);
            print('✅ CURL SUCCESS! Parsed response: $responseJson');
          } else {
            print('⚠️ Could not find JSON response in curl output');
          }
        } catch (e) {
          print('⚠️ Could not parse JSON from curl response: $e');
        }
      }
    } catch (e, stackTrace) {
      print('❌ ERROR running curl command: $e');
      print('Stack trace: $stackTrace');
    }

    print('=== 🧪 ACTUAL CURL TEST COMPLETE ===\n');
  }
}
