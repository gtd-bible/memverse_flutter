# Authentication QA Guide

## Overview

This document provides comprehensive information for QA testing of the authentication system in the Memverse Flutter app.

## Test Scenarios

### 1. Basic Authentication

#### 1.1 Successful Login
- **Prerequisites**: Valid account credentials
- **Steps**:
  1. Launch the app
  2. Enter valid username and password
  3. Tap "Login" button
- **Expected Result**: 
  - User is successfully logged in and directed to dashboard
  - No error messages displayed
  - Auth token stored securely
  
#### 1.2 Failed Login - Invalid Credentials
- **Prerequisites**: None
- **Steps**:
  1. Launch the app
  2. Enter invalid username and/or password
  3. Tap "Login" button
- **Expected Result**: 
  - User-friendly error message: "Invalid username or password. Please try again."
  - User remains on login screen
  - Analytics event "auth_error" sent with appropriate parameters

#### 1.3 Failed Login - Empty Fields
- **Prerequisites**: None
- **Steps**:
  1. Launch the app
  2. Leave username and/or password empty
  3. Tap "Login" button
- **Expected Result**: 
  - Validation message shown for empty fields
  - Login request not sent
  - Analytics event "form_validation_error" sent

#### 1.4 Successful Logout
- **Prerequisites**: User is logged in
- **Steps**:
  1. Navigate to Settings
  2. Tap "Logout" button
  3. Confirm logout
- **Expected Result**: 
  - User is logged out
  - Session terminated
  - User directed to login screen

### 2. Network Error Scenarios

#### 2.1 Connection Timeout
- **Prerequisites**: Device in airplane mode or network disabled
- **Steps**:
  1. Launch app with network disabled
  2. Enter valid credentials
  3. Tap "Login" button
- **Expected Result**: 
  - User-friendly error message: "Cannot connect to the server. Please check your internet connection."
  - Analytics and Crashlytics events logged with error details

#### 2.2 Server Errors (500 Series)
- **Prerequisites**: Test environment that can simulate 500 errors
- **Steps**:
  1. Configure test environment for 500 error
  2. Login with valid credentials
- **Expected Result**: 
  - User-friendly error message: "The server encountered an error. Please try again later."
  - Error details logged to Crashlytics
  - Analytics event "http_error_500" logged

### 3. Edge Cases

#### 3.1 Empty Token Response
- **Prerequisites**: Test environment that returns empty token
- **Steps**:
  1. Configure test for empty token
  2. Attempt login
- **Expected Result**: 
  - User-friendly error: "Login failed. Please try again later."
  - "login_empty_token" analytics event logged
  - Error recorded in Crashlytics

#### 3.2 Server Unreachable
- **Prerequisites**: Server DNS unreachable
- **Steps**:
  1. Configure DNS to unreachable address
  2. Attempt login
- **Expected Result**: 
  - Connection error message displayed
  - Error details logged to Crashlytics
  - Analytics event for connection error sent

## Verification Tools

### 1. Firebase Console
- **Analytics**: https://console.firebase.google.com/project/_/analytics/overview
  - Check for login_attempt, login_success, auth_error events
  - Verify parameters include username_length, timestamp, etc.
  
- **Crashlytics**: https://console.firebase.google.com/project/_/crashlytics
  - Verify authentication errors are captured
  - Check custom keys for context (username_provided, client_id_provided)

### 2. Debug Logging
- **Android**:
  ```
  adb shell setprop log.tag.FA VERBOSE
  adb shell setprop log.tag.FA-SVC VERBOSE
  adb logcat -v time | grep -E 'FA|Firebase|Crashlytics'
  ```
- **iOS**:
  - Enable Analytics debug mode in Xcode scheme arguments:
    - `-FIRDebugEnabled`
    - `-FIRAnalyticsDebugEnabled`

## Integration Tests

Run integration tests to verify error handling:

```bash
# Run auth error handling test
flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/auth_error_handling_test.dart

# Android Firebase debug test
flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/android_firebase_debug_test.dart --dart-define=IS_FIREBASE_DEBUG=true
```

## Common Issues and Troubleshooting

### 1. Analytics Events Not Appearing
- Events may take up to 24 hours to appear in the Firebase console
- For immediate verification, use debug logging as described above

### 2. Crashlytics Not Reporting Errors
- Verify Crashlytics collection is enabled
- Force a test crash using the integration test
- Check device logs for Crashlytics initialization messages

### 3. Inconsistent Error Messages
- If user-facing error messages are inconsistent, check:
  - `AuthErrorHandler.extractUserFriendlyMessage` method
  - DioException handling in error handler

## Reporting Issues
When reporting authentication issues, please include:

1. Steps to reproduce
2. Full error message displayed to user
3. Network conditions
4. Device and OS version
5. App version
6. Screenshots
7. Any relevant logs from debug mode