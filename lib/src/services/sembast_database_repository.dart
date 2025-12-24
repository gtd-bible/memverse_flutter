import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../features/demo/data/scripture.dart';
import 'database_repository.dart';

/// Sembast implementation of the database repository
class SembastDatabaseRepository implements DatabaseRepository {
  late Database _db;
  final _store = intMapStoreFactory.store('scriptures');

  @override
  Future<void> init() async {
    if (kIsWeb) {
      // For web, use in-memory database
      _db = await databaseFactoryMemory.openDatabase('memverse.db');
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, 'memverse.db');
      _db = await databaseFactoryIo.openDatabase(dbPath);
    }
  }

  @override
  Future<void> addScripture(Scripture scripture) async {
    final json = scripture.toJson();
    json.remove('id'); // Let Sembast auto-generate the ID
    final id = await _store.add(_db, json);
    scripture.id = id;
  }

  @override
  Future<void> deleteScripture(int scriptureId) async {
    await _store.record(scriptureId).delete(_db);
  }

  @override
  Future<List<Scripture>> getScripturesByList(String listName) async {
    final finder = Finder(
      filter: Filter.equals('listName', listName),
    );
    final records = await _store.find(_db, finder: finder);
    return records.map((record) {
      final data = Map<String, dynamic>.from(record.value);
      data['id'] = record.key;
      return Scripture.fromJson(data);
    }).toList();
  }

  @override
  Future<int> getScriptureCount() async {
    return await _store.count(_db);
  }

  @override
  Future<bool> isListEmpty(String listName) async {
    final finder = Finder(
      filter: Filter.equals('listName', listName),
    );
    final count = await _store.count(_db, filter: finder.filter);
    return count == 0;
  }

  @override
  Future<void> renameList(String oldName, String newName) async {
    final finder = Finder(
      filter: Filter.equals('listName', oldName),
    );
    await _store.update(
      _db,
      {'listName': newName},
      finder: finder,
    );
  }

  @override
  Future<List<String>> getAllListNames() async {
    final records = await _store.find(_db);
    final listNames = records
        .map((record) => record.value['listName'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    return listNames;
  }

  @override
  Future<void> close({bool deleteFromDisk = false}) async {
    if (deleteFromDisk) {
      await _store.delete(_db);
    }
    await _db.close();
  }
}
