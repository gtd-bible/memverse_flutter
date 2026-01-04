import 'dart:async';

import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/services/app_logger.dart';

/// Bootstrap the app with proper error handling and provider setup
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Make zone errors fatal in debug mode to catch zone mismatches early
  if (kDebugMode) {
    BindingBase.debugZoneErrorsAreFatal = true;
  }

  // Use the same zone for bootstrap that Flutter binding uses
  final app = await builder();

  runApp(ProviderScope(child: BetterFeedback(child: app)));

  // Set up global error handling
  FlutterError.onError ??= (details) {
    AppLogger.error('Flutter error: ${details.exception}', details.exception, details.stack);
  };
}
