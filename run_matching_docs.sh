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

# Print information about the environment variables
echo "=========================================================="
echo "🚀 Starting Memverse Flutter App"
echo "=========================================================="
echo "Using environment variables from your .zshrc:"
if [ -n "$MEMVERSE_CLIENT_ID" ]; then
  echo "✅ MEMVERSE_CLIENT_ID: ${MEMVERSE_CLIENT_ID:0:3}...${MEMVERSE_CLIENT_ID: -3} (${#MEMVERSE_CLIENT_ID} chars)"
else
  echo "❌ MEMVERSE_CLIENT_ID not set!"
fi

if [ -n "$MEMVERSE_CLIENT_API_KEY" ]; then
  echo "✅ MEMVERSE_CLIENT_API_KEY: ${MEMVERSE_CLIENT_API_KEY:0:3}...${MEMVERSE_CLIENT_API_KEY: -3} (${#MEMVERSE_CLIENT_API_KEY} chars)"
else
  echo "❌ MEMVERSE_CLIENT_API_KEY not set!"
fi
echo "=========================================================="

if [ -z "$MEMVERSE_CLIENT_API_KEY" ]; then
    echo "⚠️  WARNING: MEMVERSE_CLIENT_API_KEY is not set!"
    echo "   Ensure you have exported these in your .zshrc:"
    echo "   export MEMVERSE_CLIENT_ID=\"your_client_id\""
    echo "   export MEMVERSE_CLIENT_API_KEY=\"your_api_key\""
    echo ""
fi

echo "📱 Target device: $DEVICE_ID"
echo "🧪 Running command that matches SETUP.md and RUNNING.md documentation:"
echo "flutter run -d \"$DEVICE_ID\" --dart-define=MEMVERSE_CLIENT_ID=\$MEMVERSE_CLIENT_ID --dart-define=MEMVERSE_CLIENT_API_KEY=\$MEMVERSE_CLIENT_API_KEY"
echo "=========================================================="

# Run Flutter with environment variables - EXACTLY matching the documentation
flutter run -d "$DEVICE_ID" \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY