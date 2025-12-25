import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/scripture_form.dart';

void main() {
  group('ScriptureForm', () {
    testWidgets('shows validation error when reference field is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScriptureForm(
                onSubmit: (text) async {},
              ),
            ),
          ),
        ),
      );

      // Find and tap the submit button
      final submitButton = find.text('Submit');
      expect(submitButton, findsOneWidget);
      
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter some text'), findsOneWidget);
    });

    testWidgets('shows validation error when collection name field is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScriptureForm(
                onSubmit: (text) async {},
              ),
            ),
          ),
        ),
      );

      // Enter reference but leave collection empty
      await tester.enterText(find.byType(TextField).first, 'John 3:16');
      
      final submitButton = find.text('Submit');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Should show validation error for collection name
      expect(find.text('Please enter some text'), findsWidgets);
    });

    testWidgets('calls onSubmit when form is valid', (tester) async {
      String? submittedText;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScriptureForm(
                onSubmit: (text) async {
                  submittedText = text;
                },
              ),
            ),
          ),
        ),
      );

      // Enter valid data
      final referenceField = find.byType(TextField).first;
      final collectionField = find.byType(TextField).last;
      
      await tester.enterText(referenceField, 'John 3:16');
      await tester.enterText(collectionField, 'My Verses');
      
      final submitButton = find.text('Submit');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Should have called onSubmit
      expect(submittedText, equals('John 3:16'));
    });
  });
}
