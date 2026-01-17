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

# Print the exact command that will be run
echo "========================================================================"
echo "RUNNING EXACT COMMAND:"
echo "flutter run -d $DEVICE_ID --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY"
echo "========================================================================"
echo "Using environment variables from your .zshrc file:"
echo "- MEMVERSE_CLIENT_ID receives value from: MEMVERSE_CLIENT_ID"
echo "- MEMVERSE_CLIENT_API_KEY receives value from: MEMVERSE_CLIENT_API_KEY"
echo "========================================================================"

# Run the app with the EXACT command line arguments as specified
flutter run -d "$DEVICE_ID" \
  --dart-define=CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY