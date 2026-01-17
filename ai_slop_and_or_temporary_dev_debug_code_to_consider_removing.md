# Temporary Debug/Dev Code to Consider Removing

This document lists code that was added temporarily for development or debugging purposes and should be considered for cleanup before production release.

## Library Code

### Auth Feature

- **`lib/src/utils/auth_test_utils.dart`**
  - This entire utility class was created for testing but is imported in production code
  - Should be moved to the test directory or refactored as a proper API utility

- **`lib/src/features/auth/utils/auth_error_debugger.dart`**
  - Contains simulation methods specifically for testing error scenarios
  - The `runComprehensiveTest()` method should be moved to test code

- **`lib/src/utils/test_utils_stub.dart`**
  - Added as a workaround for conditional imports
  - Should be refactored to use proper dependency injection

- **`lib/src/features/verse/data/verse_repository.dart`**
  - Has conditional import with `if (dart.library.io)` for test utilities
  - Contains the `isInTestMode` function that should be abstracted

- **`lib/services/app_logger_facade.dart`**
  - Has excessive debug logging that should be simplified for production
  - May contain unnecessary crashlytics initializations

### Firebase Integration

- **`lib/main.dart`**
  - Has debug environment variable checks
  - Contains explicit environment validation that could be simplified
  - Detailed error messages that expose internal structure

### API Implementation

- **`lib/src/features/auth/data/auth_api.dart`**
  - Manual implementation as a temporary replacement for retrofit generated code
  - Contains debug-specific logging (`_logOAuthRequest` method)
  - Has duplicate content type headers in POST requests

## Test Code

### Integration Tests

- **`integration_test/minimal_happy_path_test.dart`**
  - Temporary minimal test that should be expanded or replaced
  - Uses hardcoded keys and simplified approach

- **`integration_test/unhappy_path_login_test.dart`**
  - Contains screenshot logic that was causing build issues
  - Should be refactored to handle screenshotting more elegantly

### Direct Tests

- **`direct_auth_test.dart`**
  - Should be moved to the proper test directory structure
  - Bypasses app code for direct API testing

### Test Utilities

- **`test/features/auth/test_utils/login_test_utils.dart`**
  - Contains utility code that duplicates functionality in the main app
  - Should be harmonized with production utilities

## Configuration Files

- **.env.example**
  - Might need to be expanded with all required environment variables

- **run_app.sh**
  - Contains temporary testing setup code

## Build Scripts

- **scripts/deploy_ios.sh**
  - May contain temporary debug options