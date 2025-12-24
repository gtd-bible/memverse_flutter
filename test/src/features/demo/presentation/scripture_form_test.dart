import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:memverse_flutter/src/features/demo/presentation/demo_providers.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/scripture_form.dart';
import 'package:memverse_flutter/src/app.dart';
import '../../../helpers/test_app.dart';
import '../../../helpers/provider_mocks.dart';

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
  });
}
