# STORY-001: Add Google Sign-In Support

## Story Type
Enhancement

## Priority
Low

## Description
As a user, I want to sign in with Google so that I can quickly access the app without creating a separate account.

## Acceptance Criteria
- [ ] User can tap "Sign in with Google" button on login screen
- [ ] Google OAuth flow completes successfully
- [ ] User is logged in with their Google account
- [ ] User profile is created/updated with Google account info
- [ ] Analytics track "google" as the login method
- [ ] Error handling for OAuth failures

## Technical Notes
**🔴 BLOCKER: Backend API must support Google OAuth first**

### Prerequisites
1. Coordinate with API/Web team to implement Google OAuth on backend
2. Verify Memverse API endpoints support Google authentication
3. Obtain OAuth client IDs for iOS and Android
4. Configure Firebase Authentication for Google sign-in

### Implementation Steps
1. Add `google_sign_in` package to pubspec.yaml
2. Update `AnalyticsService` to support multiple login methods:
   - Restore optional `loginMethod` parameter
   - Track "email" vs "google" authentication
3. Create `GoogleAuthService` implementation
4. Update `LoginScreen` to show Google sign-in button
5. Add integration tests for Google auth flow

### Dependencies
- `google_sign_in: ^6.1.0` (or latest)
- Firebase Authentication must be configured
- Backend API must have Google OAuth endpoints

## Estimate
8 story points (5 days)
- 1 day: Backend coordination and setup
- 2 days: Frontend implementation
- 1 day: Testing and error handling
- 1 day: Analytics integration and polish

## Related Files
- `lib/src/services/analytics_service.dart`
- `lib/src/services/firebase_analytics_service.dart`
- `lib/src/features/auth/data/real_auth_service.dart`
- `lib/src/features/auth/presentation/views/login_screen.dart`

## Notes
- **First Step**: Talk to the API/web team to confirm backend support
- Google Sign-In is a common user request
- May also want to consider Apple Sign-In for iOS (App Store requirement if other social logins exist)
