#!/bin/bash

# run_auth_test.sh - Comprehensive auth API test runner
# This script runs the auth test using app code, repository layer, and Riverpod

# Color output setup
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    Memverse Auth API Test Runner${NC}"
echo -e "${BLUE}================================================${NC}"

# Check for environment variables
if [[ -z "$MEMVERSE_CLIENT_ID" || -z "$MEMVERSE_CLIENT_API_KEY" || 
      -z "$MEMVERSE_USERNAME" || -z "$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" ]]; then
    echo -e "${RED}❌ Missing required environment variables!${NC}"
    echo -e "${YELLOW}Please set the following variables:${NC}"
    echo "export MEMVERSE_CLIENT_ID=\"your_client_id\""
    echo "export MEMVERSE_CLIENT_API_KEY=\"your_client_api_key\""
    echo "export MEMVERSE_USERNAME=\"your_username\""
    echo "export MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT=\"your_password\""
    exit 1
fi

# Optional: Print out masked credentials
echo -e "${YELLOW}Running with:${NC}"
# Only show first 4 chars and replace rest with asterisks
echo -e "Client ID: ${MEMVERSE_CLIENT_ID:0:4}****"
echo -e "Username: $MEMVERSE_USERNAME"
echo ""

# Ensure dependencies are up to date
echo -e "${BLUE}Ensuring dependencies...${NC}"
flutter pub get

# Run the test with Dart directly (works outside of Flutter)
echo -e "${BLUE}Running auth test with Riverpod and Repository layer...${NC}"
dart run test_auth_with_riverpod.dart | tee auth_test_output.log

# Check result
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Auth test completed successfully!${NC}"
    
    # Extract key metrics from the log
    echo -e "\n${BLUE}Summary:${NC}"
    echo -e "${YELLOW}API Authentication:${NC} $(grep -A1 "Direct API auth" auth_test_output.log | grep -o "succeeded\|failed")"
    echo -e "${YELLOW}Service Layer:${NC} $(grep -A1 "AuthService login" auth_test_output.log | grep -o "succeeded\|failed")"
    echo -e "${YELLOW}Riverpod Auth:${NC} $(grep -A1 "Riverpod auth" auth_test_output.log | grep -o "succeeded\|failed")"
    echo -e "${YELLOW}Verses Fetch:${NC} $(grep -A1 "Verses fetch" auth_test_output.log | grep -o "successful\|failed")"
    
    # Extract sample verse if available
    VERSE_REF=$(grep "  Reference:" auth_test_output.log | head -1 | sed 's/.*Reference: //')
    if [[ ! -z "$VERSE_REF" ]]; then
        echo -e "${YELLOW}Sample Verse:${NC} $VERSE_REF"
    fi
    
    exit 0
else
    echo -e "${RED}❌ Auth test failed!${NC}"
    echo -e "Check auth_test_output.log for details"
    exit 1
fi