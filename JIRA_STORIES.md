# JIRA Stories - Future Enhancements

## Low Priority Stories

### STORY-001: Investigate Google Sign-In Support
**Priority**: Low  
**Type**: Research / Feature Investigation  
**Status**: Backlog

**Description**:
Research and potentially implement Google Sign-In as an alternative authentication method for the app.

**Background**:
Currently, the app only supports email/password authentication. We've simplified the analytics tracking to remove the `signUpMethod` and `loginMethod` parameters since we only have one auth method. This story is to investigate adding Google Sign-In in the future.

**Requirements**:
1. **First Step**: Coordinate with API/Web team
   - Check if the Memverse API supports Google OAuth
   - Understand what backend changes are needed
   - Get API endpoints/documentation for Google auth

2. **Mobile Implementation** (only after API is ready):
   - Add `google_sign_in` package
   - Implement Google Sign-In flow
   - Update analytics to track auth method
   - Test on iOS and Android

**Acceptance Criteria**:
- [ ] API team confirms Google OAuth is supported on backend
- [ ] Backend provides necessary endpoints/documentation
- [ ] Mobile app can authenticate via Google
- [ ] Analytics properly tracks login method
- [ ] Works on both iOS and Android
- [ ] Existing email/password auth still works

**Technical Notes**:
- Current code has been simplified - removed `loginMethod` and `signUpMethod` parameters
- See git history for how it was structured before (commit fc06aea)
- Firebase Analytics supports `loginMethod` parameter when ready

**Dependencies**:
- 🔴 **BLOCKER**: API/Web team must implement Google OAuth on backend first
- Firebase already configured and ready
- Analytics service ready to add method tracking back

**Effort Estimate**: 
- API coordination: 1-2 sprints (not our team)
- Mobile implementation: 3-5 days (once API ready)

**Notes for Future Developer**:
- Talk to the API/web guy FIRST before starting any mobile work
- The analytics service is already abstracted - easy to add back auth method tracking
- Check `lib/src/services/analytics_service.dart` for interface
- Current implementation in `lib/src/services/firebase_analytics_service.dart`

**Related Files**:
- `lib/src/services/analytics_service.dart`
- `lib/src/services/firebase_analytics_service.dart`
- `lib/src/features/auth/data/auth_service.dart`

---

## Notes
- This file tracks future enhancement stories
- Add new stories as needed
- Keep priority and dependencies updated
