#!/bin/bash

# Validate required environment variables
if [ -z "$DEVICE_ID" ]; then
  # Get device ID using JSON output from flutter devices
  DEVICE_ID=$(flutter devices --machine | jq -r '
    .[] | 
    select(.platform == "android-arm64" or .platform == "android-arm" or .platform == "ios") |
    select(.emulator == true or .platform == "ios") |
    .id' | head -1)

  if [ -z "$DEVICE_ID" ]; then
    echo "No emulator or simulator found. Please start one before running this script."
    echo "Available devices:"
    flutter devices
    exit 1
  fi
fi

if [ -z "$MEMVERSE_CLIENT_ID" ]; then
  echo "ERROR: MEMVERSE_CLIENT_ID environment variable is not set"
  exit 1
fi

if [ -z "$MEMVERSE_CLIENT_API_KEY" ]; then
  echo "ERROR: MEMVERSE_CLIENT_API_KEY environment variable is not set"
  exit 1
fi

# Run the app with environment variables
echo "Running on device: $DEVICE_ID"
echo "Using MEMVERSE_CLIENT_ID and MEMVERSE_CLIENT_API_KEY from environment"

flutter run \
  -d "$DEVICE_ID" \
  --dart-define=MEMVERSE_CLIENT_ID="$MEMVERSE_CLIENT_ID" \
  --dart-define=MEMVERSE_CLIENT_API_KEY="$MEMVERSE_CLIENT_API_KEY" \
  --verbose