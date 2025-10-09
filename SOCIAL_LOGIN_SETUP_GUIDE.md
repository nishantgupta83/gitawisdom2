# Social Login Setup Guide for GitaWisdom
## Production-Ready Apple & Facebook Authentication

**Last Updated**: January 6, 2025
**Version**: 2.3.0+24

---

## ✅ What's Already Configured

### Code Implementation
- ✅ `SupabaseAuthService` with `signInWithApple()` and `signInWithFacebook()` methods
- ✅ `SocialAuthButtons` widget with Apple, Facebook, and Google buttons
- ✅ OAuth packages installed (`sign_in_with_apple: ^6.1.3`, `flutter_facebook_auth: ^7.1.1`)
- ✅ Deep link URL scheme configured (`com.hub4apps.gitawisdom://login-callback`)
- ✅ Test accounts section removed from auth screen

### What You Need to Do

---

## 1️⃣ Apple Sign-In Setup (REQUIRED for iOS App Store)

### Step 1: Enable Sign in with Apple in Xcode

1. **Open Xcode project**:
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. **Select Runner target** → **Signing & Capabilities** tab

3. **Click "+ Capability"** → Search for **"Sign in with Apple"**

4. **Add the capability** (it will automatically configure with your Apple Developer account)

5. **Verify**: You should see "Sign in with Apple" listed under Capabilities

### Step 2: Configure Supabase Dashboard for Apple OAuth

1. **Go to Supabase Dashboard**: https://supabase.com/dashboard/project/jnzzwknjzigvupwfzfhq

2. **Navigate to**: Authentication → Providers → Apple

3. **Enable Apple provider**

4. **Get Apple credentials** (requires Apple Developer Account):

   **4a. Create Service ID**:
   - Go to: https://developer.apple.com/account/resources/identifiers/list/serviceId
   - Click **+** to create new Service ID
   - Description: `GitaWisdom Sign in with Apple`
   - Identifier: `com.hub4apps.gitawisdom.signin` (must be unique)
   - Enable **"Sign in with Apple"**
   - Click **Configure** next to Sign in with Apple
   - Primary App ID: Select your app's Bundle ID (`com.hub4apps.gitawisdom`)
   - Domains and Subdomains: `jnzzwknjzigvupwfzfhq.supabase.co`
   - Return URLs: `https://jnzzwknjzigvupwfzfhq.supabase.co/auth/v1/callback`
   - Save and Continue

   **4b. Create Key for Apple Sign In**:
   - Go to: https://developer.apple.com/account/resources/authkeys/list
   - Click **+** to create new key
   - Key Name: `GitaWisdom Apple Sign In Key`
   - Enable **"Sign in with Apple"**
   - Click **Configure** → Select Primary App ID (`com.hub4apps.gitawisdom`)
   - Click **Continue** → Click **Register**
   - **IMPORTANT**: Download the `.p8` file immediately (you can't download it again!)
   - Note the **Key ID** (e.g., `ABC123XYZ`)

5. **Configure Supabase with Apple credentials**:
   - **Services ID**: `com.hub4apps.gitawisdom.signin` (from step 4a)
   - **Key ID**: Your Key ID from step 4b
   - **Secret Key (Private Key)**: Paste contents of the `.p8` file
   - **Team ID**: Find this at https://developer.apple.com/account (top right corner)
   - **Redirect URL**: `https://jnzzwknjzigvupwfzfhq.supabase.co/auth/v1/callback`

6. **Save** the configuration

### Step 3: Test Apple Sign-In

```bash
# Build and run on your physical iPhone
./scripts/run_dev.sh <your-iphone-device-id>

# OR build production release
flutter build ipa --release \
  --dart-define=SUPABASE_URL=https://db.jnzzwknjzigvupwfzfhq.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<your-key> \
  --dart-define=APP_ENV=production
```

**Expected Flow**:
1. Tap Apple Sign-In button
2. iOS native Apple ID prompt appears
3. User authenticates with Face ID/Touch ID/Passcode
4. User chooses to share/hide email
5. App receives callback and creates Supabase session
6. User is redirected to home screen

---

## 2️⃣ Facebook Sign-In Setup

### Step 1: Create Facebook App

1. **Go to**: https://developers.facebook.com/apps

2. **Create App**:
   - App Type: **Consumer**
   - App Name: `GitaWisdom`
   - App Contact Email: Your email
   - Purpose: **Yourself or your own business**

3. **Add Facebook Login Product**:
   - From dashboard, click **Add Product**
   - Select **Facebook Login** → Click **Set Up**

4. **Configure Facebook Login Settings**:
   - Navigate to: Facebook Login → Settings
   - **Valid OAuth Redirect URIs**:
     ```
     https://jnzzwknjzigvupwfzfhq.supabase.co/auth/v1/callback
     ```
   - **Allowed Domains for the JavaScript SDK**: (leave empty for mobile)
   - Save changes

5. **Get Facebook App Credentials**:
   - Go to: Settings → Basic
   - **App ID**: Copy this (e.g., `1234567890123456`)
   - **App Secret**: Click **Show** → Copy this
   - **App Domains**: `jnzzwknjzigvupwfzfhq.supabase.co`

### Step 2: Configure iOS for Facebook Login

**Update Info.plist**:

```bash
cd ios/Runner
open Info.plist
```

Add the following entries inside `<dict>`:

```xml
<!-- Facebook Configuration -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fb<YOUR_FACEBOOK_APP_ID></string>
      <string>com.hub4apps.gitawisdom</string>
    </array>
  </dict>
</array>

<key>FacebookAppID</key>
<string><YOUR_FACEBOOK_APP_ID></string>

<key>FacebookClientToken</key>
<string><YOUR_FACEBOOK_CLIENT_TOKEN></string>

<key>FacebookDisplayName</key>
<string>GitaWisdom</string>

<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
  <string>fbauth2</string>
  <string>fbshareextension</string>
</array>
```

**Replace**:
- `<YOUR_FACEBOOK_APP_ID>` with your App ID from Step 1.5
- `<YOUR_FACEBOOK_CLIENT_TOKEN>` with your Client Token (Settings → Advanced → Security → Client Token)

### Step 3: Configure Supabase for Facebook OAuth

1. **Go to Supabase Dashboard**: Authentication → Providers → Facebook

2. **Enable Facebook provider**

3. **Configure**:
   - **Facebook client ID**: Your App ID from Step 1.5
   - **Facebook client secret**: Your App Secret from Step 1.5
   - **Redirect URL**: `https://jnzzwknjzigvupwfzfhq.supabase.co/auth/v1/callback`

4. **Save**

### Step 4: Test Facebook Sign-In

```bash
# Run on physical iPhone
./scripts/run_dev.sh <your-iphone-device-id>
```

**Expected Flow**:
1. Tap Facebook Sign-In button
2. Facebook OAuth web page opens in Safari/WebView
3. User logs in with Facebook credentials
4. User approves permissions
5. Callback redirects to app
6. App receives Facebook OAuth token
7. Supabase creates session
8. User redirected to home screen

---

## 3️⃣ Testing on Physical iPhone

### Prerequisites
1. ✅ iPhone connected to Mac via cable or WiFi
2. ✅ Xcode installed with your Apple Developer account signed in
3. ✅ iPhone added to your provisioning profile

### Get Your iPhone Device ID

```bash
# List connected devices
xcrun simctl list devices available | grep -i iphone

# OR use Flutter
flutter devices
```

**Example output**:
```
Nishant's iPhone (mobile) • 00008030-001234567890ABCD • ios • iOS 17.2.1
```

**Your device ID**: `00008030-001234567890ABCD`

### Build and Test

**Option 1: Development Build (Recommended for Testing)**
```bash
./scripts/run_dev.sh 00008030-001234567890ABCD
```

**Option 2: Production Build (For App Store Testing)**
```bash
# Build IPA
flutter build ipa --release \
  --dart-define=SUPABASE_URL=https://db.jnzzwknjzigvupwfzfhq.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key> \
  --dart-define=APP_ENV=production

# Install on iPhone via Xcode
open build/ios/archive/Runner.xcarchive
# In Xcode Organizer: Distribute App → Development → Select your iPhone
```

### Test Checklist

- [ ] **Apple Sign-In**:
  - [ ] Button appears with Apple icon
  - [ ] Tapping opens iOS native Apple ID prompt
  - [ ] Can authenticate with Face ID/Touch ID
  - [ ] Email sharing options work (Share/Hide)
  - [ ] Successful login redirects to home screen
  - [ ] User session persists after app restart

- [ ] **Facebook Sign-In**:
  - [ ] Button appears with Facebook icon
  - [ ] Tapping opens Facebook login page
  - [ ] Can log in with Facebook credentials
  - [ ] Permissions approval works
  - [ ] Callback redirects to app correctly
  - [ ] Session created in Supabase
  - [ ] User data synced correctly

- [ ] **Production Mode**:
  - [ ] No test accounts displayed
  - [ ] No debug logs in console
  - [ ] App feels production-ready
  - [ ] Performance is smooth

---

## 4️⃣ Troubleshooting

### Apple Sign-In Issues

**Error**: "Invalid client"
- **Fix**: Verify Service ID matches configuration in Supabase
- **Check**: Return URLs in Apple Developer console match Supabase callback URL

**Error**: "Unauthorized domain"
- **Fix**: Add `jnzzwknjzigvupwfzfhq.supabase.co` to Apple Service ID domains

**Error**: Sign-in button does nothing
- **Fix**: Check Xcode Capabilities has "Sign in with Apple" enabled
- **Check**: Device is running iOS 13+ (requirement for Apple Sign-In)

### Facebook Sign-In Issues

**Error**: "Can't Load URL"
- **Fix**: Verify `CFBundleURLSchemes` includes `fb<YOUR_APP_ID>`
- **Check**: Facebook App is in **Development** or **Live** mode (not Draft)

**Error**: "Invalid OAuth redirect URI"
- **Fix**: Add exact callback URL to Facebook Login Settings: `https://jnzzwknjzigvupwfzfhq.supabase.co/auth/v1/callback`

**Error**: "App Not Set Up"
- **Fix**: Complete Facebook App Review (required for production)
- **Check**: Facebook app has "Facebook Login" product added

### General OAuth Issues

**Error**: "Failed to complete authentication"
- **Fix**: Check Supabase logs (Dashboard → Logs → Auth Logs)
- **Verify**: Network connectivity on device
- **Test**: Try on WiFi instead of cellular

**Error**: App crashes after OAuth callback
- **Fix**: Verify deep link URL scheme is configured in Info.plist
- **Check**: No conflicting URL schemes in project

---

## 5️⃣ Production Deployment Checklist

Before submitting to App Store:

- [ ] Apple Sign-In fully configured and tested
- [ ] Facebook App approved and in **Live** mode
- [ ] All OAuth redirect URLs use production Supabase URL
- [ ] Deep link URL scheme configured correctly
- [ ] Test accounts section removed from code
- [ ] Privacy Policy URL updated in App Store Connect
- [ ] App Store screenshots show social login options
- [ ] App Review Notes mention social login providers used

---

## 6️⃣ Quick Reference

### Supabase OAuth Callback URL
```
https://jnzzwknjzigvupwfzfhq.supabase.co/auth/v1/callback
```

### Deep Link URL Scheme
```
com.hub4apps.gitawisdom://login-callback
```

### Bundle ID
```
com.hub4apps.gitawisdom
```

### Files Modified
- ✅ `lib/screens/modern_auth_screen.dart` - Removed test accounts
- ✅ `lib/services/supabase_auth_service.dart` - Social auth methods already implemented
- ✅ `lib/widgets/social_auth_buttons.dart` - UI buttons already implemented
- ⏳ `ios/Runner/Info.plist` - Needs Facebook configuration (see Step 2.2)
- ⏳ Xcode Capabilities - Needs Apple Sign-In capability (see Step 1.1)

---

## 📚 Additional Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth/social-login)
- [Apple Sign-In Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple)
- [Facebook Login for iOS](https://developers.facebook.com/docs/facebook-login/ios)
- [Flutter Sign in with Apple Package](https://pub.dev/packages/sign_in_with_apple)
- [Flutter Facebook Auth Package](https://pub.dev/packages/flutter_facebook_auth)

---

**Need Help?**
- Check Supabase Dashboard → Logs → Auth Logs for detailed error messages
- Test on iOS Simulator first, then physical device
- Use `flutter logs` to see real-time app logs

**Next Steps**:
1. Complete Apple Sign-In setup (Section 1)
2. Complete Facebook Sign-In setup (Section 2)
3. Test on your physical iPhone (Section 3)
4. Build production release when ready (Section 4)
