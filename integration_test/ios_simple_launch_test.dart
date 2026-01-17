import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart' as app;

/// Simple iOS launch test to verify app starts correctly
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('iOS App Launch Test',
      (WidgetTester tester) async {
    debugPrint('🚀 Testing iOS app launch');

    // Verify environment variables are set
    const username = String.fromEnvironment('MEMVERSE_USERNAME');
    const password = String.fromEnvironment('MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT');
    const clientId = String.fromEnvironment('MEMVERSE_CLIENT_ID');
    const clientSecret = String.fromEnvironment('MEMVERSE_CLIENT_API_KEY');

    if (username.isEmpty || password.isEmpty || clientId.isEmpty || clientSecret.isEmpty) {
      throw Exception('Environment variables not set properly');
    }

    debugPrint('✅ Environment variables verified');

    // Launch app
    debugPrint('📱 Launching app...');
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify basic app structure
    expect(find.byType(MaterialApp), findsOneWidget);
    debugPrint('✅ App launched and MaterialApp found');

    // Verify no errors
    expect(find.byType(ErrorWidget), findsNothing);
    debugPrint('✅ No error widgets present');

    debugPrint('✅ iOS app launch test PASSED');
  });
}