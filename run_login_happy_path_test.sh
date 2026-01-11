#!/bin/bash

# Get the available Android emulator
DEVICE_ID=$(flutter devices | grep -o "emulator-[0-9]*" | head -n 1)

if [ -z "$DEVICE_ID" ]; then
  echo "❌ No Android emulator found. Please start one before running this test."
  exit 1
fi

echo "📱 Using device: $DEVICE_ID"
echo "📝 Running login happy path integration test..."

# Run the integration test with environment variables
flutter test integration_test/login_happy_path_test.dart \
  -d "$DEVICE_ID" \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY \
  --dart-define=MEMVERSE_USERNAME=$MEMVERSE_USERNAME \
  --dart-define=MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT=$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT