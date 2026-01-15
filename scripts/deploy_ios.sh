#!/bin/bash

# Usage: ./deploy_ios.sh [--testflight] [--firebase] [--dry-run] [--help]
# Required env vars:
#   MEMVERSE_CLIENT_ID  (Your client id)
#   MEMVERSE_CLIENT_API_KEY  (Your client api key)

show_help() {
  cat <<EOF
Usage: ./deploy_ios.sh [--testflight] [--firebase] [--dry-run] [--help]

Options:
  --dry-run     Run on currently booted (or default) simulator and do integration test
  --testflight  Use testflight tester_type (testflight_beta_ios) [default]
  --firebase    Use firebase tester_type (firebase_alpha_ios)
  --help        Show this help message and exit

Environment variables needed:
  export MEMVERSE_CLIENT_ID=your_id
  export MEMVERSE_CLIENT_API_KEY=your_api_key
EOF
}

# Default option will be selected via interactive prompt if not specified

while [ $# -gt 0 ]; do
  case $1 in
    --help)
      show_help
      exit 0
      ;;
    --testflight)
      TESTER_TYPE="testflight_beta_ios"
      ;;
    --firebase)
      TESTER_TYPE="firebase_alpha_ios"
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
  shift
done

if [[ "$DRY_RUN" == "true" ]]; then
  echo "[DRY RUN] Running flutter app on iOS Simulator (booted or default) with integration smoke test..."
  flutter run \
    --dart-define=MEMVERSE_CLIENT_ID="$MEMVERSE_CLIENT_ID" \
    --dart-define=MEMVERSE_CLIENT_API_KEY="$MEMVERSE_CLIENT_API_KEY" \
    --dart-define=TESTER_TYPE="$TESTER_TYPE"
  echo "Running smoke test (integration_test/smoke_test.dart)..."
  flutter test integration_test/smoke_test.dart
  exit $?
fi

if [[ "$1" != "" ]]; then
  echo "Unknown parameter $1."
  show_help
  exit 1
fi

# Choose distribution method if not already selected
if [[ -z "$TESTER_TYPE" ]]; then
  echo "Please choose a distribution method:"
  echo "1) TestFlight (Open Beta) [Recommended]"
  echo "2) Firebase App Distribution (Alpha testers)"
  read -p "Enter 1 or 2 [default: 1]: " DIST_CHOICE
  
  case "$DIST_CHOICE" in
    2)
      TESTER_TYPE="firebase_alpha_ios"
      echo "Selected: Firebase App Distribution (Alpha)"
      ;;
    *)
      TESTER_TYPE="testflight_beta_ios"
      echo "Selected: TestFlight (Beta)"
      ;;
  esac
fi

# Interactive confirmation
echo "About to build, sign, and package an IPA for release."
echo "Required env vars: MEMVERSE_CLIENT_ID, MEMVERSE_CLIENT_API_KEY"
echo "Using tester_type: $TESTER_TYPE"
echo "Are you sure you want to continue? [Y/n]"
read -r CONFIRM
if [[ "$CONFIRM" =~ ^([nN][oO]?|[nN])$ ]]; then
  echo "Aborted. To do a dry run instead, use ./deploy_ios.sh --dry-run"
  exit 1
fi

EXPORT_PLIST=ios/ExportOptions.plist
flutter build ipa \
  --export-options-plist=$EXPORT_PLIST \
  --dart-define=MEMVERSE_CLIENT_ID="$MEMVERSE_CLIENT_ID" \
  --dart-define=MEMVERSE_CLIENT_API_KEY="$MEMVERSE_CLIENT_API_KEY" \
  --dart-define=TESTER_TYPE="$TESTER_TYPE"

echo "📱 IPA built successfully. Now adding Swift support..."

# Find the IPA file
IPA_PATH=$(find build/ios/ipa -name "*.ipa" | head -1)
IPA_FILENAME=$(basename "$IPA_PATH")
IPA_DIR=$(dirname "$IPA_PATH")

if [[ -z "$IPA_PATH" ]]; then
  echo "❌ Error: Could not find IPA file in build/ios/ipa/"
  exit 1
fi

echo "📦 Found IPA: $IPA_FILENAME"

# Create a temporary directory for fixing the IPA
TEMP_DIR=$(mktemp -d)
echo "🔧 Extracting IPA to $TEMP_DIR..."

# Extract the IPA
unzip -q "$IPA_PATH" -d "$TEMP_DIR"

# Create SwiftSupport directory
mkdir -p "$TEMP_DIR/SwiftSupport"

# Find and copy Swift frameworks
echo "🔍 Looking for Swift frameworks..."
if [[ -d "$TEMP_DIR/Payload/"*.app/Frameworks ]]; then
  echo "✅ Found frameworks, copying to SwiftSupport..."
  cp -R "$TEMP_DIR/Payload/"*.app/Frameworks/*.framework "$TEMP_DIR/SwiftSupport/" 2>/dev/null || true
  
  # Check if any frameworks were copied
  if [[ $(find "$TEMP_DIR/SwiftSupport" -name "*.framework" | wc -l) -gt 0 ]]; then
    echo "✅ Swift frameworks copied successfully"
  else
    echo "⚠️ No Swift frameworks found to copy. This might be OK if your app doesn't use Swift."
  fi
else
  echo "⚠️ No Frameworks directory found. This might be OK if your app doesn't use Swift."
fi

# Create fixed IPA
echo "📦 Creating fixed IPA with SwiftSupport..."
FIXED_IPA_PATH="$IPA_DIR/Fixed_$IPA_FILENAME"

# Go to temp dir and zip everything back
(cd "$TEMP_DIR" && zip -qr "$FIXED_IPA_PATH" Payload SwiftSupport)

# Move the fixed IPA to replace the original
mv "$FIXED_IPA_PATH" "$IPA_PATH"

# Clean up
rm -rf "$TEMP_DIR"

echo "✅ Fixed IPA with SwiftSupport created successfully at $IPA_PATH"
echo "🚀 Ready for upload to TestFlight or Firebase App Distribution!"

if [[ "$TESTER_TYPE" == "testflight_beta_ios" ]]; then
  echo ""
  echo "📱 TESTFLIGHT UPLOAD INSTRUCTIONS:"
  echo "-----------------------------------"
  echo "Option 1: Use Apple Transporter app"
  echo "- Open Apple Transporter app"
  echo "- Sign in with your Apple Developer account"
  echo "- Click + and select your IPA at: $IPA_PATH"
  echo "- Click Upload and wait for completion"
  echo ""
  echo "Option 2: Use Terminal with xcrun altool"
  echo "export ASC_USERNAME=\"your_apple_id@example.com\""
  echo "export ASC_APP_SPECIFIC_PASSWORD=\"your_app_specific_password\""
  echo "xcrun altool --upload-app -f $IPA_PATH -t ios -u \"\$ASC_USERNAME\" -p \"\$ASC_APP_SPECIFIC_PASSWORD\""
  echo ""
  echo "After upload, go to App Store Connect → TestFlight to set up testing"
  echo "https://appstoreconnect.apple.com/apps"
fi
