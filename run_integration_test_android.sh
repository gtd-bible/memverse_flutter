#!/bin/bash

# Memverse Flutter - Integration Test Runner (Android)
# This script runs integration tests on Android emulator with required environment variables

# Set defaults if not provided
CLIENT_ID="${CLIENT_ID:-test_client_id}"
MEMVERSE_CLIENT_API_KEY="${MEMVERSE_CLIENT_API_KEY:-test_api_key}"

echo "🧪 Running Integration Tests on Android"
echo "========================================"
echo "Client ID: ${CLIENT_ID}"
echo "API Key: ${MEMVERSE_CLIENT_API_KEY:0:8}..."
echo "========================================"
echo ""

# Check if an Android emulator is running
ANDROID_DEVICES=$(flutter devices | grep -c "emulator")
if [ "$ANDROID_DEVICES" -eq 0 ]; then
    echo "⚠️  WARNING: No Android emulator detected!"
    echo "   Please start an Android emulator first."
    echo ""
    echo "   Available devices:"
    flutter devices
    exit 1
fi

echo "📱 Android emulator detected, running integration tests..."
echo ""

# Run integration tests with environment variables
flutter test integration_test/hello_world_test.dart \
  --dart-define=CLIENT_ID=$CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY \
  -d $(flutter devices | grep "emulator" | head -n 1 | awk '{print $5}' | tr -d '•') \
  "$@"

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Integration tests PASSED!"
else
    echo ""
    echo "❌ Integration tests FAILED!"
    exit 1
fi
