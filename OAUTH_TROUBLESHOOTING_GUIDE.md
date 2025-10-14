# GitaWisdom OAuth Implementation - Complete Technical Guide

**Date:** October 13, 2025
**App:** GitaWisdom (com.hub4apps.gitawisdom)
**Issue:** Reported "Route not found" error after Google/Apple OAuth sign-in
**Status:** OAuth appears functional in logs, but user reports seeing errors

---

## Table of Contents
1. [System Overview](#system-overview)
2. [Current Configuration](#current-configuration)
3. [OAuth Flow Architecture](#oauth-flow-architecture)
4. [Reported Issue](#reported-issue)
5. [Troubleshooting Steps](#troubleshooting-steps)
6. [Configuration URLs](#configuration-urls)
7. [Code Implementation](#code-implementation)
8. [Testing Checklist](#testing-checklist)

---

## System Overview

### Application Details
- **Bundle ID:** `com.hub4apps.gitawisdom`
- **Platform:** Flutter (iOS & Android)
- **Backend:** Supabase (PostgreSQL + Authentication)
- **OAuth Providers:** Google, Apple, Facebook

### Supabase Project
- **Project URL:** `https://wlfwdtdtiedlcczfoslt.supabase.co`
- **Authentication Callback:** `https://wlfwdtdtiedlcczfoslt.supabase.co/auth/v1/callback`
- **Deep Link Scheme:** `com.hub4apps.gitawisdom://`

---

## Current Configuration

### 1. Supabase Dashboard Settings

**Location:** Supabase Dashboard → Authentication → URL Configuration
**Dashboard URL:** https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/url-configuration

#### Current Settings (as of last update):
```
Site URL: com.hub4apps.gitawisdom://
Redirect URLs: com.hub4apps.gitawisdom://login-callback
```

#### Google OAuth Provider Settings
**Location:** Supabase Dashboard → Authentication → Providers → Google

**Required Configuration:**
- Enable Google provider
- Add Google Client ID (from Google Cloud Console)
- Add Google Client Secret (from Google Cloud Console)
- Authorized redirect URIs in Google Cloud Console must include:
  ```
  https://wlfwdtdtiedlcczfoslt.supabase.co/auth/v1/callback
  ```

**Google Cloud Console URL:**
https://console.cloud.google.com/apis/credentials

#### Apple OAuth Provider Settings
**Location:** Supabase Dashboard → Authentication → Providers → Apple

**Required Configuration:**
- Enable Apple provider
- Add Apple Services ID (from Apple Developer)
- Add Apple Team ID
- Add Apple Key ID
- Add Apple Private Key (.p8 file content)
- Authorized domains in Apple Developer must include:
  ```
  wlfwdtdtiedlcczfoslt.supabase.co
  ```

**Apple Developer Console URL:**
https://developer.apple.com/account/resources/identifiers/list/serviceId

---

### 2. iOS Configuration

**File:** `ios/Runner/Info.plist`

**Current URL Scheme Configuration:**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.hub4apps.gitawisdom.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.hub4apps.gitawisdom</string>
        </array>
    </dict>
</array>
```

**Missing Configuration (Potential Fix):**
The iOS Info.plist does NOT currently have the `FlutterDeepLinkingEnabled` flag. This may need to be added:

```xml
<key>FlutterDeepLinkingEnabled</key>
<false/>
```

**Location in file:** Lines 66-76

---

### 3. Android Configuration

**File:** `android/app/src/main/AndroidManifest.xml`

**Expected Intent Filter:**
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="com.hub4apps.gitawisdom" android:host="login-callback" />
</intent-filter>
```

**Missing Configuration (Potential Fix):**
May need to add metadata to disable Flutter's default deep linking:

```xml
<meta-data
    android:name="flutter_deeplinking_enabled"
    android:value="false" />
```

---

## OAuth Flow Architecture

### Expected Flow (Working Correctly)

1. **User Action:** User taps "Sign in with Google/Apple" button
2. **App Initiates OAuth:**
   ```dart
   await _supabase.auth.signInWithOAuth(
     OAuthProvider.google,
     authScreenLaunchMode: LaunchMode.externalApplication,
   );
   ```
3. **External Browser Opens:** User authenticates with Google/Apple
4. **OAuth Provider Redirects:**
   ```
   https://wlfwdtdtiedlcczfoslt.supabase.co/auth/v1/callback?code=...&state=...
   ```
5. **Supabase Processes Auth:** Exchange auth code for tokens
6. **Supabase Issues Deep Link:**
   ```
   com.hub4apps.gitawisdom://login-callback?access_token=...&refresh_token=...
   ```
7. **App Receives Deep Link:** iOS/Android opens app with deep link
8. **Supabase SDK Handles Deep Link:**
   - Log: `supabase.supabase_flutter: INFO: handle deeplink uri`
   - Emits: `AuthChangeEvent.signedIn`
9. **App Navigates:** Auth listener navigates to home screen

### Current Log Evidence (Working)

From iPhone logs (device 00008030-000C0D1E0140802E):
```
flutter: ✅ Google sign-in initiated
[app backgrounds for OAuth]
flutter: supabase.supabase_flutter: INFO: handle deeplink uri
flutter: 🔐 Auth state changed: AuthChangeEvent.signedIn
flutter: 🔐 Auth state changed: AuthChangeEvent.signedIn
[app returns to foreground - user logged in]
```

**Conclusion:** OAuth flow completes successfully. User is authenticated.

---

## Reported Issue

### Symptom
User reports seeing a "Route not found" error screen after completing Google/Apple sign-in, despite logs showing successful authentication.

### User's Screenshots (from previous conversation)
- Error screen shows "Route not found"
- Shows callback URL path in error message
- Shows "Go Home" button

### Discrepancy
**Logs show:** OAuth working perfectly, no routing errors
**User sees:** Error screen (timing/visibility unclear)

### Possible Explanations

1. **Race Condition:**
   - Flutter's router intercepts deep link briefly
   - Shows error screen momentarily
   - Supabase then processes deep link
   - App navigates to home (overriding error)
   - **Result:** User sees flash of error screen

2. **Route Handler Conflict:**
   - `AppRouter.generateRoute()` gets called with `/login-callback?code=...`
   - Route exists but query parameters cause mismatch
   - Error screen shows briefly before Supabase navigation

3. **Stale App State:**
   - User testing with old build that didn't have `/login-callback` route
   - Current build (with route added) may work correctly

4. **Platform-Specific Behavior:**
   - iOS vs Android handle deep links differently
   - May need platform-specific configuration adjustments

---

## Troubleshooting Steps

### Step 1: Verify Current Behavior
1. **Clean Build & Reinstall:**
   ```bash
   cd /Users/nishantgupta/Documents/GitaGyan/OldWisdom
   flutter clean
   flutter pub get
   ./scripts/run_dev.sh 00008030-000C0D1E0140802E
   ```

2. **Test Sign-In Flow:**
   - Sign out completely
   - Tap "Sign in with Google"
   - Complete OAuth flow
   - **Record:** Do you see any error screen? For how long?

3. **Monitor Logs:**
   ```bash
   # Watch for routing errors
   grep -i "route"
   grep -i "error"
   grep -i "deeplink"
   ```

### Step 2: Verify Route Configuration

**File:** `lib/core/navigation/app_router.dart` (Lines 80-83)

**Current Implementation:**
```dart
case loginCallback:
  // OAuth callback route - Supabase handles authentication
  // Just return to splash which will redirect based on auth state
  return MaterialPageRoute(builder: (_) => const SplashScreen());
```

**Issue:** Returning `SplashScreen` may cause re-initialization loop.

**Suggested Fix:**
```dart
case loginCallback:
  // OAuth callback route - Supabase handles authentication
  // Return empty loading screen briefly, auth listener will navigate
  return MaterialPageRoute(
    builder: (_) => const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
```

### Step 3: Check Auth Listener

**File:** `lib/services/supabase_auth_service.dart` (Lines 105-154)

**Current Auth Listener:**
```dart
void _setupAuthListener() {
  _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    _currentSession = data.session;

    debugPrint('🔐 Auth state changed: $event');

    if (event == AuthChangeEvent.signedIn) {
      _clearError();
      notifyListeners();
    }
    // ... more handling
  });
}
```

**Question:** Does the auth listener navigate, or does something else handle navigation?

### Step 4: iOS Deep Link Configuration

**Test Adding Flutter Deep Link Disable Flag:**

**File:** `ios/Runner/Info.plist`

**Add after line 76:**
```xml
<key>FlutterDeepLinkingEnabled</key>
<false/>
```

**Rationale:** Prevents Flutter's default router from intercepting OAuth callback before Supabase can handle it.

### Step 5: Verify Supabase Dashboard URLs

**Login to Supabase Dashboard:**
https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/url-configuration

**Verify Current Settings:**
- [ ] Site URL: `com.hub4apps.gitawisdom://`
- [ ] Redirect URLs: `com.hub4apps.gitawisdom://login-callback`

**Alternative Configuration to Test:**
- Site URL: `com.hub4apps.gitawisdom://login-callback`
- Redirect URLs: `com.hub4apps.gitawisdom://login-callback`

### Step 6: Check for Multiple Navigator Keys

**Search for GlobalKey usage:**
```bash
cd /Users/nishantgupta/Documents/GitaGyan/OldWisdom
grep -r "GlobalKey<NavigatorState>" lib/
```

**Issue:** Multiple navigator keys can cause routing conflicts during deep link handling.

---

## Configuration URLs

### Supabase Dashboard URLs

1. **Project Overview:**
   ```
   https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt
   ```

2. **Authentication Settings:**
   ```
   https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/url-configuration
   ```

3. **Google Provider:**
   ```
   https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/providers
   ```

4. **Auth Users List:**
   ```
   https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/users
   ```

5. **Logs (Real-time):**
   ```
   https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/logs/explorer
   ```

### Google Cloud Console URLs

1. **Project Dashboard:**
   ```
   https://console.cloud.google.com/
   ```

2. **OAuth Credentials:**
   ```
   https://console.cloud.google.com/apis/credentials
   ```

3. **OAuth Consent Screen:**
   ```
   https://console.cloud.google.com/apis/credentials/consent
   ```

**Required Configuration:**
- Authorized redirect URIs must include:
  ```
  https://wlfwdtdtiedlcczfoslt.supabase.co/auth/v1/callback
  ```

### Apple Developer Console URLs

1. **Identifiers List:**
   ```
   https://developer.apple.com/account/resources/identifiers/list
   ```

2. **Services IDs (for Sign in with Apple):**
   ```
   https://developer.apple.com/account/resources/identifiers/list/serviceId
   ```

3. **Keys (for Sign in with Apple):**
   ```
   https://developer.apple.com/account/resources/authkeys/list
   ```

**Required Configuration:**
- Service ID: `com.hub4apps.gitawisdom.signin`
- Return URLs must include:
  ```
  https://wlfwdtdtiedlcczfoslt.supabase.co/auth/v1/callback
  ```
- Domains must include:
  ```
  wlfwdtdtiedlcczfoslt.supabase.co
  ```

---

## Code Implementation

### Key Files

#### 1. Authentication Service
**Path:** `lib/services/supabase_auth_service.dart`

**Google Sign-In (Lines 555-588):**
```dart
/// Sign in with Google using Supabase OAuth
Future<bool> signInWithGoogle() async {
  _setLoading(true);
  _clearError();

  try {
    // Google requires the Supabase HTTPS callback URL, not the app deep link
    // The deep link is handled automatically by Supabase after OAuth completes
    final result = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );

    if (result) {
      _clearError();
      debugPrint('✅ Google sign-in initiated');
      return true;
    }

    throw Exception('Failed to initiate Google sign-in');
  } on AuthException catch (e) {
    _error = _handleAuthException(e);
    debugPrint('❌ Google sign-in failed: ${e.message}');
    return false;
  } catch (e) {
    _error = 'Failed to sign in with Google. Please try again.';
    debugPrint('❌ Google sign-in error: $e');
    return false;
  } finally {
    _setLoading(false);
  }
}
```

**Apple Sign-In (Lines 590-623):**
```dart
/// Sign in with Apple using Supabase OAuth
Future<bool> signInWithApple() async {
  _setLoading(true);
  _clearError();

  try {
    // Apple requires the Supabase HTTPS callback URL, not the app deep link
    // The deep link is handled automatically by Supabase after OAuth completes
    final result = await _supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );

    if (result) {
      _clearError();
      debugPrint('✅ Apple sign-in initiated');
      return true;
    }

    throw Exception('Failed to initiate Apple sign-in');
  } on AuthException catch (e) {
    _error = _handleAuthException(e);
    debugPrint('❌ Apple sign-in failed: ${e.message}');
    return false;
  } catch (e) {
    _error = 'Failed to sign in with Apple. Please try again.';
    debugPrint('❌ Apple sign-in error: $e');
    return false;
  } finally {
    _setLoading(false);
  }
}
```

**Key Points:**
- NO `redirectTo` parameter (removed in recent fix)
- Uses `LaunchMode.externalApplication` to open browser
- Supabase SDK handles deep link automatically
- Auth state change triggers via listener

#### 2. App Router
**Path:** `lib/core/navigation/app_router.dart`

**Login Callback Route (Lines 28, 80-83):**
```dart
static const String loginCallback = '/login-callback';

// In generateRoute():
case loginCallback:
  // OAuth callback route - Supabase handles authentication
  // Just return to splash which will redirect based on auth state
  return MaterialPageRoute(builder: (_) => const SplashScreen());
```

**Issue:** May cause re-initialization. Consider returning loading screen instead.

#### 3. App Initializer
**Path:** `lib/core/app_initializer.dart`

**Supabase Initialization (Lines 63-67):**
```dart
await Supabase.initialize(
  url: Environment.supabaseUrl,
  anonKey: Environment.supabaseAnonKey,
);
```

**Missing:** No `authCallbackUrlHostname` parameter (doesn't exist in current SDK version).

#### 4. iOS Configuration
**Path:** `ios/Runner/Info.plist`

**Current URL Scheme (Lines 66-76):**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.hub4apps.gitawisdom.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.hub4apps.gitawisdom</string>
        </array>
    </dict>
</array>
```

**Potential Addition:**
```xml
<key>FlutterDeepLinkingEnabled</key>
<false/>
```

---

## Testing Checklist

### Pre-Test Setup
- [ ] Clean build: `flutter clean && flutter pub get`
- [ ] Verify Supabase URLs in dashboard
- [ ] Check Google OAuth credentials configured
- [ ] Check Apple OAuth credentials configured
- [ ] Enable verbose logging

### Test Cases

#### Test 1: Google OAuth - Fresh Start
1. [ ] Uninstall app completely from device
2. [ ] Reinstall app via `./scripts/run_dev.sh`
3. [ ] Launch app - should show auth screen
4. [ ] Tap "Sign in with Google"
5. [ ] Complete OAuth in browser
6. [ ] **Expected:** Return to app, navigate to home screen smoothly
7. [ ] **Actual:** _[Document what happens]_
8. [ ] **Screenshot:** _[If error occurs]_

#### Test 2: Apple OAuth - Fresh Start
1. [ ] Uninstall app completely from device
2. [ ] Reinstall app via `./scripts/run_dev.sh`
3. [ ] Launch app - should show auth screen
4. [ ] Tap "Sign in with Apple"
5. [ ] Complete OAuth in browser
6. [ ] **Expected:** Return to app, navigate to home screen smoothly
7. [ ] **Actual:** _[Document what happens]_
8. [ ] **Screenshot:** _[If error occurs]_

#### Test 3: Sign Out and Sign In Again
1. [ ] From home screen, navigate to More tab
2. [ ] Tap "Sign Out"
3. [ ] **Expected:** Return to auth screen
4. [ ] Tap "Sign in with Google"
5. [ ] **Expected:** Faster OAuth (already authenticated)
6. [ ] **Actual:** _[Document what happens]_

#### Test 4: Watch Logs During OAuth
```bash
# Run this command while testing
./scripts/run_dev.sh 00008030-000C0D1E0140802E 2>&1 | grep -E "(route|error|deeplink|auth|navigation)" -i
```

Look for:
- [ ] "handle deeplink uri" message
- [ ] "Auth state changed: AuthChangeEvent.signedIn"
- [ ] Any "route not found" errors
- [ ] Navigation events

#### Test 5: Network Request Inspection
1. [ ] Use Supabase Dashboard → Logs
2. [ ] Filter for authentication events
3. [ ] Verify OAuth callback reaches Supabase
4. [ ] Check for any error responses

---

## Recommended Next Steps

### Priority 1: Determine Exact Error Timing
**Action:** User should record screen during OAuth flow to capture:
- When does error screen appear?
- How long is it visible?
- What happens after error screen?

### Priority 2: Test Route Handler Fix
**Change:** Modify `/login-callback` route to return loading screen instead of SplashScreen
**File:** `lib/core/navigation/app_router.dart`
**Test:** Does this prevent re-initialization issues?

### Priority 3: Add iOS Deep Link Flag
**Change:** Add `<key>FlutterDeepLinkingEnabled</key><false/>` to Info.plist
**Test:** Does this prevent Flutter router from intercepting deep links?

### Priority 4: Verify Dashboard Configuration
**Action:** Double-check Supabase Dashboard URL configuration matches exactly:
- Site URL: `com.hub4apps.gitawisdom://`
- Redirect URLs: `com.hub4apps.gitawisdom://login-callback`

### Priority 5: Check for Navigation Conflicts
**Search:** Look for multiple navigation contexts or global keys that might conflict
**Test:** Ensure only one Navigator is active during deep link handling

---

## Contact & Support

### Supabase Support
- **Documentation:** https://supabase.com/docs/guides/auth/social-login/auth-google
- **Discord:** https://discord.supabase.com/
- **GitHub Issues:** https://github.com/supabase/supabase-flutter/issues

### Flutter Deep Linking Documentation
- **Official Guide:** https://docs.flutter.dev/ui/navigation/deep-linking
- **Supabase Flutter Integration:** https://supabase.com/docs/guides/getting-started/tutorials/with-flutter

### Debugging Resources
- **Stack Overflow Tag:** [supabase-flutter]
- **Common OAuth Issues:** https://github.com/supabase/supabase-flutter/issues?q=is%3Aissue+oauth

---

## Appendix: Log Analysis

### Successful OAuth Flow (from actual logs)

```
flutter: ✅ Google sign-in initiated
flutter: 🔋 Orb animations paused (app backgrounded) - saving battery
flutter: 🎵 App lifecycle changed to: AppLifecycleState.paused
flutter: 🎵 Pausing music due to app backgrounding
flutter: supabase.supabase_flutter: INFO: handle deeplink uri
flutter: 🏠 App resumed - resetting to home screen
flutter: 📋 Tab switched to 0 (Home)
flutter: 🔋 Orb animations resumed (app foregrounded)
flutter: 🔐 Auth state changed: AuthChangeEvent.signedIn
flutter: 🔐 Auth state changed: AuthChangeEvent.signedIn
flutter: 🎵 App lifecycle changed to: AppLifecycleState.resumed
```

**Analysis:**
- OAuth initiates successfully
- App backgrounds for OAuth (expected)
- Supabase SDK receives and handles deep link
- Auth state changes to `signedIn` (twice - likely initial + token refresh)
- App resumes and navigates to home
- **No routing errors in logs**

### Questions to Investigate

1. **Is error screen showing before logs capture it?**
   - Add logging to `AppRouter.generateRoute()` to catch all route requests

2. **Is there a visual flash that looks like an error?**
   - Could be splash screen reloading briefly

3. **Is error from a previous build/test?**
   - User may have old screenshots mixed with new tests

4. **Platform differences?**
   - Does error only occur on iOS? Or also Android?

---

## Document Version

- **Version:** 1.0
- **Created:** October 13, 2025
- **Last Updated:** October 13, 2025
- **Author:** Development Team
- **Review Status:** Pending external review

---

**END OF DOCUMENT**
