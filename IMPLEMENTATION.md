# Implementation Plan - Memverse Flutter App

This plan outlines the steps to build the `memverse_flutter` application by merging `scripture-app` and `memverse_project`.

## Journal
- **Phase 1 Start**: 2025-12-23 - Initializing project structure and dependencies.
- **Phase 1 Complete**: 2025-12-23 23:30 - Foundation established with clean architecture.
- **Phase 2 Start**: 2025-12-23 23:30 - Beginning Demo Mode port.
- **Phase 2 Complete**: 2025-12-24 00:07 - Demo Mode fully functional.
- **Database Migration**: 2025-12-24 00:30 - Migrated from Isar to Sembast for better compatibility.

## Phase 1: Project Initialization & Foundation ✅ COMPLETE
- ✅ Initialize `memverse_flutter` package
- ✅ Update `pubspec.yaml` to include combined dependencies from both projects
    - Core: `flutter_riverpod`, `hooks_riverpod`, `riverpod_annotation`, `go_router`, `freezed_annotation`, `json_annotation`
    - Data: ~~`isar`, `isar_flutter_libs`~~ **Replaced with `sembast`** (more actively maintained, no AGP issues), `dio`, `retrofit`, `logger`
    - Firebase: `firebase_core`, `firebase_analytics`, `firebase_messaging`, `firebase_crashlytics`
    - UI: `flutter_slidable`, `share_plus`, `blur`, `cupertino_icons`
    - Dev: `build_runner`, `riverpod_generator`, ~~`isar_generator`~~, `retrofit_generator`, `json_serializable`, `freezed`
- ✅ Run `flutter pub get`
- ✅ Setup `analysis_options.yaml` with 100-character line length
- ✅ Create folder structure: `lib/src/features`, `lib/src/utils`, `lib/src/services`
- ✅ Setup `main.dart` with `ProviderScope` and basic `GoRouter` setup
- ✅ Configure `android/app/build.gradle` with proper signing and versioning
- ✅ Create `DESIGN.md`
- ✅ Commit changes (Phase 1 complete)
- ✅ Verify app runs on Android emulator

## Phase 2: Demo Mode (Scripture App Port) ✅ COMPLETE
- ✅ Create `lib/src/features/demo` directory
- ✅ Port `Scripture` model - **Refactored from Isar to plain Dart class with JSON serialization**
- ✅ **Database Abstraction Layer** - Created `DatabaseRepository` interface for testability
- ✅ Port `Database` service - **Implemented with Sembast for Android, iOS, and Web support**
- ✅ Port UI components (`ScriptureForm`, `ScriptureDialog`, `FutureItemTile`)
- ✅ Port `MyHomePage` (renamed to `DemoHomeScreen`) with all functionality
    - ✅ Refactored to use Riverpod providers
    - ✅ Replaced Firebase Remote Config with local default verses
- ✅ Register `DemoHomeScreen` route in `GoRouter` (`/demo`)
- ✅ Verify "Demo Mode" functionality (Add verse, List verses, Delete verse)
- ✅ Commit changes (Phase 2 complete)

### Testing Status - WIP 🚧
- ✅ Unit Tests for Scripture model
- ✅ Comprehensive Unit Tests for DatabaseRepository
- 🚧 Widget Tests for Demo Mode components (IN PROGRESS)
- 🚧 E2E Widget Tests for complete user flows (IN PROGRESS)
- ⏳ Manual testing on Android device (PENDING)
- ⏳ Manual testing on iOS device (PENDING)
- ⏳ Manual testing on Web (PENDING)

## Phase 3: Signed-In Mode (Memverse Project Port) ⏳ NOT STARTED
- [ ] Create `lib/src/features/memverse` and `lib/src/features/auth` directories
- [ ] Port Auth Models & State (`AuthRepository`, `User` model)
- [ ] Port API Client (`RestClient` / Dio setup)
- [ ] Port `LoginScreen` and `SignupScreen`
    - **Web Constraint**: Display `WebAuthUnavailableScreen` on web platform
- [ ] Port `MemverseHome` / `Dashboard`
- [ ] Register Routes: `/login`, `/signup`, `/memverse-home`
- [ ] Run `dart run build_runner build`
- [ ] Verify "Signed-In Mode" UI on Mobile and Web
- [ ] Verify `android/app/build.gradle` release configuration
- [ ] Commit changes

## Phase 4: Integration, Testing & Final Polish ⏳ NOT STARTED
- [ ] Create a `LandingScreen` (`/`) as the initial route
    - Buttons: "Try Demo" (Go to `/demo`), "Sign In" (Go to `/login`)
- [ ] Implement Auth State listening in `GoRouter`
- [ ] Update `MaterialApp` theme to combine styles
- [ ] Ensure `Firebase.initializeApp` is called in `main.dart`
- [ ] **Testing**:
    - [ ] Widget Tests for Auth Mode screens
    - [ ] Integration Tests using `integration_test` package
    - [ ] Manual testing on all platforms
- [ ] Finalize `README.md`
- [ ] Commit changes
- [ ] Final manual walkthrough of the app

## Technical Decisions

### Database Choice: Sembast (Replaced Isar)
**Date**: 2025-12-24
**Reason**: Isar project appears to be discontinued (GitHub issue #1689: "Isar is dead, long live Isar") and has compatibility issues with Android Gradle Plugin 8.11+. Sembast provides:
- ✅ Active maintenance (latest release 2025-12)
- ✅ Pure Dart implementation (no native code generation issues)
- ✅ Full support for Android, iOS, Web, Desktop
- ✅ Simple NoSQL database with filtering and indexing
- ✅ Easy testing with in-memory databases
- ✅ No build_runner code generation required

### Architecture: Repository Pattern
**Date**: 2025-12-24
**Implementation**: Created `DatabaseRepository` abstract interface with `SembastDatabaseRepository` implementation
**Benefits**:
- ✅ Easy to mock for unit testing
- ✅ Clean separation of concerns
- ✅ Future database migrations simplified
- ✅ Test coverage without database dependencies

## Current Status
**Phase**: 2 (Demo Mode) - Testing Phase
**Last Updated**: 2025-12-24 00:30
**Next Steps**:
1. Complete widget tests for all Demo Mode components
2. Write E2E widget tests for full user journeys
3. Manual testing on Android device with video recording
4. Update README.md with setup instructions and demo
5. Begin Phase 3 (Signed-In Mode)
