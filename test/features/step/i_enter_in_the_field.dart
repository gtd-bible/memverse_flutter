import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: I enter {string} in the {string} field
Future<void> iEnterInTheField(
  WidgetTester tester,
  String text,
  String fieldLabel,
) async {
  final textField = find.ancestor(
    of: find.text(fieldLabel),
    matching: find.byType(TextField),
  );
  await tester.enterText(textField, text);
  await tester.pumpAndSettle();
}
