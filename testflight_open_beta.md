# TestFlight Open Beta Setup for MiniMemverse

This doc gives step-by-step instructions for submitting, configuring, and inviting users to a public (open) TestFlight beta—**no UDID collection required**.

---

## 1. Prepare Your App for TestFlight

- Ensure the IPA is built using the release process (see deploy_ios.sh). Example:
  ```bash
  export MEMVERSE_CLIENT_ID=your_id
  export MEMVERSE_CLIENT_API_KEY=your_api_key
  export FIREBASE_APP_DIST=alpha
  ./deploy_ios.sh
  # This script produces build/ios/ipa/*.ipa
  ```

## 2. Upload to App Store Connect

- Log in to [App Store Connect](https://appstoreconnect.apple.com/).
- Go to **My Apps** > your app.
- Click **TestFlight** tab
- Upload your IPA via **Xcode Organizer** (recommended) or via **Transporter** app.

## 3. Create a New TestFlight Beta

- After processing, the build appears under 'TestFlight/Beta Builds'
- Under 'Groups', click **New Group** > Name it "Open Beta" or similarly.
- Select "Public Link".
- Set the maximum number of testers (up to 10,000).
- Copy the invite link to share later.

## 4. Submit Beta Review

- Your first TestFlight beta requires a review by Apple. Fill in the required compliance and beta test notes/questions.
- Apple usually approves beta builds within 24-48 hours.
- After approval, public users can join with the TestFlight link

## 5. Share Public Link

- Paste the public TestFlight link anywhere: website, email, social, Discord, etc.
- Users install Apple’s TestFlight app, then join your beta via the link. No UDID or device registration is required—Apple manages onboarding.

---

## FAQ

**Q: Will users need their UDID or to be whitelisted?**  
A: No—Open/Public TestFlight groups allow anyone (up to 10,000) via invite link. No manual onboarding required.

**Q: Does this impact my App Store app?**  
A: No. TestFlight builds do not affect your live App Store app.

**Q: Can I see user feedback and crashes?**  
A: Yes. See feedback in App Store Connect > TestFlight.

**Q: How often can I update the app?**  
A: You may upload new builds for review at any time. Each is valid for 90 days.

---

## Summary & Usage Instructions

1. Build and upload IPA as above.
2. Enable Public Link in TestFlight group settings.
3. Send invite link to your beta users.
4. Approve beta builds after upload (applies only to new versions or first time).

**For detailed Apple docs:**  https://developer.apple.com/testflight/
