# GitaWisdom Store Compliance Testing Checklist v2.3.0+24

**Purpose**: Comprehensive testing plan to resolve Google Play & Apple App Store rejections
**Status**: Critical testing required before resubmission
**Last Updated**: November 12, 2025

---

## 🔴 Critical Issues Fixed (Nov 12, 2025)

### Issue #1: Hive Box Type Mismatch (BLOCKING)
**Status**: ✅ FIXED in commit `092d04d`
**Root Cause**: All typed Hive boxes opened as `Box<dynamic>` causing type mismatch errors
**Impact**: App unable to load any cached content (chapters, verses, scenarios)
**Fix Applied**:
```dart
// BEFORE (WRONG):
await Hive.openBox(boxName);  // Opens as Box<dynamic>

// AFTER (CORRECT):
await Hive.openBox<Chapter>('chapters');
await Hive.openBox<Verse>('gita_verses_cache');
await Hive.openBox<Scenario>('scenarios_critical');
// ... etc for all typed boxes
```

---

## ✅ Testing Protocol (MANDATORY BEFORE SUBMISSION)

### Phase 1: Core Functionality (iOS + Android)

#### 1.1 App Launch & Initialization
- [ ] **iOS**: Clean install launches without crashes
  - Delete app from device
  - Install fresh build
  - Wait 30 seconds for splash screen
  - Verify app logo appears
- [ ] **Android**: Clean install launches without crashes
  - Clear cache/data
  - Install fresh APK
  - Verify splash screen shows

#### 1.2 Hive Box Initialization (CRITICAL)
**Expected logs**:
```
📦 Initializing Hive boxes with proper types...
✅ Opened: settings (untyped)
✅ Opened: bookmarks (typed<Bookmark>)
✅ Opened: daily_verses (typed<DailyVerseSet>)
✅ Opened: chapters (typed<Chapter>)
✅ Opened: chapter_summaries_permanent (typed<ChapterSummary>)
✅ Opened: gita_verses_cache (typed<Verse>)
✅ Opened: scenarios_critical (typed<Scenario>)
✅ Opened: scenarios_frequent (typed<Scenario>)
✅ All Hive boxes initialized with correct types
```

**Test**:
- [ ] Connect iPhone to Mac with USB cable
- [ ] Run: `flutter run -d <device_id>`
- [ ] Check console for above logs
- [ ] **MUST NOT SEE**: "HiveError: The box is already open and of type Box<dynamic>"

#### 1.3 Content Loading (HOME SCREEN)
- [ ] **Chapters**: "18 Gita Chapters" display loads
  - [ ] All 18 chapter cards visible
  - [ ] Chapter titles readable
  - [ ] Chapter summaries display
  - [ ] No "Loading..." stuck state > 5 seconds

- [ ] **Daily Verses**: Carousel shows random verses
  - [ ] Verse text displays clearly
  - [ ] Chapter number visible
  - [ ] Swipe animation smooth

- [ ] **Scenarios/Dilemmas**: Load on Home tab
  - [ ] At least 5 scenarios visible
  - [ ] "Heart" and "Duty" guidance text readable
  - [ ] No cache errors in console

#### 1.4 Navigation (All Tabs)
- [ ] **Home Tab**: Chapters + Daily Verses + Scenarios visible
- [ ] **Chapters Tab**: All 18 chapters scrollable
  - [ ] Tap chapter → opens full chapter view
  - [ ] Verses display for each chapter
  - [ ] Scroll performance smooth (60fps)

- [ ] **Scenarios Tab**: Dilemmas list loads
  - [ ] Filter buttons work (Heart/Duty/All)
  - [ ] Search functionality works
  - [ ] Tap scenario → detail page shows

- [ ] **Journal Tab**:
  - [ ] "Sign In" button OR "Continue as Guest" visible
  - [ ] Can add journal entry as guest
  - [ ] Can add journal entry after sign in

- [ ] **More Tab**:
  - [ ] Settings visible
  - [ ] Dark mode toggle works
  - [ ] **For signed-in users**: "Account" section shows with:
    - [ ] "Delete Account" button visible
    - [ ] Delete process works without crash

---

### Phase 2: Authentication Flow Testing

#### 2.1 Anonymous (Guest) Mode
- [ ] **First Launch**:
  - [ ] App accessible without sign-in
  - [ ] All content viewable
  - [ ] Journal accessible with "Continue as Guest"

- [ ] **Journal Entry**:
  - [ ] Add entry as guest
  - [ ] Entry persists after app restart
  - [ ] Entry still visible after closing/reopening app

#### 2.2 Google Sign-In (Android Priority)
- [ ] **Android**: Google Sign-In button works
  - [ ] Tap "Sign In" → Google prompt appears
  - [ ] Select account → redirects to app
  - [ ] App shows "Signed in" state
  - [ ] Journal shows as signed-in user

- [ ] **iOS**: Google Sign-In button works
  - [ ] Requires iOS 11+ (check version)
  - [ ] Tap "Sign In" → Google auth screen
  - [ ] Returns to app successfully

#### 2.3 Apple Sign-In (iOS Priority)
- [ ] **iOS**: Apple Sign-In button visible
  - [ ] Tap "Sign In" → Apple auth sheet
  - [ ] Approve → returns to app
  - [ ] Account shows "Signed in via Apple"

- [ ] **Data Sync**: User data syncs to Supabase
  - [ ] Journal entries save to cloud
  - [ ] Sign in on different device → data available

#### 2.4 Account Deletion (NEW - Google Play Requirement)
**File**: `lib/screens/more_screen.dart:164-196`

- [ ] **UI Present**: "Account" section visible for signed-in users
  - [ ] Only shows for `isAuthenticated` (not anonymous)
  - [ ] "Delete Account" button present
  - [ ] Delete button is last section (not hidden)

- [ ] **Deletion Flow**:
  - [ ] Tap "Delete Account"
  - [ ] Confirmation dialog appears
  - [ ] Confirm → loading indicator shows
  - [ ] Account deleted from Supabase
  - [ ] App returns to guest mode

- [ ] **Data Wiped** (12 Hive boxes cleared):
  - [ ] User journal entries gone
  - [ ] Bookmarks cleared
  - [ ] Progress reset
  - [ ] Settings cleared

---

### Phase 3: Data Privacy & Security

#### 3.1 Journal Encryption (AES-256)
**File**: `lib/services/journal_service.dart`

- [ ] **Encryption**: Journal entries encrypted in Hive
  - [ ] Add sensitive journal entry
  - [ ] Check Hive file in device storage (not readable)
  - [ ] Restart app → entry still encrypted
  - [ ] Re-open entry → decrypts correctly

- [ ] **Key Storage**: Encryption keys in secure storage
  - [ ] iOS: Keychain used (not accessible via file browser)
  - [ ] Android: KeyStore used
  - [ ] Fresh install: New encryption key generated

#### 3.2 Permissions (Android 13+)
**File**: `lib/services/notification_permission_service.dart`

- [ ] **Notification Permission**:
  - [ ] Android 13+: Permission prompt appears
  - [ ] Can deny permission (app continues)
  - [ ] Can grant permission (notifications work)

- [ ] **Privacy Label** (iOS):
  - [ ] Upload build to App Store Connect
  - [ ] Privacy Manifest shows:
    - [ ] No tracking (no IDFAs)
    - [ ] No sensitive data collection
    - [ ] Calendar access: Not requested
    - [ ] Contacts: Not requested

#### 3.3 Offline Functionality
- [ ] **No Internet**: App still works
  - [ ] Chapters display from cache
  - [ ] Verses show from cache
  - [ ] Scenarios display from cache
  - [ ] Journal works offline
  - [ ] Settings work offline

- [ ] **Reconnect**:
  - [ ] Turn internet back on
  - [ ] Content syncs correctly
  - [ ] No duplicate entries

---

### Phase 4: Performance & UX

#### 4.1 Performance Metrics
- [ ] **App Launch**: < 2 seconds to first content
  - [ ] Splash screen duration: < 3 seconds
  - [ ] Home screen interactive: < 4 seconds

- [ ] **Content Loading**: No frame drops > 100ms
  - [ ] Scroll chapters list: 60fps (iOS ProMotion = 120fps)
  - [ ] Open chapter detail: No jank
  - [ ] Scenario search: Instant response

- [ ] **Memory**: No memory leaks on repeated actions
  - [ ] Add journal entry 10 times → no crash
  - [ ] Switch dark mode 10 times → no crash
  - [ ] Scroll to end of scenarios → no crash

#### 4.2 UI/UX Compliance
- [ ] **Text Scaling**: All text scales with system settings
  - [ ] Settings → Display → Larger Text
  - [ ] App text grows proportionally
  - [ ] No text cutoff

- [ ] **Dark Mode**: Works correctly
  - [ ] Light mode: Good contrast
  - [ ] Dark mode: No white text on white background
  - [ ] Toggle 10 times: No crashes

- [ ] **Accessibility**:
  - [ ] Enable VoiceOver (iOS)
  - [ ] Tab through all screens: Navigation clear
  - [ ] No unlabeled buttons

---

### Phase 5: Store Policy Compliance

#### 5.1 Content Policy (Google Play)
- [ ] **Religious Content**: Appropriately labeled
  - [ ] App description mentions "Bhagavad Gita"
  - [ ] Content rating: 4+ (no violent/sexual content)
  - [ ] "Philosophy" category selected

- [ ] **Functionality**:
  - [ ] No hidden ads
  - [ ] No malware/trojans
  - [ ] No spam content

#### 5.2 Apple App Store Guidelines
- [ ] **Privacy**:
  - [ ] Privacy policy linked in "About" tab
  - [ ] Link to: https://hub4apps.com/privacy.html
  - [ ] Privacy Manifest includes required declarations

- [ ] **Functionality**:
  - [ ] No cryptocurrency mining
  - [ ] No unauthorized access to user data
  - [ ] No performance degradation

#### 5.3 Data Collection Disclosure
- [ ] **Privacy Policy Accurate**:
  - [ ] States: "No personal data collection"
  - [ ] States: "Journal encrypted locally"
  - [ ] States: "Optional Google/Apple sign-in"
  - [ ] States: "Account deletion available"

---

### Phase 6: Build & Deployment Testing

#### 6.1 Android Build (APK/AAB)
- [ ] **Obfuscation**: ProGuard enabled
  ```bash
  flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
  ```
  - [ ] APK size < 150MB (decompressed)
  - [ ] Decompiled code is obfuscated
  - [ ] Native libraries protected

- [ ] **Split APKs** (Google Play requirement):
  ```bash
  flutter build apk --release --split-per-abi
  ```
  - [ ] arm64-v8a APK works
  - [ ] armeabi-v7a APK works
  - [ ] x86_64 APK works

- [ ] **AAB Build**: Google Play preferred format
  ```bash
  flutter build appbundle --release --obfuscate
  ```
  - [ ] AAB size < 100MB
  - [ ] Upload to Play Console test track
  - [ ] Install via Play Console internal testing

#### 6.2 iOS Build (IPA)
- [ ] **App Store Build**:
  - [ ] Archive created: `build/ios/archive/Runner.xcarchive`
  - [ ] Signed with production certificate
  - [ ] Provisioning profile: App Store distribution

- [ ] **Privacy Manifest**:
  - [ ] Included in bundle
  - [ ] Declares all API usage
  - [ ] Sign manifest: `codesign`

- [ ] **dsyms**: Debug symbols for crashes
  - [ ] Generated during build
  - [ ] Upload to App Store Connect
  - [ ] Enable crash reporting

#### 6.3 Production Credentials
- [ ] **Environment Variables**:
  - [ ] Supabase URL embedded in build
  - [ ] Anon key embedded in build
  - [ ] No credentials in code repositories
  - [ ] Use `--dart-define` for builds

---

## 🚀 Pre-Submission Checklist

### Before Google Play Submission
- [ ] Android build tested on 3+ devices (armeabi-v7a, arm64-v8a, x86_64)
- [ ] Hive boxes initialize without errors
- [ ] All content loads (chapters, verses, scenarios)
- [ ] Account deletion works and clears all data
- [ ] Notification permission prompts correctly
- [ ] ProGuard obfuscation enabled
- [ ] Split APKs generated
- [ ] Content rating correct (4+)
- [ ] Privacy policy URL works

### Before Apple App Store Submission
- [ ] iOS build tested on iPhone 14+
- [ ] Hive boxes initialize without errors
- [ ] All content loads (chapters, verses, scenarios)
- [ ] Apple Sign-In works
- [ ] Dark mode works
- [ ] Text scaling works
- [ ] Privacy Manifest included
- [ ] dsyms uploaded
- [ ] No hardcoded credentials in code
- [ ] Privacy policy URL works

---

## 📋 Bug Report If Issues Found

If any test fails, document:
1. **Device**: Model, iOS/Android version
2. **Step**: Exact action that failed
3. **Error**: Screenshot or console log
4. **Expected**: What should have happened
5. **Actual**: What actually happened

Example:
```
Device: iPhone 14 Pro (iOS 18.5)
Step: Tap "Sign In with Apple" on Journal tab
Error: [Screenshot showing crash]
Expected: Apple Sign-In sheet appears
Actual: App crashes with "Exception in firebase_auth"
```

---

## ✅ Final Verification (Before Submitting)

```bash
# 1. Verify app compiles without warnings
flutter build apk --release 2>&1 | grep -i "error"

# 2. Verify no secrets in code
grep -r "SUPABASE_URL" lib/ android/ ios/

# 3. Verify Hive adapters registered
grep -r "registerAdapter" lib/

# 4. Verify privacy policy linked
grep -r "privacy.html" lib/

# 5. Verify account deletion implemented
grep -r "deleteAccount" lib/screens/
```

**All checks must pass before submission.**

---

## 🎯 Next Steps

1. **Apply all fixes above** ✅ (Hive box type fix committed)
2. **Run comprehensive tests** on iOS and Android
3. **Verify no regressions** with test suite: `./run_tests.sh`
4. **Build production releases**:
   ```bash
   ./scripts/build_production.sh    # Build both APK and AAB
   ```
5. **Submit to stores**:
   - Google Play: Upload AAB to internal test track first
   - Apple App Store: Submit build via App Store Connect

---

**Status**: Ready for testing phase
**Last Updated**: November 12, 2025 15:37 UTC
**Reviewer**: Automated verification script
