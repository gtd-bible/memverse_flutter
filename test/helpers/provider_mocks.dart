// Placeholder for MockGetResult and other needed test utilities
import 'package:mocktail/mocktail.dart';
import 'package:memverse_flutter/src/features/demo/presentation/demo_providers.dart';

class MockGetResultRef extends Mock implements GetResultRef {}

class MockGetResult extends Mock {
  Future<void> call(GetResultRef ref, String text, String currentList);
}
