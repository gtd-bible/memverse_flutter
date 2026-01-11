# Firebase iOS Manual App Distribution Deployment Guide

This guide is for deploying your iOS build (IPA) to testers using Firebase App Distribution manually (outside Codemagic/GitHub Actions).

---

## Prerequisites
- You have a .ipa built via `scripts/deploy_ios.sh` (use `--firebase` mode)
- [Firebase CLI](https://firebase.google.com/docs/cli) is installed (`npm install -g firebase-tools`)
- You have access to your Firebase project and the correct App ID (can find in Firebase Console)

---

## Steps

1. **Authenticate (first time only):**
   ```bash
   firebase login
   ```

2. **Upload the IPA:**
   ```bash
   firebase appdistribution:distribute build/ios/ipa/YourApp.ipa \
     --app <your-ios-firebase-app-id> \
     --groups "Testers" \
     --release-notes "Built $(date '+%Y-%m-%d') via scripts/deploy_ios.sh --firebase"
   ```
   - Replace `<your-ios-firebase-app-id>` with your app’s Firebase project App ID
   - Adjust group/release-notes as desired

3. **Testers receive email with download link.**

---

## Tips
- Run `firebase appdistribution:distribute --help` for more options
- You can use this flow for ad-hoc uploads between automation runs or for a quick hotfix
- Your TESTER_TYPE will show as `firebase_alpha_ios`, so analytics will always be clear
