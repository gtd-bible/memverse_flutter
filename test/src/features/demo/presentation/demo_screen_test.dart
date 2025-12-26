// ... (imports and Mock classes remain the same)

void main() {
  // Register fallback for Uri
  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
    registerFallbackValue(Scripture(reference: 'Test', text: 'Test', translation: 'Test')); // Added fallback for Scripture
  });

  fakeAsync((async) { // Wrap the entire test group with fakeAsync
    group('DemoScreen', () {
      late MockHttpClient mockHttpClient;
      late MockDemoRepository mockDemoRepository;
      late List<Scripture> testScriptures;

      setUp(() {
        mockHttpClient = MockHttpClient();
        mockDemoRepository = MockDemoRepository();

        // Define some test scriptures
        testScriptures = [
          Scripture(id: 1, reference: 'John 3:16', text: 'For God so loved...', translation: 'KJV', listName: 'My List'),
          Scripture(id: 2, reference: 'Romans 8:28', text: 'And we know that...', translation: 'KJV', listName: 'My List'),
        ];

        // Stub DemoRepository methods
        when(() => mockDemoRepository.getScriptures(any())).thenReturn(testScriptures);
        when(() => mockDemoRepository.getCollections()).thenReturn(['My List']);
        when(() => mockDemoRepository.addScripture(any(), any()))
            .thenAnswer((_) async {
              // Simulate adding a scripture
              testScriptures.add(Scripture(
                id: testScriptures.length + 1,
                reference: 'New Ref',
                text: 'New Text',
                translation: 'New Trans',
                listName: 'My List',
              ));
              async.elapse(Duration.zero); // Ensure immediate completion for async operations within the mock
            });
        when(() => mockDemoRepository.deleteScripture(any()))
            .thenAnswer((invocation) async {
              testScriptures.removeWhere((s) => s.id == (invocation.positionalArguments[0] as Scripture).id);
              async.elapse(Duration.zero); // Ensure immediate completion
            });
        when(() => mockDemoRepository.renameList(any(), any()))
            .thenAnswer((invocation) async {
              final oldName = invocation.positionalArguments[0] as String;
              final newName = invocation.positionalArguments[1] as String;
              for (var s in testScriptures) {
                if (s.listName == oldName) {
                  s.listName = newName;
                }
              }
              async.elapse(Duration.zero); // Ensure immediate completion
            });
      });

      Widget buildTestWidget() {
        return ProviderScope(
          overrides: [
            httpClientProvider.overrideWithValue(mockHttpClient),
            demoRepositoryProvider.overrideWithValue(mockDemoRepository), // Override with mock repository
          ],
          child: const MaterialApp(
            home: DemoScreen(),
          ),
        );
      }

      testWidgets('displays app bar title', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        async.elapse(Duration.zero); // Allow initState futures to complete
        await tester.pumpAndSettle();
        expect(find.text('Demo Scripture App'), findsOneWidget);
      });

      testWidgets('displays current list name', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        async.elapse(Duration.zero); // Allow initState futures to complete
        await tester.pumpAndSettle(); // Allow async data loading

        expect(find.text('My List'), findsOneWidget);
      });

      testWidgets('displays add button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        async.elapse(Duration.zero); // Allow initState futures to complete
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('displays collections button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        async.elapse(Duration.zero); // Allow initState futures to complete
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.list), findsOneWidget);
      });

      testWidgets('displays initial scriptures', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        async.elapse(Duration.zero); // Allow initState futures to complete
        await tester.pumpAndSettle();

        expect(find.text('John 3:16'), findsOneWidget);
        expect(find.text('Romans 8:28'), findsOneWidget);
      });

      testWidgets('add button opens scripture form dialog', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        async.elapse(Duration.zero); // Allow initState futures to complete
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        async.elapse(Duration.zero); // Allow dialog to open
        await tester.pumpAndSettle();

        expect(find.text('Add a Scripture'), findsOneWidget);
        expect(find.text('Enter comma-separated list of Scriptures'), findsOneWidget);
      });
    });
  });
}