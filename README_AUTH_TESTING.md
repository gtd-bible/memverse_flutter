# Auth Feature Testing Utilities

This directory contains utilities for testing the authentication feature of the Memverse Flutter application. These tools help test various layers of the authentication stack, from direct API calls to Riverpod state management.

## Available Test Scripts

### 1. `test_auth_with_riverpod.dart`

A comprehensive testing script that tests the entire auth stack:

- **API Layer**: Direct API calls to the authentication endpoints
- **Service Layer**: Testing the `AuthService` with token storage
- **Provider Layer**: Testing Riverpod state management
- **Feature Tests**: Testing verse fetching with authentication

This test is the most thorough and uses the actual application code from multiple layers.

### 2. `test_auth_api_with_app_code.dart` 

A simpler test focusing on the API and service layers only. This test:

- Tests direct OAuth token acquisition
- Verifies login functionality
- Tests error handling

### 3. `test_signup_api_with_app_code.dart`

Tests the user registration flow:

- Fetches the signup page
- Extracts CSRF token if present
- Submits registration form
- Attempts login with newly created credentials

## Running the Tests

### Comprehensive Auth Stack Test

Use the included bash script for the easiest testing experience:

```bash
# Set required environment variables
export MEMVERSE_CLIENT_ID="your_client_id"
export MEMVERSE_CLIENT_API_KEY="your_client_api_key"  
export MEMVERSE_USERNAME="your_username"
export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT="your_password"

# Run the test
./run_auth_test.sh
```

This script will:
1. Validate environment variables
2. Run the comprehensive test
3. Save output to `auth_test_output.log`
4. Display a summary of test results

### Direct Test Execution

You can also run the tests directly with Dart:

```bash
# For the comprehensive test
dart run test_auth_with_riverpod.dart

# For the API test
dart run test_auth_api_with_app_code.dart

# For the signup test
dart run test_signup_api_with_app_code.dart
```

## Security Notes

- **No secrets are hardcoded** in any of these test files
- All sensitive data must be provided via environment variables
- Logging redacts sensitive data automatically
- For CI/CD environments, use secure environment variables

## Test Utils

The `lib/src/utils/auth_test_utils.dart` class provides shared utilities for all tests:

- Creating configured Dio instances
- Extracting CSRF tokens from HTML
- Creating form data payloads
- Redacting sensitive data
- Handling error responses
- Testing credentials
- Summarizing responses

## Integration with Manual Testing

These scripts can be used alongside manual testing to validate authentication flows from the command line before attempting in the app. This is especially helpful for debugging authentication issues without needing to rebuild the entire app.

## Contributing

When enhancing the auth feature:

1. Update these test scripts to match any API changes
2. Ensure all tests pass before submitting PRs
3. Add new test cases for edge cases and error conditions