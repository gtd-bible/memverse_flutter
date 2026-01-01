import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/src/features/verse/data/verse_repository.dart';
import 'package:mini_memverse/src/features/verse/domain/verse.dart';

final versesProvider = FutureProvider<List<Verse>>((ref) async {
  final repository = ref.watch(verseRepositoryProvider);
  return repository.getVerses();
});
