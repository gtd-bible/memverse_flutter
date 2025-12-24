import 'package:memverse_flutter/src/features/demo/data/scripture.dart';
import 'package:memverse_flutter/src/services/database_repository.dart';
import 'package:sembast/sembast_memory.dart';

/// Test implementation of the database repository
/// Uses Sembast with an in-memory database for isolated testing
class TestDatabaseRepository implements DatabaseRepository {
  late Database _db;
  final _store = intMapStoreFactory.store('scriptures');

  @override
  Future<void> init() async {
    // Use in-memory database for tests
    _db = await databaseFactoryMemory.openDatabase('test.db');
  }

  @override
  Future<void> addScripture(Scripture scripture) async {
    final json = scripture.toJson();
    json.remove('id');
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
    final count = await _store.count(_db, filter: Filter.equals('listName', listName));
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

/// Create a test database repository with in-memory database
Future<DatabaseRepository> createTestDatabaseRepository() async {
  final repo = TestDatabaseRepository();
  await repo.init();
  return repo;
}
