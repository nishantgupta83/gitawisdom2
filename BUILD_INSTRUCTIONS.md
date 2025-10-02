# GitaWisdom Build Instructions

## Security-First Build Configuration

All sensitive configuration (Supabase URLs, API keys) **must** be provided at build time via `--dart-define` flags or environment files.

## Prerequisites

1. Flutter SDK >=3.2.0
2. Supabase project credentials
3. Android/iOS development setup

## Environment Configuration

### Option 1: Using .env Files (Recommended for CI/CD)

1. Create environment file based on template:
   ```bash
   cp .env.example .env.production
   ```

2. Edit `.env.production` with your actual values:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_actual_anon_key_here
   APP_ENV=production
   ENABLE_ANALYTICS=true
   ENABLE_LOGGING=false
   ```

3. Build using the script:
   ```bash
   ./scripts/build_release.sh
   ```

### Option 2: Manual --dart-define Flags

Build directly with inline configuration:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_actual_anon_key \
  --dart-define=APP_ENV=production \
  --dart-define=ENABLE_ANALYTICS=true \
  --dart-define=ENABLE_LOGGING=false
```

## Android Build

### Debug Build
```bash
flutter build apk --debug \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### Release Build (Google Play Store)
```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=APP_ENV=production
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

## iOS Build

### Development Build
```bash
flutter build ios --debug \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### Release Build (App Store)
```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=APP_ENV=production
```

Then archive in Xcode:
```bash
open ios/Runner.xcworkspace
# Product > Archive
```

## Security Checklist

Before deploying to production:

- [ ] **Never** commit `.env` files (only `.env.example`)
- [ ] **Never** hardcode API keys in source code
- [ ] Verify `.gitignore` blocks all sensitive files
- [ ] Use environment-specific `.env.production` / `.env.staging` files
- [ ] Store secrets in CI/CD environment variables
- [ ] Test builds locally before deploying to stores
- [ ] Review `lib/config/environment.dart` - should have empty `defaultValue`

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Build Release
  env:
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
    SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
  run: |
    flutter build appbundle --release \
      --dart-define=SUPABASE_URL=$SUPABASE_URL \
      --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
      --dart-define=APP_ENV=production
```

## Troubleshooting

### "Missing required environment variables"

**Cause**: Build ran without providing `SUPABASE_URL` or `SUPABASE_ANON_KEY`

**Fix**: Ensure you pass `--dart-define` flags or use `.env` file with build script

### "defaultValue must not be empty"

**Cause**: Trying to run app without environment configuration

**Fix**: Always build with proper `--dart-define` flags, never rely on defaults

## Build Script Reference

- `scripts/build_release.sh` - Production builds with `.env.production`
- `scripts/build_dev.sh` - Development builds with `.env.development`
- `scripts/load_env.sh` - Helper to convert `.env` to `--dart-define` flags

## Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SUPABASE_URL` | ✅ Yes | - | Supabase project URL |
| `SUPABASE_ANON_KEY` | ✅ Yes | - | Supabase anonymous key |
| `APP_ENV` | No | `development` | Environment: development/staging/production |
| `ENABLE_ANALYTICS` | No | `false` | Enable analytics tracking |
| `ENABLE_LOGGING` | No | `true` | Enable debug logging |
| `API_TIMEOUT_SECONDS` | No | `30` | API request timeout |
| `AUDIO_BASE_URL` | No | `assets/audio/` | Audio assets path |

## Production Deployment Checklist

### Before Submitting to Stores:

1. **Security**
   - [ ] No hardcoded API keys in code
   - [ ] `.env` files not committed to git
   - [ ] Sensitive files in `.gitignore`
   - [ ] Build with production credentials

2. **Configuration**
   - [ ] `APP_ENV=production`
   - [ ] `ENABLE_LOGGING=false` (disable debug logs)
   - [ ] `ENABLE_ANALYTICS=true` (if using analytics)

3. **Build Verification**
   - [ ] Test app on physical device
   - [ ] Verify Supabase connection works
   - [ ] Check app bundle size (<150MB for Google Play)
   - [ ] No debug/development artifacts in build

4. **Store Compliance**
   - [ ] Updated version in `pubspec.yaml`
   - [ ] Proper iOS signing & provisioning
   - [ ] Android keystore configured securely
   - [ ] Privacy policy URL updated
   - [ ] Required permissions documented

## Support

For build issues, check:
- Flutter version: `flutter doctor`
- Environment config: `cat .env.production` (verify structure)
- Gitignore: `git status` (should show no `.env` files)
- Build logs: Review console output for missing variables
