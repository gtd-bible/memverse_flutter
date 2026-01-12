#!/bin/bash

# Simple script to run the app with proper environment variables
# This ensures the environment variables are properly passed to Flutter

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we have the required environment variables
if [[ -z "$MEMVERSE_CLIENT_ID" || -z "$MEMVERSE_CLIENT_API_KEY" ]]; then
    echo -e "${RED}Missing required environment variables!${NC}"
    echo -e "Please set the following variables in your shell:"
    echo -e "  ${YELLOW}export MEMVERSE_CLIENT_ID=\"your_client_id_here\"${NC}"
    echo -e "  ${YELLOW}export MEMVERSE_CLIENT_API_KEY=\"your_api_key_here\"${NC}"
    exit 1
fi

# Run the app with the environment variables passed as --dart-define
echo -e "${GREEN}Running app with environment variables...${NC}"
echo -e "MEMVERSE_CLIENT_ID: ${MEMVERSE_CLIENT_ID:0:4}...${MEMVERSE_CLIENT_ID: -4}"
echo -e "MEMVERSE_CLIENT_API_KEY: ${MEMVERSE_CLIENT_API_KEY:0:4}...${MEMVERSE_CLIENT_API_KEY: -4}"

# Check for test credentials
if [[ -n "$MEMVERSE_USERNAME" && -n "$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" ]]; then
    echo -e "${YELLOW}Debug credentials found - will auto-fill login form${NC}"
    echo -e "Username: $MEMVERSE_USERNAME"
    echo -e "Password: ${MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT:0:2}*****"
    
    # Run with test credentials
    flutter clean
    flutter pub get
    flutter run \
      --dart-define=MEMVERSE_CLIENT_ID="$MEMVERSE_CLIENT_ID" \
      --dart-define=MEMVERSE_CLIENT_API_KEY="$MEMVERSE_CLIENT_API_KEY" \
      --dart-define=TESTER_TYPE="manual_testing" \
      --dart-define=MEMVERSE_USERNAME="$MEMVERSE_USERNAME" \
      --dart-define=MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT="$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT"
else
    echo -e "${YELLOW}No test credentials found - login form will be empty${NC}"
    echo -e "If you want auto-filled credentials, set these variables:"
    echo -e "  export MEMVERSE_USERNAME=\"your_test_username\""
    echo -e "  export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT=\"your_test_password\""
    
    # Run without test credentials
    flutter clean
    flutter pub get
    flutter run \
      --dart-define=MEMVERSE_CLIENT_ID="$MEMVERSE_CLIENT_ID" \
      --dart-define=MEMVERSE_CLIENT_API_KEY="$MEMVERSE_CLIENT_API_KEY" \
      --dart-define=TESTER_TYPE="manual_testing"
fi