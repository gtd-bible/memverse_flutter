#!/bin/bash

# Memverse Flutter - Development Run Script
# This script reads environment variables from .zshrc or exports

# Required environment variables:
# - CLIENT_ID (in your .zshrc as MEMVERSE_CLIENT_ID)
# - MEMVERSE_CLIENT_API_KEY (in your .zshrc as MEMVERSE_CLIENT_API_KEY)

# Set defaults if not provided
CLIENT_ID="${CLIENT_ID:-debug}"
MEMVERSE_CLIENT_API_KEY="${MEMVERSE_CLIENT_API_KEY:-}"

echo "🚀 Starting Memverse Flutter App (Firebase Analytics only)"
echo "================================"
echo "Client ID: ${CLIENT_ID:0:8}..."
echo "API Key: ${MEMVERSE_CLIENT_API_KEY:0:8}..."
echo "================================"
echo ""

if [ -z "$MEMVERSE_CLIENT_API_KEY" ]; then
    echo "⚠️  WARNING: MEMVERSE_CLIENT_API_KEY is not set!"
    echo "   Ensure you have exported these in your .zshrc:"
    echo "   export CLIENT_ID=\"your_client_id\""
    echo "   export MEMVERSE_CLIENT_API_KEY=\"your_api_key\""
    echo ""
fi

# Run Flutter with environment variables
flutter run \
  --dart-define=CLIENT_ID=$CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY \
  "$@"