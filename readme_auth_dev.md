# Authentication Developer Guide

## Architecture Overview

Our authentication system follows a clean architecture approach with a comprehensive error handling and analytics system.

### Key Components

#### 1. Auth Service
- `AuthService`: Handles API communication for login/logout operations
- Uses OAuth 2.0 password grant flow
- Located in `lib/src/features/auth/data/auth_service.dart`

#### 2. State Management
- `AuthNotifier`: Riverpod state notifier that manages authentication state
- `AuthState`: Immutable state class with authentication information
- Located in `lib/src/features/auth/presentation/providers/auth_providers.dart`

#### 3. Error Handling
- `AuthErrorHandler`: Processes auth errors consistently with detailed logging
- Translates server/network errors to user-friendly messages
- Located in `lib/src/features/auth/utils/auth_error_handler.dart`

#### 4. Analytics
- `AnalyticsFacade`: Handles all analytics event tracking
- Interfaces with Firebase Analytics and Crashlytics
- Located in `lib/src/monitoring/analytics_facade.dart`

#### 5. Logging
- `AppLoggerFacade`: Comprehensive logging system
- Integrates with Talker for in-app error visualization
- Located in `lib/services/app_logger_facade.dart`

## Authentication Flow

1. **Login Attempt**:
   ```dart
   final token = await _authService.login(username, password, _clientId, _clientSecret);
   ```

2. **Success Handling**:
   ```dart
   // Set user ID for future analytics
   await _analyticsFacade.setUserId(token.userId.toString());
   
   // Log success event
   await _analyticsFacade.logEvent(
     'login_success',
     parameters: {
       'user_id': token.userId?.toString() ?? 'unknown',
       'token_type': token.tokenType,
       'authenticated': true,
     },
   );
   ```

3. **Error Handling**:
   ```dart
   final userFriendlyError = await _errorHandler.processError(
     e,
     stackTrace,
     context: 'Login',
     additionalData: {
       'username_provided': username.isNotEmpty,
       'username_length': username.length,
     },
   );
   ```

## Adding New Authentication Features

### Adding a New Auth Method (Example: Sign In with Google)

1. **Update AuthService**:

   ```dart
   Future<AuthToken?> loginWithGoogle(String idToken) async {
     try {
       // Implement API call
       final response = await _dio.post<dynamic>(
         '$apiBaseUrl/oauth/token',
         data: {
           'grant_type': 'google',
           'id_token': idToken,
           'client_id': clientId,
           'client_secret': clientSecret,
         },
       );
       
       return _processAuthResponse(response);
     } catch (e) {
       // Let error handler in AuthNotifier handle this
       rethrow;
     }
   }
   ```

2. **Update AuthNotifier**:

   ```dart
   Future<void> loginWithGoogle() async {
     try {
       state = state.copyWith(isLoading: true, error: null);
       
       // Get Google sign-in token using google_sign_in package
       // ...
       
       final token = await _authService.loginWithGoogle(idToken);
       
       // Rest of code similar to regular login
       // ...
     } catch (e, stackTrace) {
       // Use our error handler
       final userFriendlyError = await _errorHandler.processError(
         e, stackTrace,
         context: 'Google Login',
         additionalData: {'auth_method': 'google'},
       );
       
       state = state.copyWith(isLoading: false, error: userFriendlyError);
     }
   }
   ```

3. **Update Analytics**:
   - Add new event tracking in `AnalyticsClient` interface
   - Implement in both `FirebaseAnalyticsClient` and `LoggerAnalyticsClient`

### Error Handling for New Auth Methods

Always use the `AuthErrorHandler.processError` method for consistent error handling:

```dart
final userFriendlyError = await _errorHandler.processError(
  e,
  stackTrace,
  context: 'YourAuthMethod',
  additionalData: {
    'custom_field1': 'value1',
    'custom_field2': 'value2',
  },
);
```

This ensures:
1. Errors are logged to Crashlytics
2. Analytics events are tracked
3. User-friendly messages are generated
4. Debug logs are comprehensive

## Testing

### Unit Tests

Run the auth-specific unit tests:

```bash
flutter test test/features/auth
```

Key test files:
- `test/features/auth/presentation/auth_error_handling_test.dart`
- `test/src/monitoring/analytics_facade_test.dart`

### Integration Tests

Run integration tests that verify the full auth flow:

```bash
flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/auth_error_handling_test.dart
```

For Android Firebase debugging:

```bash
flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/android_firebase_debug_test.dart --dart-define=IS_FIREBASE_DEBUG=true
```

### Manual API Testing

Use the `test_api_signin.dart` script to test the authentication API directly:

```bash
export MEMVERSE_CLIENT_ID="your_client_id"
export MEMVERSE_CLIENT_API_KEY="your_client_secret"
export MEMVERSE_USERNAME="your_test_username"
export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT="your_test_password"
dart test_api_signin.dart
```

## Environment Variables

Authentication requires these environment variables:

- `MEMVERSE_CLIENT_ID`: OAuth client ID
- `MEMVERSE_CLIENT_API_KEY`: OAuth client secret

These can be passed to the Flutter run command:

```bash
flutter run \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY
```

## Common Issues & Solutions

### 1. Expired OAuth Client Credentials
If authentication suddenly stops working, check if OAuth client credentials have expired.

### 2. Testing Auth Changes
Always verify analytics and error handling when making auth changes:
1. Test successful login
2. Test invalid credentials
3. Test network failure
4. Test server errors
5. Verify events in Firebase Analytics
6. Verify error reports in Crashlytics

### 3. Adding New Error Types
If adding new error types, update:
1. `_extractUserFriendlyMessage` in AuthErrorHandler
2. Add analytics events in AnalyticsClient
3. Add tests for the new error type

## Best Practices

1. **Never log sensitive data**:
   - Use `_redactSensitiveFields` in AuthErrorHandler
   - Never log full tokens, passwords, or secrets

2. **User-friendly error messages**:
   - Keep messages clear and actionable
   - Don't expose technical details to users
   - Use consistent messaging

3. **Analytics Best Practices**:
   - Include timestamp in events
   - Use consistent event naming
   - Include enough context for analysis

4. **Error Tracking**:
   - Always include stacktraces
   - Add contextual data to Crashlytics
   - Make error groups identifiable