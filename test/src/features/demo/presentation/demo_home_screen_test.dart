import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/demo/data/scripture.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/demo_home_screen.dart';
import 'package:memverse_flutter/src/services/database.dart';
import '../../../helpers/test_database_repository.dart';

void main() {
  group('DemoHomeScreen', () {
    late TestDatabaseRepository mockDatabase;

    setUp(() {
      mockDatabase = TestDatabaseRepository();
    });

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(mockDatabase),
        ],
        child: const MaterialApp(
          home: DemoHomeScreen(),
        ),
      );
    }

    testWidgets('displays app title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Scripture App (Demo)'), findsOneWidget);
    });

    testWidgets('displays back button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays collections button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('displays floating action button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays current list name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My List'), findsOneWidget);
    });

    testWidgets('shows empty message when no verses', (tester) async {
      mockDatabase.scriptureList = [];

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No verses in this list.'), findsOneWidget);
    });

    testWidgets('displays list of verses', (tester) async {
      mockDatabase.scriptureList = [
        Scripture(
          id: 1,
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'NIV',
        ),
        Scripture(
          id: 2,
          reference: 'Romans 8:28',
          text: 'And we know that...',
          translation: 'ESV',
        ),
      ];

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('John 3:16'), findsOneWidget);
      expect(find.text('Romans 8:28'), findsOneWidget);
    });

    testWidgets('tapping verse opens dialog', (tester) async {
      mockDatabase.scriptureList = [
        Scripture(
          id: 1,
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'NIV',
        ),
      ];

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('John 3:16'));
      await tester.pumpAndSettle();

      expect(find.byType(SimpleDialog), findsOneWidget);
    });

    testWidgets('tapping FAB opens scripture form', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(SimpleDialog), findsOneWidget);
      expect(find.text('Add a Scripture'), findsOneWidget);
    });

    testWidgets('pull to refresh reloads list', (tester) async {
      mockDatabase.scriptureList = [
        Scripture(
          id: 1,
          reference: 'John 3:16',
          text: 'Test',
          translation: 'NIV',
        ),
      ];

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.text('John 3:16'), findsOneWidget);
    });

    testWidgets('swiping verse shows delete action', (tester) async {
      mockDatabase.scriptureList = [
        Scripture(
          id: 1,
          reference: 'John 3:16',
          text: 'Test',
          translation: 'NIV',
        ),
      ];

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.text('John 3:16'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('tapping delete removes verse', (tester) async {
      mockDatabase.scriptureList = [
        Scripture(
          id: 1,
          reference: 'John 3:16',
          text: 'Test',
          translation: 'NIV',
        ),
      ];

      int deleteCallCount = 0;
      mockDatabase.onDeleteScripture = (id) {
        deleteCallCount++;
        mockDatabase.scriptureList = [];
      };

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.text('John 3:16'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleteCallCount, 1);
    });
  });
}
