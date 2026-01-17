import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/services/app_logger.dart';

/// Bootstrap the app with proper error handling and provider setup
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Initialize app components
  final app = await builder();

  // Set up global error handling
  FlutterError.onError ??= (details) {
    AppLogger.error('Flutter error: ${details.exception}', details.exception, details.stack);
  };

  // Create a single ProviderContainer for the app
  runApp(ProviderScope(child: app));
}
