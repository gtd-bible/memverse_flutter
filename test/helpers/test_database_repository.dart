import 'package:isar/isar.dart';
import 'package:memverse_flutter/src/features/demo/data/scripture.dart';
import 'package:memverse_flutter/src/services/database_repository.dart';

/// Test implementation of the database repository
/// Uses Isar with a temporary directory for isolated testing
class TestDatabaseRepository implements DatabaseRepository {
  late Isar _isar;
  final String testDirectory;

  TestDatabaseRepository({this.testDirectory = './temp_test_isar_dir'});

  @override
  Future<void> init() async {
    _isar = await Isar.open(
      [ScriptureSchema],
      directory: testDirectory,
      inspector: false,
    );
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
    return await _isar.scriptures.filter().listNameMatches(listName).findAll();
  }

  @override
  Future<int> getScriptureCount() async {
    return await _isar.scriptures.count();
  }

  @override
  Future<bool> isListEmpty(String listName) async {
    final count = await _isar.scriptures.filter().listNameMatches(listName).count();
    return count == 0;
  }

  @override
  Future<void> renameList(String oldName, String newName) async {
    final scriptures = await _isar.scriptures.filter().listNameMatches(oldName).findAll();
    await _isar.writeTxn(() async {
      for (var s in scriptures) {
        s.listName = newName;
        await _isar.scriptures.put(s);
      }
    });
  }

  @override
  Future<List<String>> getAllListNames() async {
    return await _isar.scriptures.where().distinctByListName().listNameProperty().findAll();
  }

  @override
  Future<void> close({bool deleteFromDisk = false}) async {
    await _isar.close(deleteFromDisk: deleteFromDisk);
  }
}

/// Create a test database repository with a temporary directory
Future<DatabaseRepository> createTestDatabaseRepository() async {
  final repo = TestDatabaseRepository();
  await repo.init();
  return repo;
}
