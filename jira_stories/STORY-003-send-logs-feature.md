# STORY-003: Add Send Logs Feature Using Talker

## Story Type
Enhancement

## Priority
Medium

## Description
As a user experiencing issues, I want an easy way to send logs to the developers so that they can diagnose and fix problems faster.

## Acceptance Criteria
- [ ] User can access "Send Logs" button in Settings screen
- [ ] Tapping the button opens a share dialog with logs
- [ ] Logs include last 500 entries from Talker
- [ ] Logs are formatted in a readable way (timestamp, level, message)
- [ ] User can choose to share via email, messages, or save to files
- [ ] Privacy: logs are reviewed locally before sending (user consent)
- [ ] Works on both iOS and Android

## Technical Notes

### Talker Built-in Features
Talker already provides excellent logging infrastructure:
- `TalkerFlutter.init()` - Automatically initialized in app
- `Talker.history` - Access to all logged events
- `TalkerScreen` - Built-in UI to view logs (already available)
- `TalkerFilter` - Can filter by log level, type, etc.

### Recommended Implementation

**Option 1: Use Talker's Built-in Share (Simplest)**
```dart
import 'package:talker_flutter/talker_flutter.dart';

// Talker already has a share button in TalkerScreen!
// Just add a button in Settings that navigates to TalkerScreen
ElevatedButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TalkerScreen(talker: AppLogger.talker),
      ),
    );
  },
  child: Text('View & Share Logs'),
);
```

**Option 2: Custom Share Implementation**
```dart
import 'package:share_plus/share_plus.dart';
import 'package:talker_flutter/talker_flutter.dart';

Future<void> shareLogs() async {
  final talker = AppLogger.talker;
  
  // Get last 500 log entries
  final logs = talker.history.take(500).map((log) {
    return '${log.displayTime} [${log.level}] ${log.message}';
  }).join('\n');
  
  // Create a formatted log file
  final logText = '''
MemVerse Flutter App Logs
Generated: ${DateTime.now().toIso8601String()}
Device: ${Platform.operatingSystem}
App Version: [TODO: get from package_info_plus]

========================================
LOGS
========================================

$logs
''';

  // Share using share_plus (already in dependencies)
  await Share.share(
    logText,
    subject: 'MemVerse App Logs - ${DateTime.now().toLocal()}',
  );
}
```

### Files to Modify
- `lib/src/features/settings/presentation/views/settings_screen.dart`
  - Add "Send Logs" or "View Logs" button
  - Wire up to Talker's TalkerScreen or custom share function

### Dependencies
- ✅ `talker_flutter` - Already installed
- ✅ `share_plus` - Already installed
- Optional: `package_info_plus` - For app version in logs

## User Flow

1. User experiences a bug or crash
2. User opens Settings
3. User taps "Send Logs" button
4. Option A: TalkerScreen opens with built-in share button
   - User can review logs
   - User taps share icon
   - Native share sheet opens
5. Option B: Custom share dialog opens immediately
   - User chooses email/messages/files
6. User sends logs to support email or saves locally

## Privacy Considerations
- [ ] Logs should NOT contain sensitive data:
  - ❌ Passwords
  - ❌ API tokens
  - ❌ Personal information
- [ ] Add disclaimer: "Logs may contain scripture references and app usage data"
- [ ] User must explicitly tap to share (no automatic sending)

## Estimate
2 story points (1 day)
- **Option 1 (Recommended)**: 1-2 hours - Just add navigation to TalkerScreen
- **Option 2 (Custom)**: 4-6 hours - Build custom share implementation

## Implementation Steps

### Option 1: Simple Approach (Recommended)
1. Add "View Logs" button to Settings screen
2. Navigate to `TalkerScreen(talker: AppLogger.talker)`
3. Test on iOS and Android
4. Done! Talker handles everything else

### Option 2: Custom Approach
1. Create `sendLogs()` function in `app_logger.dart`
2. Format logs with timestamps and levels
3. Use `share_plus` to share logs
4. Add "Send Logs" button to Settings
5. Test on iOS and Android

## Testing Checklist
- [ ] Generate some logs (navigate, add verses, trigger errors)
- [ ] Tap "Send Logs" button
- [ ] Verify logs are readable
- [ ] Test sharing via email
- [ ] Test sharing via messages
- [ ] Test saving to files
- [ ] Verify no sensitive data in logs
- [ ] Test on iOS
- [ ] Test on Android

## Related Files
- `lib/src/utils/app_logger.dart` - Talker instance
- `lib/src/features/settings/presentation/views/settings_screen.dart`
- Existing: `TalkerScreen` from `talker_flutter` package

## Example Code for Settings Screen

```dart
// Add to SettingsScreen build method
ListTile(
  leading: Icon(Icons.bug_report),
  title: Text('View Logs'),
  subtitle: Text('View and share app logs for troubleshooting'),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TalkerScreen(
          talker: globalContainer!.read(talkerProvider),
        ),
      ),
    );
  },
),
```

## Benefits
- **Fast debugging**: Developers can see exact logs from users
- **User empowerment**: Users can help diagnose their own issues
- **Better support**: Support team gets detailed context
- **Already 90% built**: Talker provides most functionality

## Future Enhancements (Post-MVP)
- Auto-upload logs to Firebase Crashlytics on crashes
- Filter logs by severity before sharing
- Include device info (OS version, app version, device model)
- Add "Report Bug" flow that attaches logs automatically

## Notes
- Talker's `TalkerScreen` already has a beautiful UI with search, filtering, and share
- Using built-in features is simpler and more maintainable
- Consider adding this to alpha test feedback form

## References
- Talker Documentation: https://pub.dev/packages/talker_flutter
- TalkerScreen example: Check `/Users/neil/.pub-cache/hosted/pub.dev/talker_flutter-5.0.0-dev.7/`
- Share Plus: https://pub.dev/packages/share_plus
