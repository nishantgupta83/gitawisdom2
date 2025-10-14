# GitaWisdom Store Bundle Summary
**Build Date:** October 8, 2025
**Version:** 2.3.1 (Build 25)
**User Display Version:** 1.0.1

---

## 🤖 Android Bundles

### Google Play Store Bundle (AAB)
- **File:** `build/app/outputs/bundle/release/app-release.aab`
- **Size:** 74MB (77.8MB uncompressed)
- **Status:** ✅ Ready for Google Play Store upload
- **Signing:** Properly signed with production keystore
- **Keystore:** `android/gitawisdom-upload-key.jks`
- **Key Alias:** `upload`
- **Certificate Valid Until:** February 18, 2053
- **Certificate SHA-256:** `41:0A:86:35:F0:68:25:60:A0:B1:6A:33:8A:4C:47:9A:54:05:4B:1A:30:1E:46:95:05:3D:94:C6:A0:AD:22:BC`

### Direct Distribution APK
- **File:** `build/app/outputs/flutter-apk/app-release.apk`
- **Size:** 100MB (105.1MB uncompressed)
- **Status:** ✅ Ready for direct distribution/testing
- **Signing:** Same production keystore as AAB
- **ProGuard:** Enabled (obfuscation applied)

### Android Build Configuration
- **Package Name:** `com.hub4apps.gitawisdom`
- **Target SDK:** API 35 (Android 15)
- **Minimum SDK:** API 21 (Android 5.0)
- **Permissions:**
  - Internet (network access for Supabase)
  - Foreground Service (background audio)
  - Post Notifications (daily verse reminders)
  - Wake Lock (audio playback)
  - Network State (connectivity monitoring)

---

## 🍎 iOS Bundle

### App Store Distribution (IPA)
- **File:** `build/ios/ipa/GitaWisdom.ipa`
- **Size:** 47MB (50.1MB uncompressed)
- **Status:** ✅ Ready for App Store submission
- **Archive:** `build/ios/archive/Runner.xcarchive` (243.3MB)
- **dSYMs:** Included for crash symbolication
- **Signing:** Automatically signed with Team ID `ZW6PP4YAN4`

### iOS Build Configuration
- **Bundle Identifier:** `com.hub4apps.gitawisdom`
- **Display Name:** `GitaWisdom`
- **Deployment Target:** iOS 13.0+
- **Privacy Manifest:** ✅ Included (`PrivacyInfo.xcprivacy`)
- **Capabilities:**
  - Background Audio
  - Sign in with Apple
  - Associated Domains (deep linking)

### Privacy Disclosures
**Data Collection:**
- Device ID (non-linked, non-tracking) - Analytics
- User ID (linked) - App Functionality

**API Usage:**
- System Boot Time (35F9.1) - Performance measurement
- Disk Space (E174.1) - Cache management
- File Timestamp (C617.1) - Offline sync
- User Defaults (CA92.1) - Settings storage

---

## 🔐 Security & Compliance

### Google Play 2024 Compliance
✅ In-app account deletion implemented
✅ AES-256 journal encryption with secure key storage
✅ Android 13+ runtime permissions (POST_NOTIFICATIONS)
✅ Transparent data collection disclosure
✅ User data deletion on account removal (12 Hive boxes)

### iOS App Store Compliance
✅ Privacy manifest included and validated
✅ No unauthorized API usage
✅ Proper permission descriptions in Info.plist
✅ Background audio capability documented
✅ No microphone usage (removed unnecessary permission)

---

## 📦 Bundle Contents

### Included Assets
- App icon (ocean theme) - 1024x1024px
- Background music: `Riverside_Morning_Calm.mp3`
- Hub4Apps QR code (SVG)
- Material Icons (tree-shaken: 99.4% reduction, 10KB)

### Third-Party SDKs
- **Supabase:** PostgreSQL backend + Auth
- **Hive:** Local offline storage
- **Google Sign-In:** OAuth authentication
- **Apple Sign-In:** OAuth authentication
- **Facebook Auth:** OAuth authentication
- **Google Fonts:** Poppins typography
- **Just Audio:** Background music playback
- **Flutter TTS:** Text-to-speech (future feature)
- **TFLite:** ML-based semantic search

### Environment Configuration
- **Production Supabase URL:** Embedded via `--dart-define`
- **Supabase Anonymous Key:** Embedded via `--dart-define`
- **Environment:** PRODUCTION
- **Debug Mode:** Disabled
- **Analytics:** Disabled (privacy-first)
- **Crash Reporting:** Disabled

---

## 📤 Upload Instructions

### Google Play Store (AAB)
1. Navigate to [Google Play Console](https://play.google.com/console)
2. Select GitaWisdom app
3. Go to "Release" → "Production" → "Create new release"
4. Upload `build/app/outputs/bundle/release/app-release.aab`
5. Fill release notes for v2.3.1
6. Submit for review

### Apple App Store (IPA)
**Option 1: Apple Transporter (Recommended)**
1. Download [Apple Transporter](https://apps.apple.com/us/app/transporter/id1450874784)
2. Drag and drop `build/ios/ipa/GitaWisdom.ipa` into Transporter
3. Sign in with Apple Developer account
4. Click "Deliver" to upload

**Option 2: Command Line**
```bash
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/GitaWisdom.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

**Option 3: Xcode**
1. Open `build/ios/archive/Runner.xcarchive` in Xcode
2. Click "Distribute App"
3. Select "App Store Connect"
4. Follow the prompts to upload

---

## ✅ Pre-Upload Validation Checklist

### Android
- [x] AAB builds successfully
- [x] APK builds successfully
- [x] Production signing verified
- [x] Version 2.3.1 (Build 25) confirmed
- [x] Target SDK API 35 (Android 15)
- [x] ProGuard enabled
- [x] Google Play 2024 compliance features implemented
- [x] Account deletion tested
- [x] Journal encryption tested

### iOS
- [x] IPA builds successfully
- [x] Archive includes dSYMs
- [x] Version 2.3.1 (Build 25) confirmed
- [x] Privacy manifest included
- [x] Info.plist cleaned (no microphone permission)
- [x] Deployment target iOS 13.0+
- [x] Apple Sign-In configured
- [x] Deep linking configured

---

## 🔄 Version History

### v2.3.1 (Build 25) - October 8, 2025
**Critical Bug Fixes:**
- ✅ Chapters loading: Instant cache-first with parallel network fetching
- ✅ OAuth error: Fixed Google sign-in error display after successful auth
- ✅ Text alignment: Heart/Duty Says sections now properly aligned (large font fix)
- ✅ Search UI: Removed duplicate indicators for cleaner interface
- ✅ Semantic search: Always-on intelligent search implementation

**Enhanced Journal Experience:**
- 📝 Emoji rating hints with visual feedback
- 🎨 Mint gradient background for calming aesthetic
- 💜 Gradient save button with pulse animation
- 🔘 Simplified emoji-only rating (removed stars)
- 📳 Haptic feedback on interactions
- ✅ Removed categories for streamlined experience

**Account Management:**
- 🔐 Account section moved below Appearance
- 📂 Expandable account section with Sign Out/Delete options
- ✅ Fixed account deletion bug (PostgreSQL column error)

**Production Readiness:**
- 🔒 User-facing version: 1.0.1
- 🏪 Store version: 2.3.1+25
- 🚫 Debug mode disabled
- 📱 iOS Privacy Manifest added
- 🔐 Microphone permission removed

---

## 📊 Build Statistics

| Metric | Android AAB | Android APK | iOS IPA |
|--------|-------------|-------------|---------|
| **File Size** | 74MB | 100MB | 47MB |
| **Uncompressed** | 77.8MB | 105.1MB | 50.1MB |
| **Build Time** | 3m 30s | 1m 7s | 2m 11s |
| **Tree-shaking** | Yes | Yes | Yes |
| **Obfuscation** | Yes | Yes | Yes |

**Total Build Time:** ~7 minutes
**Font Optimization:** 99.4% reduction (1.6MB → 10KB)

---

## 🚀 Next Steps

1. **Android:** Upload AAB to Google Play Console
2. **iOS:** Upload IPA to App Store Connect via Transporter
3. **Testing:** Submit for closed testing on both platforms
4. **Monitoring:** Enable crash reporting post-approval
5. **Analytics:** Re-enable analytics after user consent

---

## 📞 Support Information

- **Developer:** Hub4Apps
- **Bundle ID:** com.hub4apps.gitawisdom
- **Privacy Policy:** https://hub4apps.com/privacy.html
- **Support Email:** nishantgupta83@gmail.com
- **Category:** Lifestyle
- **Content Rating:** Everyone

---

**Generated:** October 8, 2025 23:45 UTC
**Build Environment:** macOS 14.6.0, Flutter 3.2.0+
**Distribution:** Production Release
