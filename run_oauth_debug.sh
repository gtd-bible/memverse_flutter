#!/bin/bash

# ============================================
# Memverse OAuth Debug Test
# ============================================
# This script runs a detailed OAuth debugging test
# to ensure the app's authentication works exactly
# like the successful curl command
# ============================================

# Verify environment variables exist
if [ -z "$MEMVERSE_CLIENT_ID" ] || [ -z "$MEMVERSE_CLIENT_API_KEY" ]; then
  echo "❌ ERROR: MEMVERSE_CLIENT_ID and/or MEMVERSE_CLIENT_API_KEY environment variables are missing!"
  echo "Please set them in your .zshrc or export them before running this script."
  echo "Example:"
  echo "  export MEMVERSE_CLIENT_ID=\"your_client_id\""
  echo "  export MEMVERSE_CLIENT_API_KEY=\"your_client_api_key\""
  exit 1
fi

echo "✅ Found MEMVERSE_CLIENT_ID and MEMVERSE_CLIENT_API_KEY environment variables"

# Find available device
echo "🔍 Looking for available devices..."
DEVICES=$(flutter devices)
DEVICE_ID=""

# Try Android emulator first
if echo "$DEVICES" | grep -q "emulator"; then
  DEVICE_ID=$(echo "$DEVICES" | grep "emulator" | head -1 | sed 's/.*emulator-\([^ ]*\).*/emulator-\1/')
  echo "✅ Found Android emulator: $DEVICE_ID"
# Or try iPhone simulator
elif echo "$DEVICES" | grep -q "iPhone"; then
  DEVICE_ID=$(echo "$DEVICES" | grep "iPhone" | head -1 | sed 's/.*iPhone \([^ ]*\).*/iPhone \1/')
  echo "✅ Found iPhone simulator: $DEVICE_ID"
else
  echo "❌ No emulator or simulator found. Please start one before running this script."
  echo "Available devices:"
  echo "$DEVICES"
  exit 1
fi

# Print test plan
echo ""
echo "===================================================="
echo "🧪 OAUTH DEBUG TEST PLAN"
echo "===================================================="
echo "1. Breakpoint set in auth_service.dart (line 104)"
echo "2. Breakpoint set in curl_logging_interceptor.dart (line 9)"
echo "3. Enhanced logging to compare with successful curl"
echo "4. Will run app with verbose logging"
echo "5. Target device: $DEVICE_ID"
echo "===================================================="
echo ""

# Run app with debugging
echo "🚀 Running app with debugging enabled..."
echo ""

flutter run \
  -d "$DEVICE_ID" \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY \
  --verbose