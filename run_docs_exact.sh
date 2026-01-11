#!/bin/bash

# Get the available emulators/simulators
DEVICES=$(flutter devices)
DEVICE_ID=""

# Check for Android emulator first
if echo "$DEVICES" | grep -q "emulator"; then
  DEVICE_ID=$(echo "$DEVICES" | grep "emulator" | head -1 | awk '{print $2}')
  echo "Found Android emulator: $DEVICE_ID"
# Or try iPhone simulator
elif echo "$DEVICES" | grep -q "iPhone"; then
  DEVICE_ID=$(echo "$DEVICES" | grep "iPhone" | head -1 | awk '{print $2}')
  echo "Found iPhone simulator: $DEVICE_ID"
else
  echo "No emulator or simulator found. Please start one before running this script."
  echo "Available devices:"
  echo "$DEVICES"
  exit 1
fi

# Set defaults if not provided
MEMVERSE_CLIENT_ID="${MEMVERSE_CLIENT_ID:-debug}"
MEMVERSE_CLIENT_API_KEY="${MEMVERSE_CLIENT_API_KEY:-}"

echo "====================================================================================="
echo "🚀 Running with EXACT command from RUNNING.md (lines 29-32)"
echo "====================================================================================="
echo "Using device: $DEVICE_ID"
echo ""
echo "Environment variables:"
echo "MEMVERSE_CLIENT_ID: ${#MEMVERSE_CLIENT_ID} characters"
echo "MEMVERSE_CLIENT_API_KEY: ${#MEMVERSE_CLIENT_API_KEY} characters"
echo ""
echo "Command:"
echo "flutter run -d \"$DEVICE_ID\" \\"
echo "  --dart-define=MEMVERSE_CLIENT_ID=\$MEMVERSE_CLIENT_ID \\"
echo "  --dart-define=MEMVERSE_CLIENT_API_KEY=\$MEMVERSE_CLIENT_API_KEY"
echo "====================================================================================="

# Run the EXACT command from RUNNING.md (lines 29-32), just adding the device ID
flutter run -d "$DEVICE_ID" \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY