# firebase_audiences.md

## How to Send an In-App Message: “Are you enjoying this beta?”
This guide shows you how to create an audience, send an in-app message to that audience, and track user responses with Firebase Analytics in your Flutter app. **No private info is included—safe for public repos!**

---

### 1. Define an Analytics User Property
Set a custom analytics user property (e.g., `firebase_app_dist`):

```dart
await FirebaseAnalytics.instance.setUserProperty(
  name: 'firebase_app_dist',
  value: 'beta', // Or any string to denote beta audience
);
```
This should be set via your deploy script and AnalyticsManager.

---

### 2. Create an Audience in Firebase Console
- Go to **Firebase Console** → **Analytics** → **Audiences**
- Click **New Audience**
- **Include users where:**  
  *User Property* → `firebase_app_dist` → *equals* → `beta`
- Name your audience, e.g., `Beta Testers`

---

### 3. Set Up Firebase In-App Messaging
- Go to **Engage** → **In-App Messaging**
- Click **Create campaign**
- **Target Audience:** Select the `Beta Testers` audience
- **Message Type:** Card, Modal, or Banner (Card works well)
- **Message Content:**
  - **Title:** "Enjoying this Beta?"
  - **Body:** "We'd love your feedback."
  - **Primary action:** "Yes!"
  - **Secondary action:** "No" or "Not Really"

---

### 4. Track Analytics on User Response
Handle clicks on these buttons using an analytics event, e.g.:

```dart
FirebaseAnalytics.instance.logEvent(
  name: 'beta_feedback',
  parameters: {
    'response': 'yes' // or 'no', depending on button tapped
  },
);
```

If using Firebase default buttons, In-App Messaging logs action events automatically. For more control, use a custom dialog and Firestore/Remote Config.

---

### 5. Review Analytics in Console
- Go to **Analytics** → **Events** in Firebase Console
- Filter or search for your custom event name, e.g., `beta_feedback`
- Review breakdown for `yes`/`no` by audience/user property

---

### 6. (Optional) Use `firebase_in_app_messaging` for Custom Control
For advanced feedback, integrate [`firebase_in_app_messaging`](https://pub.dev/packages/firebase_in_app_messaging) for native messaging and analytics.

---

## Summary Table

| Step | Action | Firebase Section |
|------|---------------------------------------|-------------------------------|
| 1 | Set user property for audience | Analytics (Dart code) |
| 2 | Create audience for beta testers | Analytics → Audiences |
| 3 | Create in-app message for audience | Engage → In-App Messaging |
| 4 | Track user responses with events | Analytics (Dart code/Console) |
| 5 | Review feedback event in analytics | Analytics → Events |

---

**Pro Tips:**
- Keep event/parameter names consistent for easy filtering.
- Reuse this strategy for feedback and feature rollouts.
- Don’t use any sensitive user data in analytics or in-app messages.
