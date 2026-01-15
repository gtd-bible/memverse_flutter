#!/bin/bash

# This script ensures SwiftSupport is properly included in the IPA
# Run this after creating an archive but before exporting the IPA

# Use provided archive path or find latest
if [ -n "$1" ]; then
  ARCHIVE_PATH="$1"
  echo "📦 Using provided archive: $ARCHIVE_PATH"
else
  ARCHIVE_DIR="$HOME/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)"
  ARCHIVE_PATH=$(ls -t "$ARCHIVE_DIR"/*.xcarchive | head -1)
  
  if [ -z "$ARCHIVE_PATH" ]; then
    echo "❌ No recent archives found at $ARCHIVE_DIR"
    exit 1
  fi
  
  echo "📦 Using latest archive: $ARCHIVE_PATH"
fi

# Create SwiftSupport directory if it doesn't exist
SWIFT_SUPPORT_PATH="$ARCHIVE_PATH/SwiftSupport"
if [ ! -d "$SWIFT_SUPPORT_PATH" ]; then
  mkdir -p "$SWIFT_SUPPORT_PATH"
  echo "📁 Created SwiftSupport directory"
fi

# Copy Swift dylibs from the app's Frameworks to SwiftSupport
APP_FRAMEWORKS_PATH="$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks"
if [ -d "$APP_FRAMEWORKS_PATH" ]; then
  echo "🔍 Finding Swift frameworks..."
  SWIFT_FRAMEWORKS=$(find "$APP_FRAMEWORKS_PATH" -name "libswift*.dylib")
  
  if [ -z "$SWIFT_FRAMEWORKS" ]; then
    echo "⚠️ No Swift frameworks found in $APP_FRAMEWORKS_PATH"
  else
    echo "✅ Copying Swift frameworks to SwiftSupport..."
    for framework in $SWIFT_FRAMEWORKS; do
      cp "$framework" "$SWIFT_SUPPORT_PATH/"
      echo "   - $(basename "$framework")"
    done
  fi
else
  echo "❌ Frameworks directory not found at $APP_FRAMEWORKS_PATH"
  exit 1
fi

echo "✅ Swift support preparation complete!"
exit 0