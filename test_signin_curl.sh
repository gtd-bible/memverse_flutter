#!/bin/bash

# Test Memverse OAuth sign-in with curl
# Usage: ./test_signin_curl.sh

echo "🔧 Testing Memverse OAuth API with curl..."

# Check environment variables
if [ -z "$MEMVERSE_CLIENT_ID" ] || [ -z "$MEMVERSE_CLIENT_API_KEY" ] || [ -z "$MEMVERSE_USERNAME" ] || [ -z "$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT" ]; then
    echo "❌ Missing environment variables"
    echo "Required: MEMVERSE_CLIENT_ID, MEMVERSE_CLIENT_API_KEY, MEMVERSE_USERNAME, MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT"
    exit 1
fi

echo "📤 Sending OAuth request..."

# Make the curl request
RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -X POST "https://www.memverse.com/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=$MEMVERSE_USERNAME&password=$MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT&client_id=$MEMVERSE_CLIENT_ID&client_secret=$MEMVERSE_CLIENT_API_KEY")

# Extract status and body
HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS:/d')

echo "📥 Response status: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Sign-in successful!"
    # Extract and display key info (safely)
    ACCESS_TOKEN=$(echo "$BODY" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4 | cut -c1-20)
    TOKEN_TYPE=$(echo "$BODY" | grep -o '"token_type":"[^"]*"' | cut -d'"' -f4)
    USER_ID=$(echo "$BODY" | grep -o '"user_id":[0-9]*' | cut -d: -f2)

    echo "Access Token: ${ACCESS_TOKEN}..."
    echo "Token Type: $TOKEN_TYPE"
    echo "User ID: $USER_ID"
else
    echo "❌ Sign-in failed"
    ERROR_DESC=$(echo "$BODY" | grep -o '"error_description":"[^"]*"' | cut -d'"' -f4)
    ERROR=$(echo "$BODY" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
    echo "Error: ${ERROR_DESC:-$ERROR}"
fi