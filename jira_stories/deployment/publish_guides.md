# Story: Deployment Guides & Automation

**Story Point Estimate:** 5
**Priority:** Medium

## Description
Create clear, foolproof documentation and scripts for deploying to various channels.

## Guides Required

### 1. Firebase App Distribution (iOS & Android)
*   **Goal:** Quick internal testing.
*   **Steps:**
    1.  Install Firebase CLI.
    2.  Build APK/IPA: `flutter build apk --release`, `flutter build ipa --release`.
    3.  Upload: `firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app <APP_ID>`.
    4.  (Detail exact commands in the final doc).

### 2. iOS TestFlight
*   **Goal:** External Beta.
*   **Steps:**
    1.  Bump version in `pubspec.yaml`.
    2.  `flutter build ipa`.
    3.  Open `ios/Runner.xcworkspace`.
    4.  Product > Archive > Distribute App > TestFlight.

### 3. Google Play Console (Open Beta)
*   **Goal:** Public Beta testing.
*   **Pros:**
    *   **Private Feedback:** User reviews in Open Beta are not public and do not affect the final store rating.
    *   **Early Access:** Real users can try it before full launch.
*   **Cons:**
    *   Users might think it's "buggy" if they don't realize it's beta (though it is labeled).
*   **Steps:**
    1.  `flutter build appbundle`.
    2.  Upload `.aab` to Play Console > Testing > Open Testing.
    3.  Promote release.

## Deliverable
A `DEPLOYMENT.md` file in the root with copy-pasteable commands and checklists.
