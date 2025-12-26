import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/demo/presentation/demo_providers.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('Demo Providers Unit Tests', () {
    test('currentListProvider starts with default value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final currentList = container.read(currentListProvider);
      expect(currentList, equals('My List'));
    });

    test('currentListProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Update the current list
      container.read(currentListProvider.notifier).setCurrentList('New List');

      // Verify it changed
      final currentList = container.read(currentListProvider);
      expect(currentList, equals('New List'));
    });

    test('currentListProvider notifies listeners on change', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var notifications = 0;
      container.listen<String>(
        currentListProvider,
        (previous, next) {
          notifications++;
        },
      );

      // Change the value
      container.read(currentListProvider.notifier).setCurrentList('Test List');

      // Should have notified once
      expect(notifications, equals(1));
    });
  });
}
