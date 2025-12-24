import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_repository.dart';
import 'sembast_database_repository.dart';

/// Provider for the database repository
/// Can be overridden in tests with a mock implementation
final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return SembastDatabaseRepository();
});

/// Legacy provider for backwards compatibility during migration
/// This wraps the new repository interface
@Deprecated('Use databaseRepositoryProvider instead')
final databaseProvider = Provider<DatabaseRepository>((ref) {
  return ref.watch(databaseRepositoryProvider);
});
