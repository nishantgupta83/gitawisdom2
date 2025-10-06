# Email Verification Setup Guide

## Problem
Email verification links from Supabase point to `localhost:3000`, which doesn't work on mobile devices.

## Solution Options

### Option 1: Disable Email Verification (Quickest for Testing)

**Best for:** Development and testing phase

**Steps:**
1. Go to https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/providers
2. Scroll to **"Email Auth"** section
3. **Uncheck** "Enable email confirmations"
4. Click **Save**

**Result:** Users can sign up and use the app immediately without email verification.

---

### Option 2: Configure Deep Linking (Production-Ready)

**Best for:** Production release on App Store/Play Store

#### Step 1: Configure Supabase Redirect URLs

1. Go to https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/url-configuration
2. Under **"Redirect URLs"**, add:
   ```
   com.hub4apps.gitawisdom://login-callback
   ```
3. Click **Save**

#### Step 2: Code Changes (Already Applied)

✅ Updated `lib/services/supabase_auth_service.dart` to include `emailRedirectTo`:

```dart
final response = await _supabase.auth.signUp(
  email: email.toLowerCase().trim(),
  password: password,
  data: {'name': name},
  emailRedirectTo: 'com.hub4apps.gitawisdom://login-callback', // ✅ Added
);
```

#### Step 3: Deep Link Handling (Already Configured)

Your app already has deep linking configured in:
- **iOS:** `ios/Runner/Info.plist` with URL scheme `gitawisdom`
- **Android:** `android/app/src/main/AndroidManifest.xml` with intent filters

The deep link pattern: `com.hub4apps.gitawisdom://login-callback`

---

## End-to-End User Flow

### Current Flow (With Email Verification Enabled):

1. **User signs up** in the app with email & password
2. **Supabase sends** verification email
3. **User clicks** "Confirm your mail" link in email
4. **Link redirects** to configured URL (now: `com.hub4apps.gitawisdom://login-callback`)
5. **App intercepts** deep link and opens
6. **Supabase verifies** email automatically
7. **User can now** sign in with verified account

### Simplified Flow (With Email Verification Disabled):

1. **User signs up** in the app with email & password
2. **Account created** immediately
3. **User can use** the app right away (no email verification needed)

---

## Current Status

### ✅ Code Fixed:
- Added `emailRedirectTo` parameter to signup method
- Deep linking already configured for both iOS and Android

### ⏳ Supabase Configuration Required:

**Choose ONE option:**

#### For Development/Testing:
- Go to Supabase Dashboard → Auth → Providers
- Disable email confirmations
- Users can test immediately

#### For Production:
- Go to Supabase Dashboard → Auth → URL Configuration
- Add redirect URL: `com.hub4apps.gitawisdom://login-callback`
- Email verification will work properly on mobile devices

---

## Recommended Approach

### For Now (Testing):
✅ **Disable email verification** in Supabase Dashboard

### Before App Store/Play Store Release:
✅ **Enable email verification** again
✅ **Add redirect URL** to Supabase
✅ **Test deep linking** on physical devices

---

## Troubleshooting

### Issue: "This site can't be reached - localhost:3000"
**Cause:** Email verification enabled but redirect URL not configured
**Fix:** Either disable email verification OR add redirect URL to Supabase

### Issue: Email link doesn't open the app
**Cause:** Deep link not properly registered with OS
**Fix:** Ensure app is installed and deep link scheme is in `Info.plist` (iOS) and `AndroidManifest.xml` (Android)

### Issue: User can't sign in after signup
**Cause:** Email not verified but verification required
**Fix:** Disable email verification in Supabase OR have user verify email first

---

## Next Steps

1. **Immediate:** Go to Supabase Dashboard and disable email confirmations
2. **Test:** Try signing up with a new email address
3. **Verify:** You should be able to use the app immediately
4. **Before Production:** Re-enable email verification and configure redirect URL

---

## Configuration URLs

- **Auth Providers:** https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/providers
- **URL Configuration:** https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/url-configuration
- **Email Templates:** https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/templates

---

## Deep Link Scheme

- **Scheme:** `com.hub4apps.gitawisdom`
- **Callback Path:** `://login-callback`
- **Full URL:** `com.hub4apps.gitawisdom://login-callback`

This matches your app's bundle ID: `com.hub4apps.gitawisdom`
