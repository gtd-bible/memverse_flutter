#!/bin/bash

# Memverse Flutter - Auth Integration Test Runner
# This script runs auth-specific integration tests on Android emulator

# Set up colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}🔐 Memverse Flutter - Auth Integration Tests${NC}"
echo -e "${BLUE}==================================================${NC}"

# Check if the test file exists
if [ ! -f "integration_test/auth_test.dart" ]; then
  echo -e "${RED}❌ ERROR: integration_test/auth_test.dart not found!${NC}"
  exit 1
fi

# Find available Android emulators
echo -e "${BLUE}Looking for available Android devices...${NC}"
DEVICES=$(flutter devices | grep -i android | grep -v offline)
DEVICE_ID=$(echo "$DEVICES" | grep -o 'emulator-[0-9]*' | head -n 1)

if [ -z "$DEVICE_ID" ]; then
  echo -e "${RED}❌ ERROR: No Android emulator found!${NC}"
  echo -e "${YELLOW}Please start an Android emulator before running this test.${NC}"
  exit 1
fi

# Extract emulator name for logging
DEVICE_NAME=$(echo "$DEVICES" | grep -i android | head -n 1 | sed 's/•//g')
echo -e "${GREEN}✓ Found device: ${DEVICE_NAME}${NC}"

echo -e "${YELLOW}Checking environment variables...${NC}"
# Check for environment variables (don't print actual values for security)
if [ -z "$MEMVERSE_USERNAME" ]; then
  echo -e "${RED}⚠️ MEMVERSE_USERNAME not set!${NC}"
  echo -e "${YELLOW}Tests may fail without proper credentials.${NC}"
  echo -e "Please add to your shell profile: export MEMVERSE_USERNAME=\"your_username\""
else
  echo -e "${GREEN}✓ MEMVERSE_USERNAME is set${NC}"
fi

if [ -z "$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" ]; then
  echo -e "${RED}⚠️ MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT not set!${NC}"
  echo -e "${YELLOW}Tests may fail without proper credentials.${NC}"
  echo -e "Please add to your shell profile: export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT=\"your_password\""
else
  echo -e "${GREEN}✓ MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT is set${NC}"
fi

echo -e "${BLUE}Running auth integration tests...${NC}"
echo -e "${YELLOW}This may take several minutes. Do not interact with the emulator.${NC}"

# Run the integration test with the environment variables
flutter test \
  --dart-define=MEMVERSE_CLIENT_ID=test_client \
  --dart-define=MEMVERSE_CLIENT_API_KEY=test_key \
  --dart-define=MEMVERSE_USERNAME=$MEMVERSE_USERNAME \
  --dart-define=MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT=$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT \
  integration_test/auth_test.dart \
  -d $DEVICE_ID

TEST_EXIT_CODE=$?

echo -e "${BLUE}==================================================${NC}"
if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}✅ Auth integration tests PASSED!${NC}"
else
  echo -e "${RED}❌ Auth integration tests FAILED with exit code $TEST_EXIT_CODE${NC}"
fi
echo -e "${BLUE}==================================================${NC}"

exit $TEST_EXIT_CODE