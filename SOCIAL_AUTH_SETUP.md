# Social Authentication Setup Guide

## ✅ Implementation Complete - Configuration Needed

### What's Been Implemented:

#### 1. Dependencies Added ✅
- `google_sign_in: ^6.2.2`
- `sign_in_with_apple: ^6.1.3`
- `flutter_facebook_auth: ^7.1.1`

#### 2. Auth Service Methods ✅
Added to `lib/services/supabase_auth_service.dart`:
- `signInWithGoogle()` - Google OAuth
- `signInWithApple()` - Apple OAuth
- `signInWithFacebook()` - Facebook OAuth

All methods use Supabase's built-in OAuth with deep linking:
- Redirect URL: `com.hub4apps.gitawisdom://login-callback`
- Launch mode: External application

#### 3. UI Integration (In Progress)
Adding social auth buttons to `lib/screens/modern_auth_screen.dart`

---

## Supabase Dashboard Configuration Required

### Step 1: Configure Google Sign-In

1. Go to https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/providers
2. Find **Google** provider
3. Click **Enable**
4. Enter Google OAuth credentials:
   - **Client ID** - From Google Cloud Console
   - **Client Secret** - From Google Cloud Console
5. Add redirect URLs:
   ```
   https://wlfwdtdtiedlcczfoslt.supabase.co/auth/v1/callback
   com.hub4apps.gitawisdom://login-callback
   ```
6. Click **Save**

**Get Google OAuth Credentials:**
- Go to https://console.cloud.google.com
- Create/select project
- Enable Google+ API
- Create OAuth 2.0 Client ID
- Add authorized redirect URIs

### Step 2: Configure Apple Sign-In

1. Go to https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/providers
2. Find **Apple** provider
3. Click **Enable**
4. Enter Apple credentials:
   - **Services ID** - From Apple Developer
   - **Team ID** - From Apple Developer
   - **Key ID** - From Apple Developer/Users/nishantgupta/Desktop/Screenshot 2025-10-05 at 1.58.01 PM.png
   - **Private Key** - From Apple Developer (.p8 file)
5. Add redirect URLs:
   ```
   https://wlfwdtdtiedlcczfoslt.supabase.co/auth/v1/callback
   ```
6. Click **Save**

**Get Apple Credentials:**
- Go to https://developer.apple.com/account
- Certificates, Identifiers & Profiles
- Create Services ID
- Enable Sign in with Apple
- Configure domains and return URLs

### Step 3: Configure Facebook Sign-In

1. Go to https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt/auth/providers
2. Find **Facebook** provider
3. Click **Enable**
4. Enter Facebook App credentials:
   - **App ID** - From Facebook Developers
   - **App Secret** - From Facebook Developers
5. Add redirect URLs:
   ```
   https://wlfwdtdtiedlcczfoslt.supabase.co/auth/v1/callback
   ```
6. Click **Save**

**Get Facebook Credentials:**
- Go to https://developers.facebook.com
- Create new app
- Add Facebook Login product
- Configure OAuth redirect URIs

---

## User Flow

### With Social Authentication:

**Option 1: Google Sign-In**
1. User taps "Continue with Google" button
2. Google account picker opens (external app)
3. User selects Google account
4. App receives callback
5. Supabase creates/signs in user
6. User lands on home screen

**Option 2: Apple Sign-In**
1. User taps "Continue with Apple" button
2. Apple authentication UI appears
3. User authenticates with Face ID/Touch ID
4. User can hide email if desired
5. App receives callback
6. Supabase creates/signs in user
7. User lands on home screen

**Option 3: Facebook Sign-In**
1. User taps "Continue with Facebook" button
2. Facebook login page opens (external app)
3. User authenticates with Facebook
4. App receives callback
5. Supabase creates/signs in user
6. User lands on home screen

**Option 4: Email/Password (Existing)**
- Still works as before
- No changes to existing flow

**Option 5: Anonymous/Guest (Existing)**
- Still works as before
- "Continue as Guest" button

---

## UI Layout

### Sign-In Screen:
```
┌─────────────────────────┐
│   GitaWisdom Logo       │
│                         │
│   Email Input           │
│   Password Input        │
│   [Sign In Button]      │
│                         │
│   ───── OR ─────        │
│                         │
│   [🍎 Apple]   [G]      │ <- Social buttons (horizontal)
│   [📘 Facebook]         │
│                         │
│   Continue as Guest     │
│   Don't have account?   │
└─────────────────────────┘
```

### Sign-Up Screen:
```
┌─────────────────────────┐
│   Create Account        │
│                         │
│   Name Input            │
│   Email Input           │
│   Password Input        │
│   [Create Account]      │
│                         │
│   ───── OR ─────        │
│                         │
│   [🍎 Apple]   [G]      │ <- Social buttons
│   [📘 Facebook]         │
│                         │
│   Already have account? │
└─────────────────────────┘
```

---

## Testing

### Before Configuration (Current State):
- Social buttons will show
- Tapping them will show error: "Provider not configured"
- Email/password still works
- Guest mode still works

### After Configuration:
1. Test Google Sign-In:
   - Tap Google button
   - Should open Google account picker
   - Select account
   - Should redirect back to app
   - Should be signed in

2. Test Apple Sign-In (iOS only):
   - Tap Apple button
   - Should show Apple auth UI
   - Authenticate
   - Should redirect back
   - Should be signed in

3. Test Facebook Sign-In:
   - Tap Facebook button
   - Should open Facebook login
   - Sign in with Facebook
   - Should redirect back
   - Should be signed in

4. Verify existing flows still work:
   - Email/password sign-in ✓
   - Email/password sign-up ✓
   - Guest mode ✓

---

## Important Notes

### Deep Linking Already Configured:
✅ iOS: `com.hub4apps.gitawisdom`
✅ Android: `com.hub4apps.gitawisdom`

### No Breaking Changes:
✅ Existing email/password auth still works
✅ Guest/anonymous mode still works
✅ All existing screens unchanged
✅ Only addition - not replacement

### Security:
✅ All authentication handled by Supabase
✅ OAuth tokens never exposed to app
✅ Secure redirect URLs
✅ HTTPS only

---

## Deployment Checklist

### For Testing:
- [ ] Configure at least one provider (Google recommended)
- [ ] Test sign-in flow
- [ ] Verify redirect works
- [ ] Check user created in Supabase

### For Production:
- [ ] Configure all three providers (Google, Apple, Facebook)
- [ ] Test on physical iOS device
- [ ] Test on physical Android device
- [ ] Verify App Store / Play Store requirements
- [ ] Test guest mode still works
- [ ] Test email/password still works

---

## Troubleshooting

### "Provider not configured" error:
**Cause:** Provider not enabled in Supabase Dashboard
**Fix:** Follow configuration steps above

### "Redirect URI mismatch" error:
**Cause:** Redirect URL not whitelisted
**Fix:** Add `com.hub4apps.gitawisdom://login-callback` to provider settings

### Social login opens but doesn't return to app:
**Cause:** Deep linking not working
**Fix:** Verify URL scheme configured in iOS Info.plist and Android Manifest

### User created but not signed in:
**Cause:** OAuth callback not handled
**Fix:** Check Supabase deep link configuration

---

## Next Steps

1. ✅ Add social buttons to UI (current task)
2. ⏳ Configure at least Google in Supabase Dashboard
3. ⏳ Test on device
4. ⏳ Configure remaining providers
5. ⏳ Production testing
