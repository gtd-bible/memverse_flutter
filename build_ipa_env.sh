#!/bin/bash

# Usage:
#   export MEMVERSE_CLIENT_ID=your_id
#   export MEMVERSE_CLIENT_API_KEY=your_api_key
#   ./build_ipa_env.sh

flutter build ipa \
  --export-options-plist=ios/ExportOptions.plist \
  --dart-define=MEMVERSE_CLIENT_ID="$MEMVERSE_CLIENT_ID" \
  --dart-define=MEMVERSE_CLIENT_API_KEY="$MEMVERSE_CLIENT_API_KEY"
