# Story: Migrate Local Database from Isar to Sembast or Drift

**Story Point Estimate:** 8
**Priority:** High
**Tags:** technical-debt, database, architecture

## Description
The current local database, Isar, is effectively unmaintained. This poses a significant risk to the project's longevity and stability. We need to migrate to a supported, stable alternative.

Based on the [Analysis](../analysis/database_comparison.md), we have identified **Sembast** and **Drift** as the primary candidates.

## Goal
Replace the implementation of `IsarDatabaseRepository` with a new repository implementation using either Sembast or Drift, ensuring all existing features (CRUD operations for Verses) work identically.

## Acceptance Criteria
1.  [ ] Select final candidate (Drift or Sembast) - *Decision: Drift recommended for long-term structure, Sembast for ease.*
2.  [ ] Add new dependencies (`drift`, `sqlite3_flutter_libs` OR `sembast`).
3.  [ ] Create new Database Repository implementation (e.g., `DriftDatabaseRepository` or `SembastDatabaseRepository`).
4.  [ ] Migrate existing data models (if necessary, add Drift tables or Sembast logic).
5.  [ ] Ensure all Unit/Widget tests pass with the new implementation.
6.  [ ] Remove Isar dependencies and code.
7.  [ ] Verify performance is acceptable.

## Implementation Steps
1.  **Repo Interface:** Ensure `DatabaseRepository` interface is generic enough.
2.  **Implementation:** Build the concrete class.
3.  **DI:** Swap the injection in `main.dart` / Riverpod providers.
4.  **Data Migration:** (Optional) If we need to keep existing user data, write a migration script to copy data from Isar to the new DB on first launch. *Note: If app is still in early alpha, we might just wipe data.*
