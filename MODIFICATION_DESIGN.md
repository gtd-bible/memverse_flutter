# Design Document: Navigation Preferences & Configuration Fixes

## 1. Overview
This design covers three main objectives:
1.  **Navigation Logic Update:** Implement a "Preferred Tab" setting for authenticated users, defaulting to the "Ref Quiz" tab (Index 2) generally, but "Home" (Index 0) on the very first launch. Users can override this via Settings.
2.  **Environment Configuration UX:** Improve the error experience when required environment variables (`CLIENT_ID`, `MEMVERSE_CLIENT_API_KEY`) are missing, providing copy-pasteable shell commands.
3.  **Test Remediation:** Fix the failing `mockingjay` widget tests by addressing unmocked dependencies (environment variables, navigation methods).

## 2. Analysis & Problem

### 2.1 Navigation
**Current State:**
- `SignedInNavScaffold` hardcodes the initial tab to Index 1 (Verse Quiz).
- No persistence for user preference.
- No "First Launch" tracking.

**Requirements:**
- **First Launch:** Show Home (Index 0).
- **Subsequent Launches:** Show Ref Quiz (Index 2).
- **User Preference:** Allow user to choose between Home, Verse Quiz, or Ref Quiz. If set, this overrides the default behavior.
- **Home Tab Message:** Show a tip on the Home tab about setting the default.

### 2.2 Configuration Errors
**Current State:**
- `main.dart` checks for `CLIENT_ID` and shows a generic `ConfigurationErrorWidget`.
- Messages are static text.

**Requirements:**
- Show exact `export` commands for `zshrc`/`bashrc`.

### 2.3 Tests
**Current State:**
- `login_page_test.dart` fails due to:
    1.  Missing `CLIENT_ID` env var (exception thrown by provider).
    2.  `MockNavigator` returning `null` for `canPop` (causing TypeError).
- Other tests (`app_router_test.dart`) are broken/outdated.

**Requirements:**
- Fix `login_page_test.dart`.

## 3. Design & Implementation

### 3.1 Persistence Layer
We will use `flutter_secure_storage` (already a dependency) to store:
- `is_first_launch` (String "true"/"false")
- `preferred_tab_index` (String "0", "1", "2")
- `alpha_tester` (String "true"/"false")
- `beta_tester` (String "true"/"false")

**New Provider:** `PreferencesRepository`
- Methods: `getPreferredTab()`, `setPreferredTab(int)`, `isFirstLaunch()`, `setFirstLaunch(bool)`, etc.

### 3.2 Navigation Logic (`SignedInNavScaffold`)
- **Initialization:**
    - Watch `PreferencesRepository`.
    - `useState` for `selectedIndex` will be initialized based on logic:
      ```dart
      int initialIndex;
      if (prefs.preferredTab != null) {
        initialIndex = prefs.preferredTab;
      } else if (prefs.isFirstLaunch) {
        initialIndex = 0; // Home
        prefs.setFirstLaunch(false);
      } else {
        initialIndex = 2; // Ref Quiz
      }
      ```

### 3.3 Settings Screen
- Add a Dropdown/Selector for "Default Tab".
- Options: "Home", "Verse Quiz", "Ref Quiz".
- Updates `PreferencesRepository`.
- **Alpha/Beta Switch:** Ensure these also update `PreferencesRepository` so the UI state is preserved on restart (in addition to calling Firebase).

### 3.4 Configuration Error Widget
- Modify `ConfigurationErrorWidget` to accept the missing variable name.
- Generate text:
  ```
  export CLIENT_ID="debug"
  export MEMVERSE_CLIENT_API_KEY="your_api_key"
  ```
- Detect OS (roughly) or just provide standard Unix export commands (since user specified `darwin` and `zsh`).

### 3.5 Test Fixes (`login_page_test.dart`)
- **Fix 1 (Env Var):** Override `clientIdProvider` in the `ProviderScope` of the test.
  ```dart
  overrides: [
    clientIdProvider.overrideWithValue('test_client_id'),
  ]
  ```
- **Fix 2 (Mockingjay):**
  - Stub `canPop`: `when(() => mockNavigator.canPop()).thenReturn(false);` (or true, depending on context).
  - Review if other methods need stubbing.

## 4. Alternatives Considered
- **Shared Preferences:** Lighter weight than Secure Storage for simple bools, but Secure Storage is already in `pubspec.yaml` and used. Better to stick to one storage solution.
- **Hydrated Bloc / Riverpod Persist:** Overkill for just a few settings.

## 5. Summary
We will wrap `flutter_secure_storage` in a simple Repository, inject it via Riverpod, and use it to drive the initial state of `SignedInNavScaffold`. We will also patch the tests by providing missing dependencies.
