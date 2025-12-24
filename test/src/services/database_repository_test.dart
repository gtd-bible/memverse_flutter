import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/demo/data/scripture.dart';
import '../../helpers/test_database_repository.dart';

void main() {
  group('DatabaseRepository', () {
    late TestDatabaseRepository repository;

    setUp(() async {
      repository = TestDatabaseRepository();
      await repository.init();
    });

    tearDown(() async {
      await repository.close(deleteFromDisk: true);
    });

    test('should initialize successfully', () async {
      // Test passes if setUp completes without errors
      expect(repository, isNotNull);
    });

    group('addScripture', () {
      test('should add a scripture and assign an ID', () async {
        final scripture = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
          listName: 'My List',
        );

        await repository.addScripture(scripture);

        expect(scripture.id, isNotNull);
        expect(scripture.id, greaterThan(0));
      });

      test('should add multiple scriptures with different IDs', () async {
        final scripture1 = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
        );
        final scripture2 = Scripture(
          reference: 'Romans 8:28',
          text: 'And we know that in all things...',
          translation: 'NIV',
        );

        await repository.addScripture(scripture1);
        await repository.addScripture(scripture2);

        expect(scripture1.id, isNot(scripture2.id));
      });
    });

    group('getScripturesByList', () {
      test('should return empty list when no scriptures exist', () async {
        final scriptures = await repository.getScripturesByList('My List');
        expect(scriptures, isEmpty);
      });

      test('should return scriptures for a specific list', () async {
        final scripture1 = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
          listName: 'Favorites',
        );
        final scripture2 = Scripture(
          reference: 'Romans 8:28',
          text: 'And we know that in all things...',
          translation: 'NIV',
          listName: 'Favorites',
        );
        final scripture3 = Scripture(
          reference: 'Psalm 23:1',
          text: 'The Lord is my shepherd...',
          translation: 'ESV',
          listName: 'Psalms',
        );

        await repository.addScripture(scripture1);
        await repository.addScripture(scripture2);
        await repository.addScripture(scripture3);

        final favorites = await repository.getScripturesByList('Favorites');
        final psalms = await repository.getScripturesByList('Psalms');

        expect(favorites.length, 2);
        expect(psalms.length, 1);
        expect(favorites[0].reference, 'John 3:16');
        expect(favorites[1].reference, 'Romans 8:28');
        expect(psalms[0].reference, 'Psalm 23:1');
      });
    });

    group('getScriptureCount', () {
      test('should return 0 when database is empty', () async {
        final count = await repository.getScriptureCount();
        expect(count, 0);
      });

      test('should return correct count after adding scriptures', () async {
        final scripture1 = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
        );
        final scripture2 = Scripture(
          reference: 'Romans 8:28',
          text: 'And we know that in all things...',
          translation: 'NIV',
        );

        await repository.addScripture(scripture1);
        expect(await repository.getScriptureCount(), 1);

        await repository.addScripture(scripture2);
        expect(await repository.getScriptureCount(), 2);
      });
    });

    group('isListEmpty', () {
      test('should return true for empty list', () async {
        final isEmpty = await repository.isListEmpty('My List');
        expect(isEmpty, isTrue);
      });

      test('should return false for list with scriptures', () async {
        final scripture = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
          listName: 'My List',
        );
        await repository.addScripture(scripture);

        final isEmpty = await repository.isListEmpty('My List');
        expect(isEmpty, isFalse);
      });

      test('should return true for different list name', () async {
        final scripture = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
          listName: 'My List',
        );
        await repository.addScripture(scripture);

        final isEmpty = await repository.isListEmpty('Other List');
        expect(isEmpty, isTrue);
      });
    });

    group('deleteScripture', () {
      test('should delete a scripture by ID', () async {
        final scripture = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
        );
        await repository.addScripture(scripture);
        expect(await repository.getScriptureCount(), 1);

        await repository.deleteScripture(scripture.id!);
        expect(await repository.getScriptureCount(), 0);
      });

      test('should only delete the specified scripture', () async {
        final scripture1 = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
        );
        final scripture2 = Scripture(
          reference: 'Romans 8:28',
          text: 'And we know that in all things...',
          translation: 'NIV',
        );
        await repository.addScripture(scripture1);
        await repository.addScripture(scripture2);

        await repository.deleteScripture(scripture1.id!);

        final remaining = await repository.getScripturesByList('My List');
        expect(remaining.length, 1);
        expect(remaining[0].reference, 'Romans 8:28');
      });
    });

    group('renameList', () {
      test('should rename all scriptures in a list', () async {
        final scripture1 = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
          listName: 'Old Name',
        );
        final scripture2 = Scripture(
          reference: 'Romans 8:28',
          text: 'And we know that in all things...',
          translation: 'NIV',
          listName: 'Old Name',
        );
        await repository.addScripture(scripture1);
        await repository.addScripture(scripture2);

        await repository.renameList('Old Name', 'New Name');

        final oldList = await repository.getScripturesByList('Old Name');
        final newList = await repository.getScripturesByList('New Name');

        expect(oldList, isEmpty);
        expect(newList.length, 2);
      });

      test('should not affect other lists', () async {
        final scripture1 = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
          listName: 'List A',
        );
        final scripture2 = Scripture(
          reference: 'Romans 8:28',
          text: 'And we know that in all things...',
          translation: 'NIV',
          listName: 'List B',
        );
        await repository.addScripture(scripture1);
        await repository.addScripture(scripture2);

        await repository.renameList('List A', 'List C');

        final listB = await repository.getScripturesByList('List B');
        final listC = await repository.getScripturesByList('List C');

        expect(listB.length, 1);
        expect(listC.length, 1);
      });
    });

    group('getAllListNames', () {
      test('should return empty list when no scriptures exist', () async {
        final listNames = await repository.getAllListNames();
        expect(listNames, isEmpty);
      });

      test('should return all unique list names', () async {
        final scripture1 = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
          listName: 'Favorites',
        );
        final scripture2 = Scripture(
          reference: 'Romans 8:28',
          text: 'And we know that in all things...',
          translation: 'NIV',
          listName: 'Favorites',
        );
        final scripture3 = Scripture(
          reference: 'Psalm 23:1',
          text: 'The Lord is my shepherd...',
          translation: 'ESV',
          listName: 'Psalms',
        );
        await repository.addScripture(scripture1);
        await repository.addScripture(scripture2);
        await repository.addScripture(scripture3);

        final listNames = await repository.getAllListNames();

        expect(listNames.length, 2);
        expect(listNames, contains('Favorites'));
        expect(listNames, contains('Psalms'));
      });
    });

    group('E2E scenarios', () {
      test('should handle complete scripture management workflow', () async {
        // Add scriptures to multiple lists
        await repository.addScripture(Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'KJV',
          listName: 'Gospel',
        ));
        await repository.addScripture(Scripture(
          reference: 'John 14:6',
          text: 'I am the way, the truth, and the life...',
          translation: 'KJV',
          listName: 'Gospel',
        ));
        await repository.addScripture(Scripture(
          reference: 'Psalm 23:1',
          text: 'The Lord is my shepherd...',
          translation: 'ESV',
          listName: 'Psalms',
        ));

        // Verify counts
        expect(await repository.getScriptureCount(), 3);
        expect(await repository.isListEmpty('Gospel'), isFalse);
        expect(await repository.isListEmpty('Psalms'), isFalse);

        // Get all list names
        final listNames = await repository.getAllListNames();
        expect(listNames.length, 2);

        // Rename a list
        await repository.renameList('Gospel', 'Good News');
        expect(await repository.isListEmpty('Gospel'), isTrue);
        expect(await repository.isListEmpty('Good News'), isFalse);

        // Delete from a list
        final goodNewsScriptures = await repository.getScripturesByList('Good News');
        await repository.deleteScripture(goodNewsScriptures[0].id!);
        expect((await repository.getScripturesByList('Good News')).length, 1);
        expect(await repository.getScriptureCount(), 2);
      });
    });
  });
}
