import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/database.dart';
import '../data/scripture.dart';

part 'demo_providers.g.dart';

var log = Logger();

Future<Map<String, dynamic>> fetchScripture(String reference) async {
  String url = 'https://bible-api.com/$reference';
  Uri uri = Uri.parse(url);

  log.d(uri.toString());
  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      log.d("200 ok");
      return jsonDecode(response.body);
    } else {
      log.e('status code = ${response.statusCode} message = ${response.reasonPhrase}',
          error: Exception('Failed to load scripture'));
      throw Exception('Failed to load scripture');
    }
  } catch (e) {
    log.e(e);
    rethrow;
  }
}

// TODO: Move this to a more appropriate place or use state management for UI feedback
String display = '';

@riverpod
Future<void> getResult(GetResultRef ref, String text, String currentList) async {
  log.d(text);
  List<String> result = text.split(',');
  if (result.isEmpty) {
    display = "Error getting scripture";
    return;
  }

  for (int i = 0; i < result.length; i++) {
    try {
      String reference = result[i];
      reference = reference.trim();
      final json = await fetchScripture(reference);

      final newScripture = Scripture()
        ..reference = json['reference']
        ..text = json['text']
        ..translation = json['translation_name']
        ..listName = currentList;

      final database = ref.read(databaseProvider);
      await database.addScripture(newScripture);

      display = "Added ${result[i]}";
      // analytics.logEvent(name: "Added", parameters: {'verse': result[i]});
    } catch (e) {
      display = 'the scripture "$text"" was not found';
      // analytics.logEvent(name: "ErrorGettingScripture", parameters: {'textString': text});
      break;
    }
  }
}

@Riverpod(keepAlive: true)
class CurrentList extends _$CurrentList {
  @override
  String build() {
    return 'My List';
  }

  void setCurrentList(String newListName) {
    state = newListName;
  }
}
