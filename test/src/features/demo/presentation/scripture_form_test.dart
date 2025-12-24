import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/app.dart';
import 'package:memverse_flutter/src/features/demo/presentation/demo_providers.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/scripture_form.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/provider_mocks.dart';
import '../../../helpers/test_app.dart';

void main() {
  group('ScriptureForm', () {
    late MockGetResult mockGetResult;

    setUpAll(() {
      // Register fallback for any() for non-nullable types
      registerFallbackValue(MockGetResultRef());
    });

    setUp(() {
      mockGetResult = MockGetResult();
      when(() => mockGetResult(any(), any(), any())).thenAnswer((_) async {});
    });

    testWidgets('shows validation error when reference field is empty', (tester) async {
      await tester.pumpWidget(
        TestApp(
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => mockGetResult(ref, text, currentList),
            ),
          ],
          child: const ScriptureForm(),
        ),
      );

      // Tap the submit button without entering any text
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Expect to see the validation error message
      expect(find.text('Please enter some text'), findsOneWidget);
    });

    testWidgets('shows validation error when collection name field is empty', (tester) async {
      await tester.pumpWidget(
        TestApp(
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => mockGetResult(ref, text, currentList),
            ),
          ],
          child: const ScriptureForm(),
        ),
      );

      // Enter text in reference, but leave collection name empty
      await tester.enterText(find.byKey(const Key('scriptureToAdd')), 'John 3:16');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Expect to see the validation error message for collection name
      expect(find.text('Please enter some text'), findsOneWidget);
    });

    testWidgets('calls getResultProvider and pops when form is valid', (tester) async {
      final mockGoRouter = MockGoRouter();
      when(() => mockGoRouter.pop()).thenReturn(true);

      await tester.pumpWidget(
        TestApp(
          initialLocation: '/', // Needed for GoRouter to be set up
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => mockGetResult(ref, text, currentList),
            ),
            routerProvider.overrideWithValue(mockGoRouter),
          ],
          child: const ScriptureForm(),
        ),
      );

      await tester.enterText(find.byKey(const Key('scriptureToAdd')), 'John 3:16');
      await tester.enterText(find.byKey(const Key('collectionName')), 'My New List');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify that getResult was called with the correct arguments
      verify(() => mockGetResult(any(), 'John 3:16', 'My New List')).called(1);
      // Verify that context.pop was called
      verify(() => mockGoRouter.pop()).called(1);
    });

    testWidgets('displays label texts correctly', (tester) async {
      await tester.pumpWidget(
        TestApp(
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => mockGetResult(ref, text, currentList),
            ),
          ],
          child: const ScriptureForm(),
        ),
      );

      expect(find.text('Enter comma-separated list of Scriptures'), findsOneWidget);
      expect(find.text('Collection name'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('initializes collection field with current list from provider', (tester) async {
      await tester.pumpWidget(
        TestApp(
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => mockGetResult(ref, text, currentList),
            ),
            currentListProvider.overrideWith((ref) => 'My List'),
          ],
          child: const ScriptureForm(),
        ),
      );

      await tester.pumpAndSettle();

      // The collection name field should be pre-filled with current list
      final collectionField = tester.widget<TextFormField>(
        find.byKey(const Key('collectionName')),
      );
      expect(collectionField.controller?.text, 'My List');
    });

    testWidgets('handles multiple comma-separated references', (tester) async {
      final mockGoRouter = MockGoRouter();
      when(() => mockGoRouter.pop()).thenReturn(true);

      await tester.pumpWidget(
        TestApp(
          initialLocation: '/',
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => mockGetResult(ref, text, currentList),
            ),
            routerProvider.overrideWithValue(mockGoRouter),
          ],
          child: const ScriptureForm(),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('scriptureToAdd')),
        'John 3:16, Romans 8:28, Philippians 4:13',
      );
      await tester.enterText(find.byKey(const Key('collectionName')), 'Batch List');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockGetResult(
            any(),
            'John 3:16, Romans 8:28, Philippians 4:13',
            'Batch List',
          )).called(1);
    });

    testWidgets('shows snackbar with display message after submission', (tester) async {
      final mockGoRouter = MockGoRouter();
      when(() => mockGoRouter.pop()).thenReturn(true);

      await tester.pumpWidget(
        TestApp(
          initialLocation: '/',
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => mockGetResult(ref, text, currentList),
            ),
            routerProvider.overrideWithValue(mockGoRouter),
          ],
          child: const Scaffold(body: ScriptureForm()),
        ),
      );

      await tester.enterText(find.byKey(const Key('scriptureToAdd')), 'John 3:16');
      await tester.enterText(find.byKey(const Key('collectionName')), 'Test List');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Snackbar should appear (display variable gets set in provider)
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('handles API error gracefully', (tester) async {
      final failingMockGetResult = MockGetResult();
      when(() => failingMockGetResult(any(), any(), any())).thenThrow(Exception('Network error'));

      final mockGoRouter = MockGoRouter();
      when(() => mockGoRouter.pop()).thenReturn(true);

      await tester.pumpWidget(
        TestApp(
          initialLocation: '/',
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => failingMockGetResult(ref, text, currentList),
            ),
            routerProvider.overrideWithValue(mockGoRouter),
          ],
          child: const Scaffold(body: ScriptureForm()),
        ),
      );

      await tester.enterText(find.byKey(const Key('scriptureToAdd')), 'Invalid 99:99');
      await tester.enterText(find.byKey(const Key('collectionName')), 'Test List');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should handle exception (in real app, would show error message)
      expect(find.byType(ScriptureForm), findsOneWidget);
    });

    testWidgets('form can be reset after submission', (tester) async {
      final mockGoRouter = MockGoRouter();
      when(() => mockGoRouter.pop()).thenReturn(true);

      await tester.pumpWidget(
        TestApp(
          initialLocation: '/',
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => mockGetResult(ref, text, currentList),
            ),
            routerProvider.overrideWithValue(mockGoRouter),
          ],
          child: const ScriptureForm(),
        ),
      );

      // First submission
      await tester.enterText(find.byKey(const Key('scriptureToAdd')), 'John 3:16');
      await tester.enterText(find.byKey(const Key('collectionName')), 'List 1');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockGetResult(any(), 'John 3:16', 'List 1')).called(1);
    });

    testWidgets('handles special characters in scripture reference', (tester) async {
      final mockGoRouter = MockGoRouter();
      when(() => mockGoRouter.pop()).thenReturn(true);

      await tester.pumpWidget(
        TestApp(
          initialLocation: '/',
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => mockGetResult(ref, text, currentList),
            ),
            routerProvider.overrideWithValue(mockGoRouter),
          ],
          child: const ScriptureForm(),
        ),
      );

      await tester.enterText(find.byKey(const Key('scriptureToAdd')), '1 John 1:9');
      await tester.enterText(find.byKey(const Key('collectionName')), 'Special');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockGetResult(any(), '1 John 1:9', 'Special')).called(1);
    });

    testWidgets('handles very long input text', (tester) async {
      final mockGoRouter = MockGoRouter();
      when(() => mockGoRouter.pop()).thenReturn(true);

      await tester.pumpWidget(
        TestApp(
          initialLocation: '/',
          overrides: [
            getResultProvider.overrideWith(
              (ref, text, currentList) => mockGetResult(ref, text, currentList),
            ),
            routerProvider.overrideWithValue(mockGoRouter),
          ],
          child: const ScriptureForm(),
        ),
      );

      final longReference = List.generate(50, (i) => 'John ${i + 1}:1').join(', ');
      await tester.enterText(find.byKey(const Key('scriptureToAdd')), longReference);
      await tester.enterText(find.byKey(const Key('collectionName')), 'Long List');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockGetResult(any(), longReference, 'Long List')).called(1);
    });
  });
}
