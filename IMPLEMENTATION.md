# Implementation Plan - Memverse Flutter App

This plan outlines the steps to build the `memverse_flutter` application by merging `scripture-app` and `memverse_project`.

## Journal
- **Phase 1 Start**: Initializing project structure and dependencies.

## Phase 1: Project Initialization & Foundation
- [ ] Initialize `memverse_flutter` package (Already created, but need to verify structure).
- [ ] Update `pubspec.yaml` to include combined dependencies from both projects.
    -   Core: `flutter_riverpod`, `hooks_riverpod`, `riverpod_annotation`, `go_router`, `freezed_annotation`, `json_annotation`.
    -   Data: `isar`, `isar_flutter_libs`, `dio`, `retrofit`, `logger`.
    -   Firebase: `firebase_core`, `firebase_analytics`, `firebase_messaging` (check if needed for combined), `firebase_crashlytics`.
    -   UI: `flutter_slidable`, `share_plus`, `blur`, `cupertino_icons`.
    -   Dev: `build_runner`, `riverpod_generator`, `isar_generator`, `retrofit_generator`, `json_serializable`, `freezed`.
- [ ] Run `flutter pub get`.
- [ ] Setup `analysis_options.yaml` (copy from `memverse_project` or use standard flutter_lints).
- [ ] Create folder structure: `lib/src/features`, `lib/src/utils`, `lib/src/services`.
- [ ] Setup `main.dart` with `ProviderScope` and basic `GoRouter` setup.
- [ ] Configure `android/app/build.gradle`:
    -   Update `applicationId` to `com.spiritflightapps.memverse`.
    -   Add `signingConfigs` block (referencing `key.properties` or env vars) matching `memverse_project`.
- [ ] Create/Update `android/key.properties` (placeholder or copy if available).
- [ ] Create `DESIGN.md` (Completed).
- [ ] Commit changes.
- [ ] Run the app (Hello World state) on an Android emulator to verify config.

## Phase 2: Demo Mode (Scripture App Port)
- [ ] Create `lib/src/features/demo` directory.
- [ ] Port `Scripture` model (Isar collection) from `scripture-app` to `lib/src/features/demo/data`.
- [ ] Port `Database` service (Isar init) to `lib/src/services`.
    -   *Task*: Ensure `Isar.open` handles Web support (schemas, directory).
- [ ] Port UI components (`ScriptureForm`, `ScriptureDialog`, `FutureItemTile`) to `lib/src/features/demo/presentation`.
- [ ] Port `MyHomePage` (renamed to `DemoHomeScreen`) and logic.
    -   *Task*: Refactor `Navigator.push` to `context.go` or `context.push`.
    -   *Task*: Replace `FirebaseRemoteConfig` calls with local constants/assets for the "first install list".
- [ ] Register `DemoHomeScreen` route in `GoRouter` (`/demo`).
- [ ] Run `dart run build_runner build`.
- [ ] Verify "Demo Mode" functionality (Add verse, List verses, Delete verse) on Android and Web.
- [ ] Commit changes.

## Phase 3: Signed-In Mode (Memverse Project Port)
- [ ] Create `lib/src/features/memverse` and `lib/src/features/auth` directories.
- [ ] Port Auth Models & State (`AuthRepository`, `User` model) from `memverse_project`.
- [ ] Port API Client (`RestClient` / Dio setup) from `memverse_project`.
- [ ] Port `LoginScreen` and `SignupScreen`.
    -   **Web Constraint**: Wrap these screens or the navigation to them with a check:
        -   If `kIsWeb`, display `WebAuthUnavailableScreen` ("Please download app...").
        -   Else, show the actual forms.
- [ ] Port `MemverseHome` / `Dashboard` from `memverse_project`.
- [ ] Register Routes: `/login`, `/signup`, `/memverse-home`.
- [ ] Run `dart run build_runner build`.
- [ ] Verify "Signed-In Mode" UI on Mobile (Login screen appears).
- [ ] Verify "Signed-In Mode" UI on Web (Message appears).
- [ ] **Critical**: Verify `android/app/build.gradle` release configuration matches the original Java/Kotlin Memverse app structure exactly (excluding flavors if not needed).
- [ ] Commit changes.

## Phase 4: Integration, Testing & Final Polish
- [ ] Create a `LandingScreen` (`/`) as the initial route.
    -   Buttons: "Try Demo" (Go to `/demo`), "Sign In" (Go to `/login`).
- [ ] Implement Auth State listening in `GoRouter`.
    -   If user is logged in (token exists), redirect `/` to `/memverse-home`.
- [ ] Update `MaterialApp` theme to combine styles.
- [ ] Ensure `Firebase.initializeApp` is called in `main.dart`.
- [ ] **Testing**:
    -   [ ] Create comprehensive Widget Tests for Demo Mode (Add/Edit/Delete flows).
    -   [ ] Create E2E Widget Tests covering the full user journey (Landing -> Demo -> Add Verse -> Verify).
    -   [ ] Create Integration Tests using `integration_test` package for on-device verification.
- [ ] Finalize `README.md` and `GEMINI.md`.
- [ ] Commit changes.
- [ ] Final manual walkthrough of the app.
