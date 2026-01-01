import 'dart:async';

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/src/app/view/app.dart';

/// Bootstrap the app with proper error handling and provider setup
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  runZonedGuarded(() async {
    // Initialize App container
    App.initialize();

    final app = await builder();

    runApp(ProviderScope(child: BetterFeedback(child: app)));
  }, (error, stack) => AppLogger.error('Error during bootstrap: $error', error, stack));
}
