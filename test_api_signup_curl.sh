#!/bin/bash

# Testing Memverse signup API with curl
# This test uses curl to analyze API responses for signup

# Check for required environment variables
if [ -z "$MEMVERSE_CLIENT_ID" ] || [ -z "$MEMVERSE_CLIENT_API_KEY" ] || [ -z "$MEMVERSE_TEST_PASSWORD" ]; then
    echo "❌ Missing environment variables"
    echo "Required: MEMVERSE_CLIENT_ID, MEMVERSE_CLIENT_API_KEY, MEMVERSE_TEST_PASSWORD"
    echo ""
    echo "🔧 Set them like:"
    echo "  export MEMVERSE_CLIENT_ID=\"your_client_id\""
    echo "  export MEMVERSE_CLIENT_API_KEY=\"your_api_key\""
    echo "  export MEMVERSE_TEST_PASSWORD=\"your_test_password\""
    exit 1
fi

# Set defaults for optional variables
TEST_EMAIL="${MEMVERSE_TEST_EMAIL:-neilwarner+unverified@gmail.com}"
TEST_FIRST_NAME="${MEMVERSE_TEST_FIRST_NAME:-Test}"
TEST_LAST_NAME="${MEMVERSE_TEST_LAST_NAME:-User}"

echo "🔧 [DEBUG] Testing Memverse API signup with curl..."
echo "[DEBUG] Client ID: ${MEMVERSE_CLIENT_ID:0:8}..."
echo "[DEBUG] Test Email: $TEST_EMAIL"

# Step 1: Get CSRF token from signup form
echo ""
echo "📝 [DEBUG] Step 1: Getting CSRF token from signup form"

SIGNUP_PAGE=$(curl -s -i "https://www.memverse.com/user/new")
SIGNUP_STATUS=$(echo "$SIGNUP_PAGE" | grep -i "HTTP/" | awk '{print $2}')

echo "[DEBUG] 📥 Signup page response status: $SIGNUP_STATUS"

# Extract CSRF token from the response (if present)
CSRF_TOKEN=$(echo "$SIGNUP_PAGE" | grep -o 'csrf-token" content="[^"]*' | sed 's/csrf-token" content="//')

if [ -n "$CSRF_TOKEN" ]; then
    echo "[DEBUG] 🔑 CSRF Token found: ${CSRF_TOKEN:0:10}..."
else
    echo "[DEBUG] ⚠️ No CSRF token found, may cause request to fail"
fi

# Extract form action URL
FORM_ACTION=$(echo "$SIGNUP_PAGE" | grep -o 'action="[^"]*"' | head -1 | sed 's/action="//;s/"$//')

if [ -n "$FORM_ACTION" ]; then
    if [[ "$FORM_ACTION" == /* ]]; then
        # Relative path, add domain
        SIGNUP_URL="https://www.memverse.com$FORM_ACTION"
    else
        # Absolute URL
        SIGNUP_URL="$FORM_ACTION"
    fi
    echo "[DEBUG] 🔎 Found signup form action: $SIGNUP_URL"
else
    # Default fallback
    SIGNUP_URL="https://www.memverse.com/users"
    echo "[DEBUG] ⚠️ Could not determine form action, using default: $SIGNUP_URL"
fi

# Step 2: Submit signup form
echo ""
echo "📝 [DEBUG] Step 2: Submitting signup form"

# Prepare headers and data
HEADERS=()
HEADERS+=("-H" "Content-Type: application/x-www-form-urlencoded")

if [ -n "$CSRF_TOKEN" ]; then
    HEADERS+=("-H" "X-CSRF-Token: $CSRF_TOKEN")
fi

# Prepare form data
FORM_DATA="user[email]=$TEST_EMAIL&user[password]=$MEMVERSE_TEST_PASSWORD&user[password_confirmation]=$MEMVERSE_TEST_PASSWORD&user[first_name]=$TEST_FIRST_NAME&user[last_name]=$TEST_LAST_NAME&client_id=$MEMVERSE_CLIENT_ID&client_secret=$MEMVERSE_CLIENT_API_KEY"

echo "[DEBUG] 📤 Sending signup request to $SIGNUP_URL"

# Execute the signup request with cookie storage
SIGNUP_RESPONSE=$(curl -s -i \
    "${HEADERS[@]}" \
    -d "$FORM_DATA" \
    -c /tmp/memverse_cookies.txt \
    -L \
    "$SIGNUP_URL")

SIGNUP_STATUS=$(echo "$SIGNUP_RESPONSE" | grep -i "HTTP/" | tail -1 | awk '{print $2}')
echo "[DEBUG] 📥 Signup response status: $SIGNUP_STATUS"

# Print first 500 characters of response body
RESPONSE_BODY=$(echo "$SIGNUP_RESPONSE" | sed '1,/^\r$/d')
echo "[DEBUG] 📄 Response preview: ${RESPONSE_BODY:0:500}..."

# Look for success/error indicators in the response
if echo "$RESPONSE_BODY" | grep -q -i "success\|successfully\|created\|welcome"; then
    echo "[DEBUG] ✅ Signup appears successful based on response content"
elif echo "$RESPONSE_BODY" | grep -q -i "error\|already exists\|taken\|invalid"; then
    echo "[DEBUG] ❌ Signup failed - account may already exist or there was an error"
fi

# Step 3: Try to authenticate with the new account
echo ""
echo "🔐 [DEBUG] Step 3: Attempting to authenticate with new account"

AUTH_RESPONSE=$(curl -s -i \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=password&username=$TEST_EMAIL&password=$MEMVERSE_TEST_PASSWORD&client_id=$MEMVERSE_CLIENT_ID&client_secret=$MEMVERSE_CLIENT_API_KEY" \
    "https://www.memverse.com/oauth/token")

AUTH_STATUS=$(echo "$AUTH_RESPONSE" | grep -i "HTTP/" | head -1 | awk '{print $2}')
echo "[DEBUG] 📥 Auth response status: $AUTH_STATUS"

# Extract and display response body
AUTH_BODY=$(echo "$AUTH_RESPONSE" | sed '1,/^\r$/d')
echo "[DEBUG] 📄 Auth response body: $AUTH_BODY"

# Check if authentication was successful
if [ "$AUTH_STATUS" = "200" ] && echo "$AUTH_BODY" | grep -q "access_token"; then
    ACCESS_TOKEN=$(echo "$AUTH_BODY" | grep -o '"access_token":"[^"]*"' | sed 's/"access_token":"//;s/"$//')
    TOKEN_TYPE=$(echo "$AUTH_BODY" | grep -o '"token_type":"[^"]*"' | sed 's/"token_type":"//;s/"$//')
    
    echo "[DEBUG] ✅ Authentication successful with new account!"
    echo "[DEBUG] Access Token: ${ACCESS_TOKEN:0:20}..."
    echo "[DEBUG] Token Type: $TOKEN_TYPE"
else
    echo "[DEBUG] ℹ️ Authentication failed, which might be expected if email verification is required"
    # Check for specific error messages
    if echo "$AUTH_BODY" | grep -q "unconfirmed"; then
        echo "[DEBUG] 📧 Email verification appears to be required"
    elif echo "$AUTH_BODY" | grep -q "invalid_grant"; then
        echo "[DEBUG] ⚠️ Invalid credentials (username or password incorrect)"
    elif [ -z "$AUTH_BODY" ]; then
        echo "[DEBUG] ⚠️ Empty response body, could be a server-side issue"
    fi
fi

echo ""
echo "🎯 [DEBUG] API testing complete!"