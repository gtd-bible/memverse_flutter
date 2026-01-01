import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mini_memverse/main.dart';

/// Simple script to load env.json and launch the app
/// Usage: flutter run --dart-define-from-file=env.json --dart-entry-point=run_with_env.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from env.json
  final envFile = File('env.json');
  if (!await envFile.exists()) {
    stderr.writeln('❌ env.json not found!');
    stderr.writeln('Create env.json with your environment variables:');
    stderr.writeln('{');
    stderr.writeln('  "CLIENT_ID": "your_client_id",');
    stderr.writeln('  "MEMVERSE_CLIENT_API_KEY": "your_api_key"');
    stderr.writeln('}');
    exit(1);
  }

  final env = jsonDecode(await envFile.readAsString());
  final clientId = env['CLIENT_ID'] ?? 'debug';
  final apiKey = env['MEMVERSE_CLIENT_API_KEY'] ?? '';

  // Show what's being used
  print('🚀 Starting with env.json configuration:');
  print('  Client ID: $clientId');
  print('  API Key: ${apiKey.isNotEmpty ? "***${apiKey.substring(0, 8)}***" : "(NOT SET)"}');

  // Import main and run the app with the loaded env vars
  runApp(MyHelloWorldApp(
    env: {
      'CLIENT_ID': clientId,
      'MEMVERSE_CLIENT_API_KEY': apiKey,
    },
  ));
}

class MyHelloWorldApp extends StatelessWidget {
  const MyHelloWorldApp({
    this.env,
    super.key,
  });

  final Map<String, String> env;

  const MyHelloWorldApp({required this.env, super.key});

  @override
  Widget build(BuildContext context) {
    // Extract environment from the env map for use in services
    final clientId = env['CLIENT_ID'] ?? env['MEMVERSE_CLIENT_API_KEY'] ?? 'debug';
    final apiSecret = env['MEMVERSE_CLIENT_API_KEY'];

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flutter_dash, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                '🚀 Using env.json configuration',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Client ID: $clientId',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'API Key: ${apiSecret.isNotEmpty ? "***${apiSecret.substring(0, 8)}***" : "(NOT SET)"}',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Text(
                'Ready to launch...',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}