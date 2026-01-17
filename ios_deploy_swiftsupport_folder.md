# iOS Deployment: Fixing the SwiftSupport Folder Issue

This document outlines different approaches to resolve the common TestFlight error:

> Invalid Swift Support. The SwiftSupport folder is missing. Rebuild your app using the current public (GM) version of Xcode and resubmit it. (90426)

## Why This Happens

Flutter's IPA export process doesn't always properly include the SwiftSupport folder required by App Store Connect. This folder needs to contain the Swift standard libraries used by your app.

## Solution 1: Automated Script Approach (Implemented)

Our current solution automates the process of adding the SwiftSupport folder:

1. **ExportOptions.plist** (in `/ios/ExportOptions.plist`):
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>compileBitcode</key>
       <false/>
       <key>destination</key>
       <string>export</string>
       <key>method</key>
       <string>app-store</string>
       <key>provisioningProfiles</key>
       <dict>
           <key>com.memverse.minimemverse</key>
           <string>MiniMemverse Distribution</string>
       </dict>
       <key>signingCertificate</key>
       <string>Apple Distribution</string>
       <key>signingStyle</key>
       <string>manual</string>
       <key>stripSwiftSymbols</key>
       <false/>
       <key>teamID</key>
       <string>YOUR_TEAM_ID</string>
       <key>uploadBitcode</key>
       <false/>
       <key>uploadSymbols</key>
       <true/>
       <key>thinning</key>
       <string>&lt;none&gt;</string>
   </dict>
   </plist>
   ```

2. **SwiftSupport Script** (in `/ios/add_swift_support.sh`):
   ```bash
   #!/bin/bash
   
   # This script ensures SwiftSupport is properly included in the IPA
   # Run this after creating an archive but before exporting the IPA
   
   # Use provided archive path or find latest
   if [ -n "$1" ]; then
     ARCHIVE_PATH="$1"
     echo "📦 Using provided archive: $ARCHIVE_PATH"
   else
     ARCHIVE_DIR="$HOME/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)"
     ARCHIVE_PATH=$(ls -t "$ARCHIVE_DIR"/*.xcarchive | head -1)
     
     if [ -z "$ARCHIVE_PATH" ]; then
       echo "❌ No recent archives found at $ARCHIVE_DIR"
       exit 1
     fi
     
     echo "📦 Using latest archive: $ARCHIVE_PATH"
   fi
   
   # Create SwiftSupport directory if it doesn't exist
   SWIFT_SUPPORT_PATH="$ARCHIVE_PATH/SwiftSupport"
   if [ ! -d "$SWIFT_SUPPORT_PATH" ]; then
     mkdir -p "$SWIFT_SUPPORT_PATH"
     echo "📁 Created SwiftSupport directory"
   fi
   
   # Copy Swift dylibs from the app's Frameworks to SwiftSupport
   APP_FRAMEWORKS_PATH="$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks"
   if [ -d "$APP_FRAMEWORKS_PATH" ]; then
     echo "🔍 Finding Swift frameworks..."
     SWIFT_FRAMEWORKS=$(find "$APP_FRAMEWORKS_PATH" -name "libswift*.dylib")
     
     if [ -z "$SWIFT_FRAMEWORKS" ]; then
       echo "⚠️ No Swift frameworks found in $APP_FRAMEWORKS_PATH"
     else
       echo "✅ Copying Swift frameworks to SwiftSupport..."
       for framework in $SWIFT_FRAMEWORKS; do
         cp "$framework" "$SWIFT_SUPPORT_PATH/"
         echo "   - $(basename "$framework")"
       done
     fi
   else
     echo "❌ Frameworks directory not found at $APP_FRAMEWORKS_PATH"
     exit 1
   fi
   
   echo "✅ Swift support preparation complete!"
   exit 0
   ```

3. **Deployment Script** (modified `/scripts/deploy_ios.sh`):
   ```bash
   # Build the app for archiving
   flutter build ios --release \
     --dart-define=MEMVERSE_CLIENT_ID="$MEMVERSE_CLIENT_ID" \
     --dart-define=MEMVERSE_CLIENT_API_KEY="$MEMVERSE_CLIENT_API_KEY" \
     --dart-define=TESTER_TYPE="$TESTER_TYPE"
   
   # Create the archive directly with xcodebuild (fully automated)
   echo "📱 Creating archive..."
   
   ARCHIVE_PATH="$HOME/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)"
   mkdir -p "$ARCHIVE_PATH"
   ARCHIVE_FILENAME="MiniMemverse_$(date +%Y-%m-%d_%H%M%S).xcarchive"
   FULL_ARCHIVE_PATH="$ARCHIVE_PATH/$ARCHIVE_FILENAME"
   
   # Build and archive using xcodebuild
   xcodebuild -workspace ios/Runner.xcworkspace \
     -scheme Runner \
     -configuration Release \
     -archivePath "$FULL_ARCHIVE_PATH" \
     archive
   
   # Run script to ensure SwiftSupport folder exists
   echo "🔧 Ensuring SwiftSupport folder exists..."
   ./ios/add_swift_support.sh "$FULL_ARCHIVE_PATH"
   
   # Export IPA with the correct options
   echo "📦 Creating IPA from archive..."
   xcodebuild -exportArchive \
     -archivePath "$FULL_ARCHIVE_PATH" \
     -exportOptionsPlist "$EXPORT_PLIST" \
     -exportPath "build/ios/ipa" \
     -allowProvisioningUpdates
   ```

## Solution 2: Manual Xcode Approach

If the automated script doesn't work, you can try the direct Xcode UI approach:

1. **Open Xcode**:
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. **Create an Archive**:
   - Select the "Runner" scheme and "Any iOS Device (arm64)" as the destination
   - Go to Product > Archive
   - Wait for archive process to complete

3. **Distribute via Xcode**:
   - When the Archive window opens, click "Distribute App"
   - Select "App Store Connect" then "Upload"
   - Follow the prompts to submit to App Store Connect
   - Ensure "Include bitcode" is unchecked (unless required by your app)
   - Ensure "Upload symbols" is checked for crash reporting
   - Click "Next" and then "Upload"

This method is more reliable because Xcode handles the SwiftSupport folder automatically.

## Solution 3: Using flutter_app_builder Plugin

The flutter_app_builder plugin can automate the process:

1. **Add the package**:
   ```bash
   flutter pub add flutter_app_builder --dev
   ```

2. **Run the build command**:
   ```bash
   flutter pub run flutter_app_builder:main build ios
   ```

This approach uses a custom build process that addresses common Flutter iOS build issues.

## Solution 4: Manually Fix the IPA Post-Build

If you've already built an IPA, you can fix it manually:

1. **Unzip the IPA**:
   ```bash
   mkdir -p tmp/Payload
   mkdir -p tmp/SwiftSupport
   unzip build/ios/ipa/YourApp.ipa -d tmp/
   ```

2. **Copy Swift frameworks**:
   ```bash
   cp -r tmp/Payload/*.app/Frameworks/libswift*.dylib tmp/SwiftSupport/
   ```

3. **Repackage the IPA**:
   ```bash
   cd tmp
   zip -r ../fixed_app.ipa Payload SwiftSupport
   cd ..
   mv fixed_app.ipa build/ios/ipa/YourApp.ipa
   ```

## Solution 5: Use Latest Xcode

Make sure you're using the latest public (GM) version of Xcode:

1. **Check your current Xcode version**:
   ```bash
   xcodebuild -version
   ```

2. **Update Xcode** from the Mac App Store or the Apple Developer website

3. **Select the correct Xcode version** if you have multiple installed:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app
   ```

## Solution 6: Temporary Workaround via fastlane

If you're using fastlane, add this to your Fastfile:

```ruby
lane :fix_swift_support do
  Dir.chdir("..") do
    puts "Fixing SwiftSupport folder..."
    `mkdir -p /tmp/SwiftSupport`
    `find #{ENV['PWD']}/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Frameworks -name "*.dylib" -type f | xargs -I {} cp {} /tmp/SwiftSupport/`
    `cd /tmp && zip -r #{ENV['PWD']}/build/ios/ipa/Runner.ipa SwiftSupport`
  end
end
```

And then run:
```bash
fastlane fix_swift_support
```

## Troubleshooting

1. **Check for Swift content**: Your app might be using Swift without you knowing it through dependencies.

2. **Verify archive contents**: Inspect the .xcarchive contents:
   ```bash
   find /path/to/YourApp.xcarchive -name "*.dylib" | grep swift
   ```
   
3. **Validate IPA**: Before uploading, validate using:
   ```bash
   xcrun altool --validate-app -f build/ios/ipa/Runner.ipa -t ios -u "your@email.com"
   ```

4. **Check signing issues**: Sometimes signing problems can be misreported as SwiftSupport issues.

## References

- [Apple Technical Note TN2339](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [Flutter GitHub Issue #60235](https://github.com/flutter/flutter/issues/60235)
- [Stack Overflow: SwiftSupport folder is missing](https://stackoverflow.com/questions/50129582/error-itms-90426-invalid-swift-support-the-swiftsupport-folder-is-missing)