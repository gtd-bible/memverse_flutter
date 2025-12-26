import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added import
import 'package:memverse_flutter/src/features/demo/data/demo_repository.dart';
import 'package:memverse_flutter/src/features/demo/domain/scripture.dart';

final currentListProvider = StateProvider<String>((ref) => 'My List');

final scriptureListProvider = FutureProvider.autoDispose<List<Scripture>>((ref) async {
  final repo = ref.watch(demoRepositoryProvider);
  final currentList = ref.watch(currentListProvider);
  return repo.getScriptures(currentList);
});