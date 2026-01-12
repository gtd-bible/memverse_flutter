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
  --testflight  Use testflight tester_type (testflight_beta_ios)
  --firebase    Use firebase tester_type (firebase_alpha_ios) [default]
  --help        Show this help message and exit

Environment variables needed:
  export MEMVERSE_CLIENT_ID=your_id
  export MEMVERSE_CLIENT_API_KEY=your_api_key
EOF
}

TESTER_TYPE="firebase_alpha_ios"

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

echo "IPA build complete. Find IPA in build/ios/ipa/."
echo "Ready for upload to TestFlight or Firebase App Distribution!"
