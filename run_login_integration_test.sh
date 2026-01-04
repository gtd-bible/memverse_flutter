#!/bin/bash

# Memverse Flutter - Login Integration Tests
# Tests both happy path (successful login) and unhappy path (failed login)
# Uses environment variables from your .zshrc

# Get the available emulators/simulators
DEVICES=$(flutter devices)

# Only use Android emulator
if echo "$DEVICES" | grep -q "emulator-"; then
  DEVICE_ID=$(echo "$DEVICES" | grep "emulator-" | head -1 | sed 's/.*\(emulator-[0-9]*\).*/\1/')
else
  echo "❌ No Android emulator found. Please start one before running this script."
  echo "Available devices:"
  echo "$DEVICES"
  echo ""
  echo "Please start an Android emulator with:"
  echo "  flutter emulators --launch <emulator-id>"
  exit 1
fi

# Set environment variables - use values from .zshrc or defaults
MEMVERSE_CLIENT_ID="${MEMVERSE_CLIENT_ID:-debug}"
MEMVERSE_CLIENT_API_KEY="${MEMVERSE_CLIENT_API_KEY:-}"
MEMVERSE_USERNAME="${MEMVERSE_USERNAME:-}"
MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT="${MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT:-}"

# Check if required variables are available
if [ -z "$MEMVERSE_USERNAME" ] || [ -z "$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" ]; then
  echo "⚠️ WARNING: Test credentials not found in environment variables"
  echo "To test with real credentials, add these to your .zshrc:"
  echo "  export MEMVERSE_USERNAME=\"your_username\""
  echo "  export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT=\"your_password\""
  echo ""
  echo "Proceeding with tests, but they may not pass without valid credentials."
  echo ""
fi

echo "=============================================================="
echo "🧪 RUNNING LOGIN INTEGRATION TESTS"
echo "=============================================================="
echo "Using device: $DEVICE_ID"
echo ""
echo "Application Environment Variables:"
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
echo ""

echo "Test Credentials:"
if [ -n "$MEMVERSE_USERNAME" ]; then
  echo "✅ MEMVERSE_USERNAME: ${MEMVERSE_USERNAME:0:2}...${MEMVERSE_USERNAME: -2} (${#MEMVERSE_USERNAME} chars)"
else
  echo "❌ MEMVERSE_USERNAME not set!"
fi

if [ -n "$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" ]; then
  echo "✅ MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT: [REDACTED] (${#MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT} chars)"
else 
  echo "❌ MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT not set!"
fi

echo "=============================================================="
echo "Running tests with verbose output..."
echo "=============================================================="

# Run the integration test
flutter test integration_test/login_test.dart \
  -d "$DEVICE_ID" \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY \
  --dart-define=MEMVERSE_USERNAME=$MEMVERSE_USERNAME \
  --dart-define=MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT=$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT

# Store test result
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
  echo "=============================================================="
  echo "✅ ALL TESTS PASSED!"
  echo "=============================================================="
else
  echo "=============================================================="
  echo "❌ TESTS FAILED"
  echo "=============================================================="
  echo "Try running the app manually first to verify credentials work:"
  echo "./run_docs_exact.sh"
fi

exit $TEST_RESULT