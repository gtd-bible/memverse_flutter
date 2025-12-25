import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memverse_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke test - app launches successfully', (tester) async {
    // Launch the app
    await app.main();
    await tester.pumpAndSettle();

    // Verify the app launched by checking for any widget
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
