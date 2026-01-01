# Memverse Flutter App - Setup Guide

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd memverse_flutter
flutter pub get
```

### 2. Configure Environment Variables

**IMPORTANT:** Never commit API keys to the repository! Use environment variables.

#### For Local Development (Mac/Linux):

Add the following to your `~/.zshrc` (Mac) or `~/.bashrc` (Linux):

```bash
# Memverse App Configuration
export MEMVERSE_CLIENT_ID="your_actual_client_id"
export MEMVERSE_CLIENT_API_KEY="your_actual_api_key"
export POSTHOG_MEMVERSE_API_KEY="your_actual_posthog_key"
export ENVIRONMENT="dev"  # Options: dev, stg, prd
```

Then reload your shell:

```bash
source ~/.zshrc  # Mac
# or
source ~/.bashrc  # Linux
```

### 3. Run the App

#### Using the convenience script (recommended):
```bash
./run_dev.sh
```

#### Or manually with Flutter:
```bash
flutter run \
  --dart-define=CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY \
  --dart-define=POSTHOG_MEMVERSE_API_KEY=$POSTHOG_MEMVERSE_API_KEY \
  --dart-define=ENVIRONMENT=$ENVIRONMENT
```

## What Each Environment Variable Does

| Variable | Source | Purpose | Required |
|----------|--------|---------|----------|
| `CLIENT_ID` | `MEMVERSE_CLIENT_ID` | OAuth client identifier | ✅ Yes (auto-fallbacks to 'debug' in dev mode) |
| `MEMVERSE_CLIENT_API_KEY` | `MEMVERSE_CLIENT_API_KEY` | API authentication key | ✅ Yes (required, no fallback) |
| `POSTHOG_MEMVERSE_API_KEY` | `POSTHOG_MEMVERSE_API_KEY` | PostHog analytics key | ❌ Optional (Firebase works without it) |
| `ENVIRONMENT` | `ENVIRONMENT` | API environment | ❌ Optional (defaults to 'dev') |

### Note on CLIENT_ID
There are two dart-define values that point to the same environment variable:
- `--dart-define=CLIENT_ID=$MEMVERSE_CLIENT_ID`
- The code also checks for `CLIENT_API_KEY` in some places

**For your .zshrc, only set:**
```bash
export MEMVERSE_CLIENT_ID="your_value"     # Used by flutter run via CLIENT_ID
```

## Environment-Specific API URLs

| ENVIRONMENT Value | API URL |
|-------------------|---------|
| `dev` | https://api-dev.memverse.com |
| `stg` | https://api-stg.memverse.com |
| `prd` | https://api.memverse.com |

## How It Works

### Bootstrap Process

1. `main()` checks for required environment variables
2. If missing, it shows a friendly error screen with instructions
3. Firebase is initialized (always works, no env vars needed)
4. PostHog analytics is initialized (optional, skips if no API key)
5. App boots up with ProviderScope for state management

### Debug Mode Fallback

In debug mode (`flutter run` without `--release`):
- `CLIENT_ID` automatically defaults to `'debug'` if not provided
- You still need `MEMVERSE_CLIENT_API_KEY`

### Public Repository Safety

This app is designed for public repositories:
- No API keys in code
- No `.env` files committed
- All sensitive data comes from environment variables
- Works with `.zshrc` exports locally
- Works with GitHub Secrets in CI/CD

## IDE Setup

### VSCode

The `.vscode/launch.json` configuration is already set up. Just select:
- "Flutter (Dev)" - Development
- "Flutter (Staging)" - Staging
- "Flutter (Production)" - Production

Make sure your environment variables are exported in your shell before launching.

### IntelliJ/Android Studio

1. Run → Edit Configurations
2. Add new Flutter configuration
3. Set "Additional arguments":

```
--dart-define=CLIENT_ID=$MEMVERSE_CLIENT_ID --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY --dart-define=POSTHOG_MEMVERSE_API_KEY=$POSTHOG_MEMVERSE_API_KEY --dart-define=ENVIRONMENT=dev
```

## CI/CD (GitHub Actions)

Add these secrets to your GitHub repository settings:
- `MEMVERSE_CLIENT_ID`
- `MEMVERSE_CLIENT_API_KEY`
- `POSTHOG_MEMVERSE_API_KEY`
- `ENVIRONMENT` (optional, defaults to dev)

Example workflow step:

```yaml
- name: Build APK
  run: |
    flutter build apk \
      --dart-define=CLIENT_ID=${{ secrets.MEMVERSE_CLIENT_ID }} \
      --dart-define=MEMVERSE_CLIENT_API_KEY=${{ secrets.MEMVERSE_CLIENT_API_KEY }} \
      --dart-define=POSTHOG_MEMVERSE_API_KEY=${{ secrets.POSTHOG_MEMVERSE_API_KEY }} \
      --dart-define=ENVIRONMENT=${{ secrets.ENVIRONMENT }}
```

## Common Issues

### Issue: "Missing required MEMVERSE_CLIENT_API_KEY"
**Solution:** Export the environment variable and reload your shell:
```bash
export MEMVERSE_CLIENT_API_KEY="your_key"
source ~/.zshrc
```

### Issue: "CLIENT_ID not defined"
**Solution:** Either export it or it will auto-use 'debug' in development mode:
```bash
export MEMVERSE_CLIENT_ID="your_client_id"
```

### Issue: PostHog logs "API key not provided"
**Solution:** This is normal if you haven't set `POSTHOG_MEMVERSE_API_KEY`. Firebase will still work.

## Testing Build Without Actual Keys

You can test the configuration screen by running:
```bash
flutter run --dart-define=CLIENT_ID=test
```

This will show the error screen since `MEMVERSE_CLIENT_API_KEY` is missing.

## Architecture

- **main.dart**: Entry point, validates env vars, initializes Firebase & PostHog
- **bootstrap.dart**: Sets up ProviderContainer and error handling
- **services/app_logger.dart**: Consolidated logging with kDebugMode checks
- **services/analytics_manager.dart**: Firebase Analytics & Crashlytics
- **common/services/analytics_bootstrap.dart**: PostHog initialization
- **common/services/analytics_service.dart**: Unified analytics interface

## Further Reading

- `RUNNING.md` - Detailed running instructions
- `.env.example` - Example environment variable comments (do not add values!)
- `.vscode/launch.json` - VSCode run configurations