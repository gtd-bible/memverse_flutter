# LLM Notes - Critical Context for AI Assistants

## ⚠️ CRITICAL RULES - READ FIRST

### 1. Code MUST Compile After Every Prompt
- **NEVER** leave code in a non-compiling state
- Run `flutter analyze lib` before completing ANY response
- Fix ALL compilation errors before finishing
- If uncertain, ask the user rather than breaking compilation

### 2. Authentication Architecture
**Auth is via OAuth API, NOT Firebase Auth**
- We use custom OAuth with the Memverse API
- `RealAuthService` calls our API endpoints for login/logout
- `FakeAuthService` for testing
- Firebase is ONLY for: Analytics, Crashlytics, Messaging
- **DO NOT** use `firebase_auth` package
- **DO NOT** assume Firebase handles authentication

### 3. Database Architecture
**We use Sembast, NOT Isar**
- Isar was replaced due to maintenance issues
- All database operations go through `DatabaseRepository` interface
- `SembastDatabaseRepository` is the implementation
- **DO NOT** reference Isar in any code
- **DO NOT** add Isar dependencies

### 4. Testing Philosophy
**Focus on BDD tests that are readable and maintainable**
- Use `bdd_widget_test` for user-facing scenarios
- Feature files should describe user behavior, not implementation
- Integration tests should require ZERO mocking when possible
- Demo mode tests should work without Firebase

## Project Structure

### Features
- **Demo Mode** (`lib/src/features/demo/`) - Works without authentication
  - Local database only (Sembast)
  - No API calls required
  - Entry point for new users
  
- **Auth** (`lib/src/features/auth/`) - Custom OAuth, NOT Firebase
  - `RealAuthService` - API-based auth
  - `FakeAuthService` - Testing
  - API endpoints in `auth_api.dart`
  
- **Memverse** (`lib/src/features/memverse/`) - Authenticated features
  - Requires login via OAuth API
  - Syncs with Memverse web app

### Services
- **Database** - Sembast via `DatabaseRepository` interface
- **Analytics** - Firebase Analytics (optional, not required for demo)
- **Crashlytics** - Firebase Crashlytics (optional)
- **Messaging** - Firebase Messaging (optional)

## Common Mistakes to Avoid

### ❌ DON'T
- Use Firebase Auth
- Reference Isar
- Leave code that doesn't compile
- Write BDD tests with extensive mocking
- Assume Firebase is required for demo mode
- Break existing functionality without asking

### ✅ DO
- Verify compilation with `flutter analyze lib`
- Check test compilation with `flutter analyze test`
- Use `DatabaseRepository` for all database ops
- Keep BDD tests simple and readable
- Focus on user-facing scenarios
- Ask for clarification when uncertain

## Current State

### What Works
- ✅ Demo mode (local only, no auth)
- ✅ Database operations via Sembast
- ✅ Basic routing
- ✅ Scripture add/view/delete in demo mode

### What Needs Work
- ⚠️ Firebase options file (out of date, but not blocking demo mode)
- ⚠️ Integration tests (scaffolded but not all passing)
- ⚠️ BDD tests (cleaned up, need reimplementation)
- ⚠️ Signed-in mode (OAuth API integration incomplete)

## Key Files

### Must Read Before Making Changes
- `lib/src/features/auth/data/auth_service.dart` - Auth interface
- `lib/src/features/auth/data/real_auth_service.dart` - OAuth implementation
- `lib/src/services/database_repository.dart` - Database interface
- `lib/src/routing/app_router.dart` - Route configuration

### Configuration
- `pubspec.yaml` - Dependencies (NO isar, NO firebase_auth)
- `lib/firebase_options.dart` - Firebase config (Analytics/Crashlytics only)
- `lib/main.dart` - App entry point

## Testing Commands

### Before Finishing ANY Response
```bash
# Check main app compiles
flutter analyze lib

# Check tests compile
flutter analyze test

# Check integration tests compile
flutter analyze integration_test

# Run a quick smoke test
flutter test test/src/services/database_repository_test.dart
```

### To Run Full Test Suite
```bash
# Unit tests
flutter test test/src/

# Integration tests
flutter test integration_test/
```

## Debugging Tips

### If Code Won't Compile
1. Check for Isar references: `grep -r "isar\|Isar" lib/ test/`
2. Check for Firebase Auth: `grep -r "firebase_auth\|FirebaseAuth" lib/`
3. Run `flutter clean && flutter pub get`
4. Check `flutter analyze lib` output

### If Tests Won't Compile
1. Remove broken test files rather than leaving them broken
2. Check for missing mocks or test helpers
3. Verify imports are correct
4. Run `flutter analyze test`

## Communication Guidelines

### When Uncertain
- Ask the user for clarification
- Don't assume Firebase Auth
- Don't assume Isar is still in use
- Check llm_notes.md for context

### When Making Changes
- State what you're changing and why
- Verify compilation before finishing
- Make atomic commits
- Push after each logical change

## Version Info
- Flutter: 3.38.5
- Dart: 3.10.4
- Database: Sembast (not Isar)
- Auth: Custom OAuth API (not Firebase Auth)
- Last Updated: 2024-12-24
