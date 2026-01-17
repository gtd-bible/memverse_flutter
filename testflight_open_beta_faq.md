# TestFlight Open Beta FAQ and User Instructions

This document gives a simple, step-by-step guide for participating in the public TestFlight open beta for MiniMemverse—including copying/pasting commands and clear instructions for users and deployers (no UDID needed).

---

## For Developers: Deployment Step-by-Step

1. **Prepare environment variables:**
   ```bash
   export MEMVERSE_CLIENT_ID=your_id
   export MEMVERSE_CLIENT_API_KEY=your_api_key
   export FIREBASE_APP_DIST=alpha
   ```

2. **Build the IPA:**
   ```bash
   ./deploy_ios.sh
   # Or do a dry run first to test on simulator:
   ./deploy_ios.sh --dry-run
   ```

3. **Upload the IPA:**
   - Open Xcode, go to Organizer, and upload the IPA to App Store Connect
   - Or use the Transporter app (drag/drop .ipa)

4. **Enable Public Beta Link:**
   - Open your app in App Store Connect > TestFlight
   - Create a new Group, select Public Link, and define max testers
   - Submit the build for beta review (Apple will approve in ~1 day)

5. **Share the link:**
   - Copy the Public Link and share with users

---

## For Users: Joining the Open Beta

1. **Install TestFlight:**
   - On your iPhone, open the App Store. Search for "TestFlight" and install it

2. **Join the MiniMemverse Beta:**
   - Click the shared public beta link
   - TestFlight will prompt you to install MiniMemverse
   - Open the app and use as normal

---

## FAQ

**Q: Is this different from private beta (UDID/whitelist)?**
A: Yes. Open beta is much easier—just use the link. No device registration necessary.

**Q: Will Apple review my beta build?**
A: Yes, but review is much faster (~1 day) and only on first upload and major updates.

**Q: Will using the beta affect my App Store version?**
A: No. TestFlight betas are separate and expire after 90 days.

**Q: Is my data safe/confidential during beta?**
A: All usage follows MiniMemverse’s privacy policy. You can opt out or uninstall at any time.

**Q: How do I give feedback?**
A: Use the TestFlight app’s "Send Beta Feedback" feature, or email/support as directed in the app or description.

---

**See also:**  testflight_open_beta.md for full process and Apple’s docs:
https://developer.apple.com/testflight/
