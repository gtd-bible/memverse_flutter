#!/bin/bash

# Comprehensive API testing for Memverse sign-in
# Tests both successful and failed authentication scenarios

echo "🔬 Comprehensive Memverse API Testing"
echo "====================================="

# Check environment variables
if [ -z "$MEMVERSE_CLIENT_ID" ] || [ -z "$MEMVERSE_CLIENT_API_KEY" ] || [ -z "$MEMVERSE_USERNAME" ] || [ -z "$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" ] || [ -z "$MEMVERSE_INCORRECT_PASSWORD" ]; then
    echo "❌ Missing environment variables"
    echo "Required: MEMVERSE_CLIENT_ID, MEMVERSE_CLIENT_API_KEY, MEMVERSE_USERNAME, MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT, MEMVERSE_INCORRECT_PASSWORD"
    exit 1
fi

# Function to test OAuth
test_oauth() {
    local desc="$1"
    local username="$2"
    local password="$3"
    local expected_status="$4"

    echo ""
    echo "🧪 $desc"

    RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
      -X POST "https://www.memverse.com/oauth/token" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=password&username=$username&password=$password&client_id=$MEMVERSE_CLIENT_ID&client_secret=$MEMVERSE_CLIENT_API_KEY")

    HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS:" | cut -d: -f2)
    BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS:/d')

    if [ "$HTTP_STATUS" = "$expected_status" ]; then
        echo "✅ PASS - Status $HTTP_STATUS (expected $expected_status)"

        if [ "$HTTP_STATUS" = "200" ]; then
            ACCESS_TOKEN=$(echo "$BODY" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4 | cut -c1-20)
            echo "   Access Token: ${ACCESS_TOKEN}..."
        fi
    else
        echo "❌ FAIL - Got status $HTTP_STATUS, expected $expected_status"
        ERROR=$(echo "$BODY" | grep -o '"error_description":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "$BODY" | head -1)
        echo "   Error: ${ERROR:0:100}..."
    fi
}

# Test 1: Correct credentials should succeed
test_oauth "Correct Credentials" "$MEMVERSE_USERNAME" "$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" "200"

# Test 2: Wrong password should fail
test_oauth "Wrong Password" "$MEMVERSE_USERNAME" "$MEMVERSE_INCORRECT_PASSWORD" "401"

# Test 3: Wrong username should fail
test_oauth "Wrong Username" "nonexistent@example.com" "$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" "401"

# Test 4: Empty password should fail
test_oauth "Empty Password" "$MEMVERSE_USERNAME" "" "401"

echo ""
echo "🎯 API Testing Complete!"
echo ""
echo "If all tests passed, the API integration is working correctly."
echo "The Flutter app should be able to authenticate users properly."