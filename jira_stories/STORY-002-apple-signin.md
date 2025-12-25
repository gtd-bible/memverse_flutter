# STORY-002: Add Apple Sign-In Support

## Story Type
Enhancement

## Priority
Medium (required for App Store if Google Sign-In is implemented)

## Description
As an iOS user, I want to sign in with Apple so that I have a private and secure authentication method.

## Acceptance Criteria
- [ ] User can tap "Sign in with Apple" button on login screen (iOS only)
- [ ] Apple OAuth flow completes successfully
- [ ] User is logged in with their Apple ID
- [ ] User profile is created/updated with Apple account info
- [ ] Analytics track "apple" as the login method
- [ ] Error handling for OAuth failures
- [ ] Button only shows on iOS devices

## Technical Notes
**⚠️ App Store Requirement**: If we add Google Sign-In (or any third-party social login), Apple requires we also offer Sign in with Apple.

### Prerequisites
1. Backend API must support Apple OAuth
2. Apple Developer account must be configured
3. Sign in with Apple capability enabled in Xcode
4. Service ID configured in Apple Developer Console

### Implementation Steps
1. Add `sign_in_with_apple` package to pubspec.yaml
2. Update `AnalyticsService` to track "apple" login method
3. Create `AppleAuthService` implementation
4. Update `LoginScreen` to show Apple sign-in button (iOS only)
5. Configure Xcode project with Sign in with Apple capability
6. Add integration tests for Apple auth flow

### Dependencies
- `sign_in_with_apple: ^5.0.0` (or latest)
- Firebase Authentication must be configured
- Backend API must have Apple OAuth endpoints
- Apple Developer account

## Estimate
5 story points (3 days)
- 1 day: Backend coordination and Apple Developer setup
- 1 day: Frontend implementation
- 1 day: Testing and iOS-specific handling

## Related Files
- `lib/src/services/analytics_service.dart`
- `lib/src/features/auth/data/real_auth_service.dart`
- `lib/src/features/auth/presentation/views/login_screen.dart`
- `ios/Runner/Runner.entitlements` (new file)

## Notes
- Should be implemented together with or after Google Sign-In
- Apple Sign-In provides enhanced privacy features
- Required by App Store guidelines if other social logins exist
