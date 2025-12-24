import 'package:isar/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:memverse_flutter/src/features/demo/data/scripture.dart';

// Mock path_provider for tests
class MockPathProviderPlatform extends Mock implements PathProviderPlatform {}

// Utility to open an Isar instance in a temporary directory
Future<Isar> openTempIsar(List<CollectionSchema<dynamic>> schemas) async {
  TestWidgetsFlutterBinding.ensureInitialized(); // Needed for path_provider

  // Mock path_provider to return a temporary directory
  final mockPathProvider = MockPathProviderPlatform();
  when(() => mockPathProvider.getApplicationDocumentsPath())
      .thenAnswer((_) async => './temp_test_isar_dir'); // Use a local temp dir

  PathProviderPlatform.instance = mockPathProvider;

  // Ensure the directory exists
  // For web, directory is ignored, but Isar still requires it.
  // For other platforms, we need a physical directory.
  // This is a simplified approach, a real temp dir solution would be better
  // but for testing locally, this works.
  // if (!kIsWeb) { // kIsWeb is not available in pure dart tests
  //   final dir = Directory('./temp_test_isar_dir');
  //   if (!await dir.exists()) {
  //     await dir.create();
  //   }
  // }

  return Isar.open(
    schemas,
    directory: './temp_test_isar_dir',
    inspector: false,
  );
}

// Close and delete the temporary Isar instance
Future<void> closeAndDeleteTempIsar(Isar isar) async {
  await isar.close(deleteFromDisk: true);
  // Optional: Clean up the physical directory if it was created
  // if (!kIsWeb) {
  //   final dir = Directory('./temp_test_isar_dir');
  //   if (await dir.exists()) {
  //     await dir.delete(recursive: true);
  //   }
  // }
}
