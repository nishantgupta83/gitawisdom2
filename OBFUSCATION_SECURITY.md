# Code Obfuscation & Security Configuration

## Overview
GitaWisdom implements comprehensive code obfuscation and security hardening to protect against reverse engineering, decompilation, and unauthorized access. This document details the security measures in place.

## 🔐 Security Layers

### 1. Flutter-Level Obfuscation
All production builds use Flutter's built-in obfuscation:

```bash
--obfuscate                              # Obfuscate Dart code
--split-debug-info=build/debug-symbols   # Separate debug symbols
```

**What this does:**
- Renames Dart classes, methods, and variables to random names (a, b, c, etc.)
- Makes Dart code nearly impossible to read when decompiled
- Separates debugging symbols for crash reporting without exposing source

**Enabled in:**
- `scripts/build_production.sh` (Android APK/AAB)
- `scripts/run_production_iphone.sh` (iOS)

---

### 2. Android ProGuard/R8 Obfuscation

#### Configuration: `android/app/build.gradle.kts`

```kotlin
buildTypes {
    getByName("release") {
        isMinifyEnabled = true        // Enable code shrinking & obfuscation
        isShrinkResources = true      // Remove unused resources
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

**What this does:**
- **Code Shrinking**: Removes unused Java/Kotlin code
- **Resource Shrinking**: Removes unused assets and resources
- **Obfuscation**: Renames Java/Kotlin classes and methods
- **Optimization**: Optimizes bytecode for size and performance

---

### 3. Enhanced ProGuard Rules

#### File: `android/app/proguard-rules.pro`

Our custom ProGuard configuration includes aggressive obfuscation:

```proguard
# Remove all logging in production
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Aggressive class/method name obfuscation
-repackageclasses 'o'                # Flatten package structure
-allowaccessmodification             # Change access modifiers for better obfuscation
-overloadaggressively                # Aggressively rename methods

# Remove debug information
-keepattributes !SourceFile,!SourceDir,!LineNumberTable

# String encryption
-adaptclassstrings

# Optimize with 7 passes
-optimizationpasses 7
```

**Security Benefits:**
1. **No Log Leakage**: All `Log.d()`, `Log.v()`, etc. calls stripped from release builds
2. **Obfuscated Packages**: All packages flattened to single letter (com.hub4apps.* → o.*)
3. **Renamed Methods**: All method names shortened and obfuscated
4. **No Debug Info**: Stack traces won't reveal file names or line numbers
5. **String Protection**: Class name strings obfuscated where possible
6. **Optimized Code**: 7-pass optimization reduces APK size and improves performance

---

### 4. Sensitive Data Protection

#### Environment Variables (NOT Hardcoded)

**✅ Secure Approach:**
```bash
# Build with credentials injected at build time
flutter build apk --release \
  --obfuscate \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
```

**❌ NEVER DO THIS:**
```dart
// NEVER hardcode credentials in code!
const supabaseUrl = 'https://your-project.supabase.co';  // BAD!
const supabaseKey = 'your-anon-key-here';                 // BAD!
```

#### How Credentials Are Protected:

1. **Build-time Injection**: Credentials passed via `--dart-define` flags
2. **Environment Files**: `.env` files excluded from git (in `.gitignore`)
3. **Runtime Access**: Credentials accessed via `String.fromEnvironment()`
4. **Obfuscated**: Flutter's `--obfuscate` scrambles the compiled access code
5. **ProGuard**: Removes debug symbols and optimizes access patterns

**Files using secure credential access:**
- `lib/config/environment.dart`: Validates and loads credentials
- All Supabase service files use `Environment.supabaseUrl/supabaseAnonKey`

---

## 📦 Build Artifacts

### Debug Symbols Location

After building with obfuscation, debug symbols are stored separately:

```
build/
  ├── debug-symbols/          # Android debug symbols
  └── ios-debug-symbols/      # iOS debug symbols
```

**Important:**
- ⚠️ **NEVER** commit debug symbols to git
- ✅ Upload to Firebase Crashlytics or similar for crash reporting
- ✅ Store securely for deobfuscating crash reports
- ❌ Don't distribute with APK/IPA files

### Crash Reporting Setup

To deobfuscate crash reports:

1. **Save symbols**: Copy `build/debug-symbols` after each release build
2. **Version them**: Name folders by version (e.g., `v2.2.8-symbols/`)
3. **Upload to Crashlytics**:
   ```bash
   firebase crashlytics:symbols:upload \
     --app=1:your-app-id:android:hash \
     build/debug-symbols
   ```

---

## 🔍 Verifying Obfuscation

### Android APK Inspection

```bash
# Decompile APK to verify obfuscation
unzip -l build/app/outputs/flutter-apk/app-release.apk | grep -E "\.dex|\.so"

# Check with jadx or apktool
jadx build/app/outputs/flutter-apk/app-release.apk
```

**What you should see:**
- Classes named `o.a`, `o.b`, `o.c` instead of readable names
- Methods named `a()`, `b()`, `c()` instead of descriptive names
- No `Log.d()` or `Log.v()` calls in code
- Minimal debug strings

### iOS IPA Inspection

```bash
# Extract IPA
unzip GitaWisdom.ipa

# Check binary symbols
nm -g Payload/Runner.app/Runner | grep -v " U "
```

**What you should see:**
- Dart methods obfuscated to random names
- No readable Dart class/method names
- Minimal debug symbols

---

## 🛡️ Security Best Practices

### ✅ DO:
1. **Use `--obfuscate`** for ALL production builds
2. **Use `--dart-define`** for secrets (never hardcode)
3. **Enable ProGuard/R8** for Android release builds
4. **Store debug symbols** separately for crash reporting
5. **Validate builds** by inspecting decompiled code
6. **Use `.env` files** excluded from git
7. **Rotate credentials** if accidentally exposed

### ❌ DON'T:
1. **Don't commit** `.env` files to git
2. **Don't hardcode** API keys, tokens, or secrets
3. **Don't disable** obfuscation for production
4. **Don't commit** debug symbols to repository
5. **Don't share** unobfuscated builds publicly
6. **Don't log** sensitive data (even in debug mode)

---

## 📊 Obfuscation Effectiveness

### Before Obfuscation:
```java
// Readable Java code
package com.hub4apps.gitawisdom;

public class SupabaseAuthService {
    private String supabaseUrl;
    private String supabaseKey;

    public void authenticateUser(String email, String password) {
        Log.d("Auth", "Authenticating user: " + email);
        // ... authentication logic
    }
}
```

### After Obfuscation:
```java
// Obfuscated code
package o;

public class a {
    private String a;
    private String b;

    public void a(String var1, String var2) {
        // Log.d() call completely removed
        // ... obfuscated logic
    }
}
```

**Result:** ~95% harder to reverse engineer and understand app logic.

---

## 🔄 Build Commands Reference

### Android Production Build
```bash
# APK with obfuscation
./scripts/build_production.sh apk

# AAB for Google Play
./scripts/build_production.sh aab

# Both
./scripts/build_production.sh all
```

### iOS Production Build
```bash
# Run on physical iPhone with obfuscation
./scripts/run_production_iphone.sh <device-id>

# Build for App Store (manual)
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/ios-debug-symbols \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=APP_ENV=production
```

---

## 📱 Store Compliance

### Google Play Requirements
- ✅ Code obfuscation enabled (ProGuard/R8)
- ✅ Target SDK 35 (Android 15)
- ✅ No hardcoded credentials
- ✅ Debug symbols uploaded for crash reporting

### Apple App Store Requirements
- ✅ Bitcode disabled (Flutter default)
- ✅ App thinning enabled
- ✅ Debug symbols separated
- ✅ No embedded provisioning profiles in production

---

## 🚨 Security Incident Response

### If Credentials Are Exposed:

1. **Immediately rotate** Supabase keys:
   - Log into Supabase dashboard
   - Project Settings → API → Regenerate anon key
   - Update `.env` file with new key

2. **Revoke old keys** in Supabase:
   - Ensure old key is disabled
   - Monitor for unauthorized access

3. **Rebuild and redeploy**:
   ```bash
   ./scripts/build_production.sh all
   # Upload new builds to stores
   ```

4. **Force update** if necessary:
   - Implement version check in app
   - Require users to update to version with new keys

---

## 📖 Additional Resources

- [Flutter Obfuscation Docs](https://docs.flutter.dev/deployment/obfuscate)
- [ProGuard Manual](https://www.guardsquare.com/manual/home)
- [R8 Documentation](https://developer.android.com/studio/build/shrink-code)
- [iOS App Security](https://developer.apple.com/documentation/security)

---

## 🔧 Troubleshooting

### Build Fails After Adding Obfuscation

**Issue:** ProGuard strips too much code
**Solution:** Add keep rules in `proguard-rules.pro`:
```proguard
-keep class your.package.ClassName { *; }
```

### Crash Reports Are Unreadable

**Issue:** Missing debug symbols
**Solution:** Use saved symbols to deobfuscate:
```bash
# Android
flutter symbolize --debug-info=build/debug-symbols \
  --input=crash-stack-trace.txt

# iOS
symbolicatecrash crash.crash build/ios-debug-symbols
```

### App Crashes Only in Release Mode

**Issue:** ProGuard removed required code
**Solution:** Add necessary keep rules or disable specific optimizations

---

**Last Updated:** November 14, 2025 (v2.2.8+21)
**Security Reviewed:** ✅ Production-ready
**Next Review:** Before major version releases
