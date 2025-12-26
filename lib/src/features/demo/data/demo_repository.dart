import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added import
import 'package:http/http.dart' as http;
import 'package:memverse_flutter/src/features/demo/domain/scripture.dart';
import 'package:memverse_flutter/src/utils/app_logger.dart';

// Provider for http.Client
// It is kept here as it is a direct dependency for DemoRepository and will be mocked in tests.
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

class DemoRepository {
  final http.Client _client;
  final List<Scripture> _scriptures = [];

  DemoRepository(this._client); // Constructor now takes http.Client

  List<Scripture> getScriptures(String listName) {
    return _scriptures.where((s) => s.listName == listName).toList();
  }

  List<String> getCollections() {
    final names = _scriptures.map((s) => s.listName).toSet().toList();
    if (names.isEmpty) return ['My List'];
    return names;
  }

  Future<void> addScripture(String reference, String listName) async {
    final url = 'https://bible-api.com/${Uri.encodeComponent(reference)}';
    final uri = Uri.parse(url);

    try {
      final response = await _client.get(uri); // Use injected client
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final newScripture = Scripture(
          id: _scriptures.length + 1, // Simple ID generation
          reference: json['reference'] as String? ?? reference,
          text: json['text'] as String? ?? '',
          translation: json['translation_name'] as String? ?? 'KJV',
          listName: listName,
        );
        _scriptures.add(newScripture);
      } else {
        throw Exception('Failed to load scripture: ${response.statusCode}');
      }
    } catch (e, s) {
      AppLogger.e('Error fetching scripture', e, s);
      rethrow;
    }
  }

  Future<void> deleteScripture(Scripture scripture) async {
    _scriptures.removeWhere((s) => s.id == scripture.id);
  }

  Future<void> renameList(String oldName, String newName) async {
    for (var s in _scriptures) {
      if (s.listName == oldName) {
        s.listName = newName;
      }
    }
  }
}

final demoRepositoryProvider = Provider((ref) {
  final client = ref.watch(httpClientProvider);
  return DemoRepository(client);
});
