import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import '../features/demo/data/scripture.dart';
import 'database_repository.dart';

/// Isar implementation of the database repository
class IsarDatabaseRepository implements DatabaseRepository {
  late Isar _isar;
  
  @override
  Future<void> init() async {
    if (Isar.instanceNames.isEmpty) {
      if (kIsWeb) {
        _isar = await Isar.open(
          [ScriptureSchema],
          inspector: true,
          directory: '', // Provide an empty string for web
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        _isar = await Isar.open(
          [ScriptureSchema],
          directory: dir.path,
          inspector: true,
        );
      }
    } else {
      _isar = Isar.getInstance()!;
    }
  }
  
  @override
  Future<void> addScripture(Scripture scripture) async {
    await _isar.writeTxn(() async {
      await _isar.scriptures.put(scripture);
    });
  }
  
  @override
  Future<void> deleteScripture(int scriptureId) async {
    await _isar.writeTxn(() async {
      await _isar.scriptures.delete(scriptureId);
    });
  }
  
  @override
  Future<List<Scripture>> getScripturesByList(String listName) async {
    return await _isar.scriptures
        .filter()
        .listNameMatches(listName)
        .findAll();
  }
  
  @override
  Future<int> getScriptureCount() async {
    return await _isar.scriptures.count();
  }
  
  @override
  Future<bool> isListEmpty(String listName) async {
    final count = await _isar.scriptures
        .filter()
        .listNameMatches(listName)
        .count();
    return count == 0;
  }
  
  @override
  Future<void> renameList(String oldName, String newName) async {
    final scriptures = await _isar.scriptures
        .filter()
        .listNameMatches(oldName)
        .findAll();
    await _isar.writeTxn(() async {
      for (var s in scriptures) {
        s.listName = newName;
        await _isar.scriptures.put(s);
      }
    });
  }
  
  @override
  Future<List<String>> getAllListNames() async {
    return await _isar.scriptures
        .where()
        .distinctByListName()
        .listNameProperty()
        .findAll();
  }
  
  @override
  Future<void> close({bool deleteFromDisk = false}) async {
    await _isar.close(deleteFromDisk: deleteFromDisk);
  }
}
