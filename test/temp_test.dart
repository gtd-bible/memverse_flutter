import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_app.dart'; // Relative import

void main() {
  testWidgets('temp test to check import', (tester) async {
    // This will use TestApp from test/helpers/test_app.dart
    await tester.pumpWidget(const TestApp(child: Text('Hello World')));
    expect(find.text('Hello World'), findsOneWidget);
  });
}
