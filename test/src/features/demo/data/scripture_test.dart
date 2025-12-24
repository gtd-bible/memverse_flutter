import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/demo/data/scripture.dart';

void main() {
  group('Scripture data model', () {
    group('constructor', () {
      test('creates instance with all required fields', () {
        final scripture = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'NIV',
        );

        expect(scripture.reference, 'John 3:16');
        expect(scripture.text, 'For God so loved the world...');
        expect(scripture.translation, 'NIV');
        expect(scripture.listName, 'My List'); // default value
        expect(scripture.id, isNull);
      });

      test('creates instance with custom list name', () {
        final scripture = Scripture(
          reference: 'Psalm 23:1',
          text: 'The Lord is my shepherd',
          translation: 'ESV',
          listName: 'Favorites',
        );

        expect(scripture.listName, 'Favorites');
      });

      test('creates instance with id', () {
        final scripture = Scripture(
          id: 42,
          reference: 'Romans 8:28',
          text: 'And we know that in all things...',
          translation: 'NIV',
        );

        expect(scripture.id, 42);
      });
    });

    group('toJson', () {
      test('converts to JSON with all fields including nulls', () {
        final scripture = Scripture(
          reference: 'John 3:16',
          text: 'For God so loved the world...',
          translation: 'NIV',
          listName: 'Daily Verses',
        );

        final json = scripture.toJson();

        expect(json, {
          'id': null,
          'reference': 'John 3:16',
          'text': 'For God so loved the world...',
          'translation': 'NIV',
          'listName': 'Daily Verses',
        });
      });

      test('converts to JSON with id', () {
        final scripture = Scripture(
          id: 123,
          reference: 'Proverbs 3:5-6',
          text: 'Trust in the Lord with all your heart...',
          translation: 'ESV',
          listName: 'Memory',
        );

        final json = scripture.toJson();

        expect(json['id'], 123);
        expect(json['reference'], 'Proverbs 3:5-6');
      });

      test('includes default list name in JSON', () {
        final scripture = Scripture(
          reference: 'Matthew 6:33',
          text: 'But seek first his kingdom...',
          translation: 'NIV',
        );

        final json = scripture.toJson();

        expect(json['listName'], 'My List');
      });
    });

    group('fromJson', () {
      test('creates instance from complete JSON', () {
        final json = {
          'id': 99,
          'reference': 'Philippians 4:13',
          'text': 'I can do all things through Christ...',
          'translation': 'KJV',
          'listName': 'Strength',
        };

        final scripture = Scripture.fromJson(json);

        expect(scripture.id, 99);
        expect(scripture.reference, 'Philippians 4:13');
        expect(scripture.text, 'I can do all things through Christ...');
        expect(scripture.translation, 'KJV');
        expect(scripture.listName, 'Strength');
      });

      test('creates instance from JSON without id', () {
        final json = {
          'reference': 'Colossians 1:17',
          'text': 'He is before all things...',
          'translation': 'NIV',
          'listName': 'Christ',
        };

        final scripture = Scripture.fromJson(json);

        expect(scripture.id, isNull);
        expect(scripture.reference, 'Colossians 1:17');
      });

      test('uses default listName when not provided in JSON', () {
        final json = {
          'id': 1,
          'reference': 'Genesis 1:1',
          'text': 'In the beginning God created...',
          'translation': 'NIV',
        };

        final scripture = Scripture.fromJson(json);

        expect(scripture.listName, 'My List');
      });

      test('uses default listName when JSON listName is null', () {
        final json = {
          'id': 2,
          'reference': 'John 1:1',
          'text': 'In the beginning was the Word...',
          'translation': 'ESV',
          'listName': null,
        };

        final scripture = Scripture.fromJson(json);

        expect(scripture.listName, 'My List');
      });

      test('roundtrip: toJson then fromJson produces equivalent object', () {
        final original = Scripture(
          id: 456,
          reference: '2 Timothy 3:16',
          text: 'All Scripture is God-breathed...',
          translation: 'NIV',
          listName: 'Teaching',
        );

        final json = original.toJson();
        final restored = Scripture.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.reference, original.reference);
        expect(restored.text, original.text);
        expect(restored.translation, original.translation);
        expect(restored.listName, original.listName);
      });
    });

    group('edge cases', () {
      test('handles empty strings', () {
        final scripture = Scripture(
          reference: '',
          text: '',
          translation: '',
          listName: '',
        );

        expect(scripture.reference, '');
        expect(scripture.text, '');
        expect(scripture.translation, '');
        expect(scripture.listName, '');

        final json = scripture.toJson();
        final restored = Scripture.fromJson(json);

        expect(restored.reference, '');
        expect(restored.listName, '');
      });

      test('handles very long text', () {
        final longText = 'A' * 10000;
        final scripture = Scripture(
          reference: 'Psalm 119',
          text: longText,
          translation: 'NIV',
        );

        expect(scripture.text.length, 10000);

        final json = scripture.toJson();
        final restored = Scripture.fromJson(json);

        expect(restored.text, longText);
      });

      test('handles special characters in text', () {
        final scripture = Scripture(
          reference: 'Test "verse"',
          text: 'Special chars: \n\t\r\\ " \' & < > {}',
          translation: 'NIV',
          listName: 'Test\'s "List"',
        );

        final json = scripture.toJson();
        final restored = Scripture.fromJson(json);

        expect(restored.reference, scripture.reference);
        expect(restored.text, scripture.text);
        expect(restored.listName, scripture.listName);
      });
    });
  });
}
