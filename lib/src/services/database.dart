import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:memverse_flutter/src/features/demo/data/scripture.dart';

class Database {
  late Isar isar;

  Future<void> init() async {
    if (Isar.instanceNames.isEmpty) {
      if (kIsWeb) {
        isar = await Isar.open(
          [ScriptureSchema],
          inspector: true,
          directory: '', // Provide an empty string for web
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        isar = await Isar.open(
          [ScriptureSchema],
          directory: dir.path,
          inspector: true,
        );
      }
    } else {
      isar = Isar.getInstance()!;
    }
  }

  Future<int> getScriptureCount() async {
    return await isar.scriptures.count();
  }
  
  Future<bool> isListEmpty(String listName) async {
    final count = await isar.scriptures.filter().listNameMatches(listName).count();
    return count == 0;
  }
  
  Future<void> renameList(String oldName, String newName) async {
    final scriptures = await isar.scriptures.filter().listNameMatches(oldName).findAll();
    await isar.writeTxn(() async {
      for (var s in scriptures) {
        s.listName = newName;
        await isar.scriptures.put(s);
      }
    });
  }
}

final databaseProvider = Provider<Database>((ref) {
  return Database();
});
