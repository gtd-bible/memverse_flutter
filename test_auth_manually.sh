#!/bin/bash

# test_auth_manually.sh - Manual testing script for auth feature
# This script provides commands for testing auth feature components

# Color output setup
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if an environment variable exists
check_env() {
  if [ -z "${!1}" ]; then
    echo -e "${RED}Required environment variable $1 is not set${NC}"
    echo "Please set it with: export $1=your_value"
    return 1
  else
    echo -e "${GREEN}✓ $1 is set${NC}"
    return 0
  fi
}

# Print header
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    Memverse Auth Feature Manual Testing${NC}"
echo -e "${BLUE}================================================${NC}"

# Check essential environment variables
echo -e "\n${YELLOW}Checking environment variables...${NC}"

check_env MEMVERSE_CLIENT_ID || MISSING_VARS=true
check_env MEMVERSE_CLIENT_API_KEY || MISSING_VARS=true
check_env MEMVERSE_USERNAME || MISSING_VARS=true
check_env MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT || MISSING_VARS=true

if [ "$MISSING_VARS" = true ]; then
  echo -e "\n${RED}Some required environment variables are missing.${NC}"
  echo -e "Set them all at once with:"
  echo -e "${YELLOW}export MEMVERSE_CLIENT_ID=your_client_id${NC}"
  echo -e "${YELLOW}export MEMVERSE_CLIENT_API_KEY=your_api_key${NC}"
  echo -e "${YELLOW}export MEMVERSE_USERNAME=your_username${NC}"
  echo -e "${YELLOW}export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT=your_password${NC}"
  exit 1
fi

echo -e "\n${GREEN}All required environment variables are set!${NC}"

# Display menu for testing options
echo -e "\n${YELLOW}Select a testing option:${NC}"
echo -e " ${GREEN}1)${NC} Run Dart-only API/Service layer test"
echo -e " ${GREEN}2)${NC} Run Dart-only Riverpod state management test"
echo -e " ${GREEN}3)${NC} Run Flutter app with API env vars injected"
echo -e " ${GREEN}4)${NC} Run unit tests for auth feature"
echo -e " ${GREEN}5)${NC} Run all auth tests"
echo -e " ${GREEN}q)${NC} Quit"

read -p "Enter your choice: " choice

case "$choice" in
  1)
    echo -e "\n${BLUE}Running API/Service layer test...${NC}"
    dart run test_auth_api_with_app_code.dart
    ;;
  2)
    echo -e "\n${BLUE}Running Riverpod state management test...${NC}"
    dart run test_auth_with_riverpod.dart
    ;;
  3)
    echo -e "\n${BLUE}Running Flutter app with API env vars...${NC}"
    flutter run \
      --dart-define=MEMVERSE_CLIENT_ID="$MEMVERSE_CLIENT_ID" \
      --dart-define=MEMVERSE_CLIENT_API_KEY="$MEMVERSE_CLIENT_API_KEY" \
      --dart-define=TESTER_TYPE="manual_testing" \
      --dart-define=AUTOSIGNIN=false
    ;;
  4)
    echo -e "\n${BLUE}Running unit tests for auth feature...${NC}"
    flutter test test/features/auth/
    ;;
  5)
    echo -e "\n${BLUE}Running all auth tests...${NC}"
    flutter test test/features/auth/
    echo -e "\n${BLUE}Running auth integration tests...${NC}"
    flutter test integration_test/auth_analytics_integration_test.dart
    ;;
  q|Q)
    echo -e "\n${GREEN}Exiting.${NC}"
    exit 0
    ;;
  *)
    echo -e "\n${RED}Invalid option.${NC}"
    exit 1
    ;;
esac

echo -e "\n${BLUE}Manual testing complete!${NC}"