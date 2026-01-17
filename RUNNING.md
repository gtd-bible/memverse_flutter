# Running Memverse Flutter App

## Local Development Setup

### 1. Set Environment Variables in `.zshrc`

Add these exports to your `~/.zshrc` (Mac) or `~/.bashrc` (Linux):

```bash
# Memverse App Configuration
export MEMVERSE_CLIENT_ID="your_client_id_here"
export MEMVERSE_CLIENT_API_KEY="your_api_key_here"
```

**Then reload your shell:**
```bash
source ~/.zshrc
```

### 2. Run the App

#### Option A: Using the convenience script (recommended)
```bash
./run_dev.sh
```

This script will automatically read your environment variables from `.zshrc`.

#### Option B: Manual flutter run
```bash
flutter run \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY
```

### 3. Building for Different Platforms

#### Android (APK)
```bash
flutter build apk \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY
```

#### iOS (IPA)
```bash
flutter build ios \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY
```

#### Web
```bash
flutter build web \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY
```



## CI/CD Setup (GitHub Actions)

Add these secrets in your GitHub repository settings:
- `MEMVERSE_CLIENT_ID`
- `MEMVERSE_CLIENT_API_KEY`

Example workflow usage:
```yaml
- name: Build APK
  run: |
    flutter build apk \
      --dart-define=MEMVERSE_CLIENT_ID=${{ secrets.MEMVERSE_CLIENT_ID }} \
      --dart-define=MEMVERSE_CLIENT_API_KEY=${{ secrets.MEMVERSE_CLIENT_API_KEY }}
```

## IDE Configuration

### VSCode
The `.vscode/launch.json` file is already configured. Just choose:
- "Flutter (Dev)" for development
- "Flutter (Staging)" for staging
- "Flutter (Production)" for production

### IntelliJ/Android Studio
Create a new run configuration:
1. Run → Edit Configurations
2. Add new Flutter configuration
3. Set "Additional arguments" to:
```
--dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY
```

## Debug Mode Auto-Fallback

In debug mode (`kDebugMode`), the app will automatically use `MEMVERSE_CLIENT_ID='debug'` if not provided. However, `MEMVERSE_CLIENT_API_KEY` is still required and will show a configuration error if missing.



## Firebase

Firebase is always initialized and does not require environment variables. Configuration is handled via:
- `firebase_options.dart` (platform-specific settings)
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS/macOS)