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

# Print the variables being used
echo "========================================="
echo "CLIENT_ID: Using $MEMVERSE_CLIENT_ID from environment"
echo "MEMVERSE_CLIENT_API_KEY: Using secret from environment"
echo "Running on device: $DEVICE_ID"
echo "========================================="

# Run the app with environment variables
flutter run -d "$DEVICE_ID" \
  --dart-define=CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY