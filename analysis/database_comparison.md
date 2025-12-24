# Database Comparison Analysis

**Date:** December 23, 2025
**Context:** Evaluation of local database solutions for `memverse_flutter`.

## Candidates
1.  **Isar** (Current)
2.  **Hive CE** (Community Edition)
3.  **Sembast**
4.  **Drift** (formerly Moor)

## Analysis

### 1. Isar (Current)
*   **Status:** **Unmaintained/Abandoned**. The original author has largely stepped away, and updates are infrequent or non-existent for long periods. Issues pile up without resolution.
*   **Pros:** Extremely fast, good DX (Developer Experience), synchronous API options.
*   **Cons:** **CRITICAL:** Lack of maintenance makes it a high-risk liability for a production app. Future Flutter SDK updates could break it with no fix in sight. Web support exists but can be quirky with massive bundles (WASM).
*   **Verdict:** **MIGRATE AWAY IMMEDIATELY.** The "bus factor" is effectively 0.

### 2. Hive CE (Community Edition)
*   **Status:** A community fork of the abandoned Hive.
*   **Pros:** Fast, simple key-value store, lightweight.
*   **Cons:** Not a relational DB. Complex queries are harder. Type adapters can be tedious. The transition from original Hive to CE is still settling.
*   **Verdict:** Good for simple preferences, maybe too simple for complex verse queries if relational data is needed later.

### 3. Sembast (Simple Embedded Database)
*   **Status:** Stable, maintained by a reliable author (Alexandre Roux).
*   **Pros:**
    *   **All Dart:** No native code dependency, meaning it works *everywhere* (Android, iOS, Web, Desktop) without specific native build setups.
    *   **Web Support:** Excellent (uses IndexedDB).
    *   **API:** NoSQL document store, flexible.
*   **Cons:** Performance is generally slower than Isar/Drift for massive datasets (100k+ records) because it runs on the Dart VM, but for a Bible verse app, this is likely negligible.
*   **Verdict:** **Strong Candidate.** Excellent stability and cross-platform compatibility.

### 4. Drift (Relational/SQL)
*   **Status:** Highly active, industry standard for SQL in Flutter.
*   **Pros:**
    *   **SQL:** Robust querying, relations, compile-time safety.
    *   **Backend:** Can use `sqlite3` (native) or `sql.js`/`sqlite3_flutter_libs` (web).
    *   **Performance:** Very high.
*   **Cons:** Boilerplate (though reduced with code gen). SQL knowledge required (though Dart API is good).
*   **Verdict:** **Strong Candidate.** Best if relational data integrity is paramount.

## Recommendation

**Switch to Drift or Sembast.**

*   **Choose Drift** if you prefer a strict Schema, SQL power, and maximum performance.
*   **Choose Sembast** if you want simplicity, 100% Dart portability (no JNI/native build issues), and document-store flexibility.

**Given the current project scope (Bible verses), Sembast is likely the easiest migration path with sufficient performance, but Drift offers the most "future-proof" architecture for complex data.**

**Final Decision:** Plan migration to **Drift** (for robustness) or **Sembast** (for simplicity/portability).
