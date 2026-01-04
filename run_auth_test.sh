#!/bin/bash

# Memverse Flutter - Auth Integration Test Runner
# This script runs auth-specific integration tests with real credentials on Android

# Ensure environment variables are set
if [ -z "$MEMVERSE_USERNAME" ] || [ -z "$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" ]; then
    echo "❌ ERROR: Required environment variables not set!"
    echo "   Please ensure these variables are set in your .zshrc:"
    echo "   - MEMVERSE_USERNAME"
    echo "   - MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT"
    exit 1
fi

# Set client ID and API key from environment
MEMVERSE_CLIENT_ID="${MEMVERSE_CLIENT_ID:-debug}"
MEMVERSE_CLIENT_API_KEY="${MEMVERSE_CLIENT_API_KEY:-}"

echo "🧪 Running Auth Integration Tests on Android"
echo "============================================"
echo "Username: $MEMVERSE_USERNAME"
echo "Password: [REDACTED]"
echo "Client ID: ${MEMVERSE_CLIENT_ID:0:3}...${MEMVERSE_CLIENT_ID: -3}"
echo "API Key: ${MEMVERSE_CLIENT_API_KEY:0:3}...${MEMVERSE_CLIENT_API_KEY: -3}"
echo "============================================"
echo ""

# Check if an Android emulator is running
ANDROID_DEVICE=$(flutter devices | grep -E "android|emulator" | head -1)
if [ -z "$ANDROID_DEVICE" ]; then
    echo "⚠️  WARNING: No Android emulator detected!"
    echo "   Please start an Android emulator first."
    echo ""
    echo "   Available devices:"
    flutter devices
    exit 1
fi

# Extract device ID
DEVICE_ID=$(echo "$ANDROID_DEVICE" | awk '{print $2}')
echo "📱 Using Android device: $DEVICE_ID"
echo ""

# Run login integration test with environment variables
echo "▶️ Running login test"
flutter test integration_test/auth_test.dart \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY \
  --dart-define=MEMVERSE_USERNAME="$MEMVERSE_USERNAME" \
  --dart-define=MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT="$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" \
  -d $DEVICE_ID

# Check exit code
TEST_RESULT=$?
if [ $TEST_RESULT -eq 0 ]; then
    echo ""
    echo "✅ Auth Integration tests PASSED!"
else
    echo ""
    echo "❌ Auth Integration tests FAILED with exit code: $TEST_RESULT"
    exit $TEST_RESULT
fi