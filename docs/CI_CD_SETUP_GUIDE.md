# CI/CD Setup Guide

## Overview

This repository includes two GitHub Actions workflows for automated testing and validation:

1. **`flutter_ci_template.yml`** - Reusable template for any Flutter project
2. **`production_readiness.yml`** - GitaWisdom-specific production pipeline

This guide explains how to set up, customize, and use these workflows in your projects.

---

## Table of Contents

- [Quick Start](#quick-start)
- [GitaWisdom Configuration](#gitawisdom-configuration)
- [Reusing the Template](#reusing-the-template)
- [GitHub Secrets Setup](#github-secrets-setup)
- [Workflow Features](#workflow-features)
- [Customization Guide](#customization-guide)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### For GitaWisdom Repository

1. **Add GitHub Secrets** (required for builds to work):
   ```
   Navigate to: https://github.com/nishantgupta83/gitawisdom2/settings/secrets/actions

   Add these secrets:
   - SUPABASE_URL: https://wlfwdtdtiedlcczfoslt.supabase.co
   - SUPABASE_ANON_KEY: <your-anon-key-from-.env.development>
   ```

2. **Trigger the Workflow**:
   - **Automatic**: Push to `main`, `oct17apple`, or `develop` branch
   - **Manual**: Go to Actions tab → Production Readiness Tests → Run workflow

3. **View Results**:
   - Check the Actions tab for detailed logs
   - PR comments will show summary results
   - Build artifacts available for 14 days

---

## GitaWisdom Configuration

### Current Setup

The `production_readiness.yml` workflow is configured for GitaWisdom:

```yaml
env:
  FLUTTER_VERSION: '3.24.0'
  MIN_COVERAGE_PERCENT: 60
  MAX_ANDROID_APK_SIZE: 120000000    # 120MB
  MAX_ANDROID_AAB_SIZE: 90000000     # 90MB
  MAX_IOS_APP_SIZE: 150000000        # 150MB
```

### What Gets Tested

| Job | Description | Runs On |
|-----|-------------|---------|
| **Setup** | Install dependencies, run build_runner | Ubuntu |
| **Static Analysis** | `flutter analyze` for code quality | Ubuntu |
| **Unit Tests** | Run all tests with coverage reporting | Ubuntu |
| **Integration Tests** | E2E tests for critical flows | Ubuntu |
| **Security Scan** | Check for hardcoded secrets, validate configs | Ubuntu |
| **Android Build** | Build APK and AAB with size validation | Ubuntu |
| **iOS Build** | Build iOS app (no code signing) | macOS |
| **Performance Analysis** | Analyze APK composition | Ubuntu |
| **Production Report** | Generate summary and PR comments | Ubuntu |

### Build Triggers

**Automatic:**
- Pushes to `main`, `oct17apple`, `develop`
- Pull requests to `main`, `oct17apple`

**Manual:**
```bash
# Via GitHub UI:
Actions → Production Readiness Tests → Run workflow

# Options:
- Run full test suite (default: true)
- Skip iOS build (default: false) - useful for faster testing
```

---

## Reusing the Template

### Step 1: Copy Template to Your Project

```bash
# In your Flutter project
mkdir -p .github/workflows
cp /path/to/GitaWisdom/.github/workflows/flutter_ci_template.yml .github/workflows/ci.yml
```

### Step 2: Customize Configuration

Edit the `env` section at the top of the file:

```yaml
env:
  # Update Flutter version to match your pubspec.yaml
  FLUTTER_VERSION: '3.24.0'

  # Set project type
  PROJECT_TYPE: 'mobile'  # Options: mobile | web | backend | fullstack

  # Enable/disable platform builds
  ENABLE_IOS_BUILD: 'true'
  ENABLE_ANDROID_BUILD: 'true'
  ENABLE_WEB_BUILD: 'false'

  # Testing configuration
  MIN_COVERAGE_PERCENT: 60
  ENABLE_INTEGRATION_TESTS: 'true'

  # Build size limits (adjust for your app)
  MAX_ANDROID_APK_SIZE: 100000000   # 100MB
  MAX_ANDROID_AAB_SIZE: 80000000    # 80MB
  MAX_IOS_APP_SIZE: 120000000       # 120MB
  MAX_WEB_BUILD_SIZE: 50000000      # 50MB
```

### Step 3: Add Required Secrets

See [GitHub Secrets Setup](#github-secrets-setup) below.

### Step 4: Commit and Push

```bash
git add .github/workflows/ci.yml
git commit -m "Add CI/CD workflow"
git push
```

---

## GitHub Secrets Setup

### Required Secrets (for Supabase projects)

Navigate to your repository's **Settings → Secrets and variables → Actions**:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `SUPABASE_URL` | Your Supabase project URL | `https://xxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase anonymous/public key | `eyJhbGci...` |

### Optional Secrets

| Secret Name | Use Case |
|-------------|----------|
| `SLACK_WEBHOOK_URL` | Post build notifications to Slack |
| `CODECOV_TOKEN` | Upload coverage to Codecov.io |
| `FIREBASE_TOKEN` | For Firebase projects |

### How Secrets Are Used

Secrets are injected as `--dart-define` flags during builds:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
  --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

Your Dart code accesses them via:

```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

---

## Workflow Features

### 1. Static Analysis

**What it does:**
- Runs `flutter analyze` to catch code quality issues
- Checks for linter violations
- Reports warnings and errors

**Customize:**
```yaml
- name: 🔍 Flutter Analyze
  run: |
    flutter analyze --no-fatal-infos --no-fatal-warnings
```

### 2. Unit Tests with Coverage

**What it does:**
- Runs all tests in `test/` directory
- Generates code coverage report
- Enforces minimum coverage threshold

**Customize coverage requirement:**
```yaml
env:
  MIN_COVERAGE_PERCENT: 60  # Change to 70, 80, etc.
```

**View coverage reports:**
- Download from Actions → Artifacts → `coverage-report`
- Open `coverage/html/index.html` in browser

### 3. Integration Tests

**What it does:**
- Runs tests in `integration_test/` directory
- Tests full user flows end-to-end

**Enable/disable:**
```yaml
env:
  ENABLE_INTEGRATION_TESTS: 'true'  # Set to 'false' to skip
```

### 4. Security Scanning

**What it checks:**
- Hardcoded passwords, API keys, secrets
- Accidentally committed `.env` files
- Keystore files in repository
- Supabase configuration security

**Example checks:**
```bash
# Detects patterns like:
password = "hardcoded123"        # ❌ Fails
apiKey = "sk_live_xxx"           # ❌ Fails

# Safe patterns:
password = String.fromEnvironment('PASSWORD')  # ✅ Pass
```

### 5. Platform Builds

**Android:**
- Builds debug APK (always)
- Builds release APK and AAB (if `run_full_suite == true`)
- Validates build sizes
- Checks AndroidManifest.xml

**iOS:**
- Builds release app (no code signing)
- Validates Info.plist configuration
- Checks app size

**Web:**
- Builds optimized web bundle
- Validates build size

### 6. Performance Analysis

**What it does:**
- Analyzes APK composition
- Shows native library sizes
- Lists largest files
- Helps identify bloat

### 7. Production Reports

**GitHub Actions Summary:**
- Displays comprehensive test results
- Shows build status for each platform
- Indicates production readiness

**PR Comments:**
- Automatic comment on pull requests
- Shows at-a-glance test status
- Helps reviewers understand build health

---

## Customization Guide

### Customize for Mobile-Only Project

```yaml
env:
  PROJECT_TYPE: 'mobile'
  ENABLE_IOS_BUILD: 'true'
  ENABLE_ANDROID_BUILD: 'true'
  ENABLE_WEB_BUILD: 'false'
```

### Customize for Web-Only Project

```yaml
env:
  PROJECT_TYPE: 'web'
  ENABLE_IOS_BUILD: 'false'
  ENABLE_ANDROID_BUILD: 'false'
  ENABLE_WEB_BUILD: 'true'
```

### Customize for Full-Stack Project

```yaml
env:
  PROJECT_TYPE: 'fullstack'
  ENABLE_IOS_BUILD: 'true'
  ENABLE_ANDROID_BUILD: 'true'
  ENABLE_WEB_BUILD: 'true'
```

### Add Custom Build Steps

Add custom steps to any job:

```yaml
- name: 🔧 Custom Build Step
  run: |
    echo "Running custom command..."
    ./scripts/my_custom_script.sh
```

### Modify Build Size Limits

Adjust for your app's expected size:

```yaml
env:
  # Small app (< 50MB APK)
  MAX_ANDROID_APK_SIZE: 60000000
  MAX_ANDROID_AAB_SIZE: 40000000

  # Large app with heavy assets
  MAX_ANDROID_APK_SIZE: 150000000
  MAX_ANDROID_AAB_SIZE: 120000000
```

### Skip Specific Platforms

Temporarily disable builds:

```yaml
# In workflow file:
ios-build:
  if: false  # Skip iOS builds temporarily

# Or via workflow_dispatch:
# GitHub Actions UI → Skip iOS build → ✓ true
```

### Add Notification Steps

Send build results to Slack:

```yaml
- name: 📢 Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Build completed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## Troubleshooting

### Build Fails: "SUPABASE_URL is not set"

**Problem:** Missing GitHub secrets

**Solution:**
1. Go to repo Settings → Secrets and variables → Actions
2. Add `SUPABASE_URL` and `SUPABASE_ANON_KEY`
3. Re-run the workflow

### Build Fails: "flutter: command not found"

**Problem:** Flutter not properly installed in runner

**Solution:** Verify Flutter version in workflow:
```yaml
- name: 🐦 Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'  # Match your pubspec.yaml
```

### iOS Build Fails on CocoaPods

**Problem:** Pod dependencies out of date

**Solution:** Add pod install step:
```yaml
- name: 🍎 Install CocoaPods
  run: |
    cd ios
    pod install --repo-update
    cd ..
```

### Security Scan False Positives

**Problem:** Scan detects commented-out code as secrets

**Solution:** Ensure sensitive code has `//` or `/* */` comments:
```dart
// const apiKey = "test123";  // ✅ Ignored by scanner
const apiKey = "test123";      // ❌ Detected as secret
```

### APK Size Exceeds Limit

**Problem:** Build fails due to size validation

**Solution 1:** Increase limit:
```yaml
env:
  MAX_ANDROID_APK_SIZE: 150000000  # Increase from 120MB
```

**Solution 2:** Reduce app size:
- Use ProGuard/R8 shrinking
- Optimize images
- Remove unused dependencies
- Enable code splitting

### No Test Coverage Generated

**Problem:** Coverage report missing

**Solution:** Ensure test directory exists:
```bash
mkdir -p test
# Add basic test file
echo 'import "package:flutter_test/flutter_test.dart";

void main() {
  test("Example test", () {
    expect(1 + 1, 2);
  });
}' > test/example_test.dart
```

### Workflow Doesn't Trigger

**Problem:** Workflow not running on push

**Solution:** Check trigger configuration:
```yaml
on:
  push:
    branches: [main, develop]  # Add your branch here
  pull_request:
    branches: [main]
```

---

## Best Practices

### 1. Run CI on Every PR

Always enable PR checks:
```yaml
on:
  pull_request:
    branches: [main]
```

### 2. Use Branch Protection Rules

Require CI to pass before merging:
- Repo Settings → Branches → Add rule
- Branch name: `main`
- ✓ Require status checks to pass
- Select: `Static Analysis`, `Unit Tests`, `Security Scan`

### 3. Keep Workflows Fast

- Skip iOS builds during development (use `skip_ios` option)
- Only upload artifacts on `main` branch
- Use caching for Flutter SDK and dependencies

### 4. Monitor Build Times

Track job durations:
- Actions tab → Workflow runs → View timing
- Optimize slow steps
- Consider parallel jobs

### 5. Secure Secrets Management

- Never commit `.env` files
- Use GitHub secrets for all credentials
- Rotate secrets regularly
- Use separate secrets for dev/prod

---

## Example: Adding CI to a New Project

**Scenario:** You're starting a new Flutter mobile app.

**Steps:**

1. **Copy template:**
   ```bash
   mkdir -p .github/workflows
   cp flutter_ci_template.yml .github/workflows/ci.yml
   ```

2. **Customize for mobile:**
   ```yaml
   env:
     FLUTTER_VERSION: '3.24.0'
     PROJECT_TYPE: 'mobile'
     ENABLE_IOS_BUILD: 'true'
     ENABLE_ANDROID_BUILD: 'true'
     ENABLE_WEB_BUILD: 'false'
     MIN_COVERAGE_PERCENT: 70
   ```

3. **Add secrets** (if using Supabase):
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

4. **Commit and test:**
   ```bash
   git add .github/workflows/ci.yml
   git commit -m "Add CI/CD workflow"
   git push origin main
   ```

5. **Verify in Actions tab:**
   - All jobs should run
   - Check for any failures
   - Review coverage report

---

## Advanced Configuration

### Matrix Testing (Multiple Flutter Versions)

Test across multiple Flutter versions:

```yaml
strategy:
  matrix:
    flutter-version: ['3.22.0', '3.24.0']

steps:
  - uses: subosito/flutter-action@v2
    with:
      flutter-version: ${{ matrix.flutter-version }}
```

### Conditional Jobs

Run jobs based on file changes:

```yaml
jobs:
  android-build:
    if: contains(github.event.head_commit.modified, 'android/')
```

### Parallel Testing

Run tests in parallel for faster execution:

```yaml
strategy:
  matrix:
    test-group: [unit, integration, widget]

steps:
  - name: Run tests
    run: flutter test test/${{ matrix.test-group }}
```

---

## Support

### Resources

- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **Flutter CI/CD Guide**: https://docs.flutter.dev/deployment/cd
- **Workflow Syntax**: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions

### Getting Help

1. Check workflow logs in Actions tab
2. Review this guide's troubleshooting section
3. Search GitHub Discussions for similar issues
4. Open an issue in the repository

---

## Changelog

### Version 1.0 (October 2025)
- Initial release
- Support for Flutter mobile, web, and fullstack projects
- Comprehensive security scanning
- Platform-specific builds (iOS, Android, Web)
- Coverage reporting
- Performance analysis
- Automated PR comments
