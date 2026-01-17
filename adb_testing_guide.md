# ADB Testing Guide for Authentication

This guide provides step-by-step instructions for testing the authentication implementation on Android using ADB (Android Debug Bridge).

## Prerequisites

1. Android device or emulator connected
2. ADB installed and available in your PATH
3. App built with `flutter build apk --debug`

## Setup Commands

```bash
# Verify device connection
adb devices

# Install the app
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Clear app data (if needed for fresh testing)
adb shell pm clear com.gtdbible.memverse
```

## Manual Testing with Logcat

### 1. Happy Path Login Testing

```bash
# Start capturing logs
adb logcat -v time | grep -E "Analytics|Crashlytics|Auth" > login_success_logs.txt

# Launch the app
adb shell am start -n com.gtdbible.memverse/com.gtdbible.memverse.MainActivity

# (Manually perform login with correct credentials on device)

# Capture screenshot after successful login
adb shell screencap -p /sdcard/login_success.png
adb pull /sdcard/login_success.png ./screenshots/
```

### 2. Failed Login Testing

```bash
# Start capturing logs
adb logcat -v time | grep -E "Analytics|Crashlytics|Auth" > login_failure_logs.txt

# Clear app data for fresh start
adb shell pm clear com.gtdbible.memverse

# Launch the app
adb shell am start -n com.gtdbible.memverse/com.gtdbible.memverse.MainActivity

# (Manually perform login with incorrect credentials on device)

# Capture screenshot of error state
adb shell screencap -p /sdcard/login_failure.png
adb pull /sdcard/login_failure.png ./screenshots/
```

### 3. Network Error Testing

```bash
# Start capturing logs
adb logcat -v time | grep -E "Analytics|Crashlytics|Auth" > network_error_logs.txt

# Enable airplane mode
adb shell settings put global airplane_mode_on 1
adb shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true

# Launch the app
adb shell am start -n com.gtdbible.memverse/com.gtdbible.memverse.MainActivity

# (Manually perform login on device - should show network error)

# Capture screenshot of network error state
adb shell screencap -p /sdcard/network_error.png
adb pull /sdcard/network_error.png ./screenshots/

# Disable airplane mode
adb shell settings put global airplane_mode_on 0
adb shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false
```

## Log Analysis

After testing, analyze the captured logs to verify proper tracking:

```bash
# Check for login attempt analytics events
grep "login_attempt" login_success_logs.txt

# Check for successful login analytics events
grep "login_success" login_success_logs.txt

# Check for error events in failed login logs
grep "login_failure" login_failure_logs.txt
grep "app_error" login_failure_logs.txt

# Check for network error handling in network error logs
grep "connection_error" network_error_logs.txt
```

## Verification Checklist

- [ ] Login success: Navigates to main screen, logs analytics event
- [ ] Login failure: Shows error message, logs failure analytics event
- [ ] Network error: Shows user-friendly message, logs connectivity error
- [ ] Analytics events: All auth events properly captured
- [ ] Crashlytics reports: Errors properly reported with context
- [ ] No sensitive data: Username/password not logged in plain text

## Common Issues & Troubleshooting

1. **App crashes during login:** Check Crashlytics for stack traces
   ```bash
   adb logcat -v time | grep "Firebase-Crashlytics"
   ```

2. **No analytics events captured:** Verify Firebase initialization
   ```bash
   adb logcat -v time | grep "Firebase"
   ```

3. **Black screen after login:** Check for navigation errors
   ```bash
   adb logcat -v time | grep "Exception"
   ```

## Security Testing Notes

- Verify credentials are not saved in shared preferences in plain text:
  ```bash
  adb shell run-as com.gtdbible.memverse cat /data/data/com.gtdbible.memverse/shared_prefs/FlutterSharedPreferences.xml
  ```

- Verify sensitive data is not logged:
  ```bash
  adb logcat -v time | grep -i "password"
  ```