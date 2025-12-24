import '../features/demo/data/scripture.dart';

/// Abstract database repository interface
/// Allows swapping database implementations for testing and future migrations
abstract class DatabaseRepository {
  /// Initialize the database
  Future<void> init();

  /// Add a new scripture to the database
  Future<void> addScripture(Scripture scripture);

  /// Delete a scripture by ID
  Future<void> deleteScripture(int scriptureId);

  /// Get all scriptures for a specific list
  Future<List<Scripture>> getScripturesByList(String listName);

  /// Get the total count of all scriptures
  Future<int> getScriptureCount();

  /// Check if a list is empty
  Future<bool> isListEmpty(String listName);

  /// Rename a list (updates all scriptures with the old name)
  Future<void> renameList(String oldName, String newName);

  /// Get all distinct list names
  Future<List<String>> getAllListNames();

  /// Close the database connection (for testing cleanup)
  Future<void> close({bool deleteFromDisk = false});
}
