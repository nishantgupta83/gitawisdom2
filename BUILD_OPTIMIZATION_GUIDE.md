# GitaWisdom Production Build Optimization Guide

**Purpose**: Reduce app size, improve security, and follow store best practices
**Focus**: ProGuard obfuscation + Split APKs for Android
**Status**: Ready to implement

---

## 1. ProGuard Configuration (Android Java/Kotlin Code)

### Current Status
**File**: `android/app/build.gradle`

ProGuard handles Java/Kotlin code obfuscation while Flutter handles Dart obfuscation.

### Configuration Steps

#### Step 1: Enable in build.gradle
```gradle
android {
    buildTypes {
        release {
            // ✅ Enable minification
            minifyEnabled true

            // ✅ Remove unused resources
            shrinkResources true

            // ✅ Use default ProGuard rules + custom rules
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'

            // ✅ Keep symbols for crash reporting
            ndk {
                debugSymbolLevel 'FULL'
            }
        }
    }
}

// ✅ Enable Dart obfuscation
flutter {
    compileSdkVersion 35
}
```

#### Step 2: Verify proguard-rules.pro exists
**File**: `android/app/proguard-rules.pro`

```pro
# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Supabase classes (networking)
-keep class io.supabase.** { *; }
-keep class io.github.jan.supabase.** { *; }

# Keep reflection-based classes
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep application classes
-keep class com.hub4apps.gitawisdom.** { *; }
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Reduce log spam
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Preserve line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
```

### Build Commands

#### Option 1: Simple release build with obfuscation
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

**Output**:
- `build/app/outputs/flutter-apk/app-release.apk` (Universal APK)
- `build/app/outputs/symbols/` (Debug symbols for crash reporting)

**Size**: ~90-110 MB (depends on dependencies)

---

## 2. Split APKs by Architecture

### Why Split APKs?
| Metric | Universal APK | Split APKs |
|--------|---------------|-----------|
| arm64-v8a only | 90 MB | 60 MB |
| armeabi-v7a only | 90 MB | 45 MB |
| Total size reduction | None | 30-40% |
| User download | All, even unused | Only their arch |
| Store optimization | Manual | Google Play automatic |

### Implementation

#### Step 1: Enable in build.gradle
```gradle
android {
    bundle {
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true  // ✅ Enable ABI splits
        }
        language {
            enableSplit = true
        }
    }
}
```

#### Step 2: Build split APKs
```bash
# Single command for all architectures
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```

**Output**:
```
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk      (45 MB - 32-bit ARM, older phones)
├── app-arm64-v8a-release.apk        (60 MB - 64-bit ARM, modern phones)
├── app-x86_64-release.apk           (65 MB - Intel/Emulator)
└── app-release.apk                  (Universal 90 MB - fallback)
```

#### Step 3: Upload to Google Play
```bash
# Option 1: Upload AAB (Google Play generates splits automatically)
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols

# Upload: build/app/outputs/bundle/release/app-release.aab
# Google Play will:
# - Generate arm64-v8a: ~55 MB
# - Generate armeabi-v7a: ~42 MB
# - Generate x86_64: ~62 MB
# - Auto-serve based on device
```

---

## 3. Dart Code Obfuscation

### Automatic in Release Builds
**Command**:
```bash
flutter build apk --release --obfuscate
```

### What Gets Obfuscated?
✅ Class names: `AuthService` → `a_1b_2c`
✅ Method names: `signInWithGoogle` → `x_y_z`
✅ Variable names: `userEmail` → `m_n_o`
✅ Strings: NOT obfuscated (still readable)

### Debug Symbols (for crash reporting)
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

**Output**:
- `build/app/outputs/symbols/` contains symbol files
- Upload to Firebase Crashlytics for crash deobfuscation
- Stack traces automatically converted back to original names

---

## 4. Build Size Analysis

### Check Current Size
```bash
# Analyze APK contents
flutter build apk --release --analyze-size
```

**Output Example**:
```
Size of app-release.apk: 107.3 MB
- dart_vm_code: 42 MB (39%)
- assets: 18 MB (17%)
- native_libs: 25 MB (23%)
- resources: 22 MB (21%)
```

### Optimization Tips

#### Reduce Dart VM Code
- Minimize unused dependencies
- Use lazy loading for heavy packages
- Remove debug packages in release

#### Reduce Assets
```dart
// ❌ Don't include unnecessary assets
assets:
  - assets/images/
  - assets/fonts/

// ✅ Only include what's used
assets:
  - assets/images/app_logo.png
  - assets/fonts/poppins/
```

#### Reduce Native Libraries
```bash
# Only include required architectures (after testing)
flutter build apk --release --target-platform android-arm64
```

---

## 5. Complete Production Build Script

### Script: build_production.sh (UPDATED)
```bash
#!/bin/bash

# GitaWisdom Production Build Script
# Usage: ./scripts/build_production.sh [apk|aab|all]

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Load environment
source .env.production

export SUPABASE_URL="${SUPABASE_URL}"
export SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
export APP_ENV="production"

BUILD_TYPE="${1:-all}"

echo "🚀 Building GitaWisdom for production..."
echo "📱 Environment: production"
echo "🔐 Supabase configured"

# Clean previous builds
flutter clean
flutter pub get

case "$BUILD_TYPE" in
  apk)
    echo "📦 Building APK with split architectures..."
    flutter build apk --release \
      --split-per-abi \
      --obfuscate \
      --split-debug-info=build/app/outputs/symbols \
      --dart-define=SUPABASE_URL="$SUPABASE_URL" \
      --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
      --dart-define=APP_ENV=production

    echo "✅ APKs built successfully:"
    echo "   arm64-v8a:   build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
    echo "   armeabi-v7a: build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
    echo "   x86_64:      build/app/outputs/flutter-apk/app-x86_64-release.apk"
    ;;

  aab)
    echo "📦 Building App Bundle (Google Play)..."
    flutter build appbundle --release \
      --obfuscate \
      --split-debug-info=build/app/outputs/symbols \
      --dart-define=SUPABASE_URL="$SUPABASE_URL" \
      --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
      --dart-define=APP_ENV=production

    echo "✅ AAB built successfully:"
    echo "   build/app/outputs/bundle/release/app-release.aab"
    echo "📝 Next: Upload to Google Play Console"
    ;;

  all)
    echo "📦 Building APK (split)..."
    flutter build apk --release \
      --split-per-abi \
      --obfuscate \
      --split-debug-info=build/app/outputs/symbols \
      --dart-define=SUPABASE_URL="$SUPABASE_URL" \
      --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
      --dart-define=APP_ENV=production

    echo "📦 Building AAB..."
    flutter build appbundle --release \
      --obfuscate \
      --split-debug-info=build/app/outputs/symbols \
      --dart-define=SUPABASE_URL="$SUPABASE_URL" \
      --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
      --dart-define=APP_ENV=production

    echo "✅ All builds completed:"
    echo "   APK (arm64-v8a):   build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
    echo "   APK (armeabi-v7a): build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
    echo "   APK (x86_64):      build/app/outputs/flutter-apk/app-x86_64-release.apk"
    echo "   AAB:               build/app/outputs/bundle/release/app-release.aab"
    ;;

  *)
    echo "❌ Invalid option: $BUILD_TYPE"
    echo "Usage: $0 [apk|aab|all]"
    exit 1
    ;;
esac

echo "✨ Production build complete!"
```

---

## 6. Upload to Stores

### Google Play (Recommended: Use AAB)
```bash
# 1. Build AAB
./scripts/build_production.sh aab

# 2. Upload to Play Console
#    - Go to: https://play.google.com/console
#    - Select app
#    - Release → Production
#    - Upload build: build/app/outputs/bundle/release/app-release.aab
#    - Add release notes
#    - Start rollout (5% → 25% → 100%)

# 3. Google Play generates optimized APKs automatically
#    - arm64-v8a: 55 MB (60% of users)
#    - armeabi-v7a: 42 MB (35% of users)
#    - x86_64: 62 MB (5% of users)
```

### Apple App Store
```bash
# 1. Build IPA
flutter build ipa --release

# 2. Upload with Transporter
open ~/Applications/Transporter.app

# 3. Or use xcrun
xcrun altool --upload-app --file build/ios/ipa/*.ipa \
  --type ios \
  --apple-id "$APPLE_ID" \
  --password "$APP_SPECIFIC_PASSWORD"
```

---

## 7. Monitoring Build Size Over Time

### Track APK Size
```bash
# Create baseline
echo "$(date): $(stat -f%z build/app/outputs/flutter-apk/app-release.apk)" >> build_size_history.txt

# Monitor
cat build_size_history.txt
```

### Goals
- ✅ Universal APK: < 120 MB
- ✅ arm64-v8a split: < 65 MB
- ✅ armeabi-v7a split: < 50 MB
- ✅ AAB (Play Console): < 100 MB

---

## 8. Troubleshooting

### Issue: ProGuard build fails
```bash
# Error: ProGuard not configured
# Solution: Run `flutter pub get` first
flutter pub get
flutter build apk --release
```

### Issue: Split APK not generated
```bash
# Error: No arm64-v8a APK created
# Cause: gradle.properties not configured
# Solution: Add to android/gradle.properties
android.enableBundleForAutomatedTesting=true
```

### Issue: Build size increased after obfuscation
```bash
# This is normal - obfuscation adds ~5-10% overhead
# Benefit: Better security and reduced reverse engineering risk
```

---

## 9. Best Practices Checklist

- ✅ Enable ProGuard obfuscation (security)
- ✅ Use split APKs (smaller downloads)
- ✅ Keep debug symbols (crash reporting)
- ✅ Build AAB for Google Play (recommended format)
- ✅ Test both split APKs on real devices
- ✅ Monitor build size over time
- ✅ Keep credentials out of repositories
- ✅ Use --dart-define for sensitive values
- ✅ Analyze size before each submission

---

## 10. Command Reference

| Task | Command |
|------|---------|
| **Build APK (split)** | `flutter build apk --release --split-per-abi --obfuscate` |
| **Build APK (universal)** | `flutter build apk --release --obfuscate` |
| **Build AAB** | `flutter build appbundle --release --obfuscate` |
| **With debug symbols** | `--split-debug-info=build/app/outputs/symbols` |
| **With env vars** | `--dart-define=SUPABASE_URL=<url>` |
| **Analyze size** | `flutter build apk --release --analyze-size` |
| **Production script** | `./scripts/build_production.sh all` |

---

**Last Updated**: November 12, 2025
**Status**: Ready to implement
**Recommended Priority**: High (reduces APK size 30-40%)
