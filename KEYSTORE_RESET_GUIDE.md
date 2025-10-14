# GitaWisdom Keystore Reset Guide

**Problem:** Lost password for original keystore `gitawisdom-release-key.jks`
**Google Play Expected SHA-1:** `09:4B:60:8C:38:1D:2F:8C:FF:27:2E:FC:89:A8:2D:C7:3A:05:48:1E`
**Current Keystore SHA-1:** `21:EA:C4:EA:66:B0:7F:D0:B8:81:B5:F1:A3:A2:74:32:3C:6C:E4:07` ❌

---

## ✅ Solution 1: Use Google Play App Signing (IF ENABLED)

### Step 1: Check if Already Enabled
Go to: **Play Console → Release → Setup → App Integrity → App signing**

If you see **"App signing by Google Play is enabled"** - YOU'RE GOOD! Proceed to Step 2.

### Step 2: Generate a NEW Upload Keystore
Since Google manages the final signing, we can create a brand new upload key:

```bash
# Generate new upload keystore
keytool -genkeypair -v \
  -storetype PKCS12 \
  -keystore ~/gitawisdom-upload-2025.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass 'GitaWisdom2025Upload!' \
  -keypass 'GitaWisdom2025Upload!' \
  -dname "CN=GitaWisdom, OU=Mobile Apps, O=Hub4Apps, L=Unknown, ST=Unknown, C=US"
```

### Step 3: Update Keystore Configuration
Edit `android/keystore.properties`:
```properties
storeFile=../../gitawisdom-upload-2025.jks
storePassword=GitaWisdom2025Upload!
keyAlias=upload
keyPassword=GitaWisdom2025Upload!
```

### Step 4: Register New Upload Key with Google Play

1. Export the certificate:
```bash
keytool -export -rfc \
  -keystore ~/gitawisdom-upload-2025.jks \
  -alias upload \
  -file upload_certificate.pem \
  -storepass 'GitaWisdom2025Upload!'
```

2. Upload to Play Console:
   - Go to: **App Integrity → App signing → Upload key certificate**
   - Click **"Change upload key"**
   - Upload `upload_certificate.pem`

3. Rebuild and upload:
```bash
cd /Users/nishantgupta/Documents/GitaGyan/OldWisdom
flutter clean
./scripts/build_production.sh aab
```

4. Upload the new AAB to Google Play - **IT WILL WORK!** ✅

---

## ❌ Solution 2: Request Signing Key Reset (IF APP SIGNING NOT ENABLED)

⚠️ **WARNING:** This process takes 3-5 business days and requires Google Play Support.

### Why This Is Needed:
Without Google Play App Signing, you MUST use the exact same keystore for all updates. If you've lost it, Google must reset your app's signing key.

### Steps to Request Reset:

1. **Go to Google Play Console**
   https://play.google.com/console

2. **Navigate to Help Center**
   Click the **?** icon (top right) → **Get help**

3. **Select Category:**
   - **App signing** → **Request signing key reset**

4. **Fill Out Form:**

   **Subject:**
   ```
   Request: Reset app signing key for GitaWisdom (lost original keystore)
   ```

   **Details:**
   ```
   Package Name: com.hub4apps.gitawisdom
   App Name: GitaWisdom
   Developer Account: [Your email]

   Reason: Lost original keystore file password and cannot recover it.

   Expected SHA-1 fingerprint: 09:4B:60:8C:38:1D:2F:8C:FF:27:2E:FC:89:A8:2D:C7:3A:05:48:1E

   I understand this will require all users to uninstall and reinstall the app,
   and I accept responsibility for this disruption.

   Requested action: Reset signing key and allow me to upload with a new keystore.
   ```

5. **Provide New Keystore Details:**

   Generate a new keystore:
   ```bash
   keytool -genkeypair -v \
     -storetype PKCS12 \
     -keystore ~/gitawisdom-new-release-2025.jks \
     -alias release \
     -keyalg RSA \
     -keysize 2048 \
     -validity 10000 \
     -storepass 'GitaWisdom2025NewKey!' \
     -keypass 'GitaWisdom2025NewKey!' \
     -dname "CN=GitaWisdom, OU=Mobile Apps, O=Hub4Apps, L=Unknown, ST=Unknown, C=US"
   ```

   Export certificate:
   ```bash
   keytool -export -rfc \
     -keystore ~/gitawisdom-new-release-2025.jks \
     -alias release \
     -file new_release_certificate.pem \
     -storepass 'GitaWisdom2025NewKey!'
   ```

   Attach `new_release_certificate.pem` to your support request.

6. **Wait for Google Response**
   - Typical response time: 3-5 business days
   - Google will review and approve/deny
   - If approved, they'll reset the signing key

7. **After Approval:**
   - Update `keystore.properties` with new keystore path
   - Rebuild AAB with new signing key
   - Upload to Google Play

   ⚠️ **IMPORTANT:** All existing users will need to **uninstall and reinstall** the app (this is unavoidable when changing signing keys without App Signing enabled).

---

## 📊 Comparison of Solutions

| Aspect | Solution 1 (App Signing) | Solution 2 (Key Reset) |
|--------|-------------------------|------------------------|
| **Time** | 10 minutes | 3-5 business days |
| **User Impact** | None (seamless) | Must uninstall/reinstall |
| **Difficulty** | Easy | Moderate |
| **Guaranteed** | Yes (if enabled) | Requires Google approval |
| **Future Safety** | Protected forever | Still at risk if lost again |

---

## 🎯 Recommended Action:

1. **First, check if Google Play App Signing is enabled**
   - If YES → Use Solution 1 (fast and easy!)
   - If NO → Use Solution 2 (slower but necessary)

2. **After resolving, enable App Signing** to prevent this issue in the future

3. **Store new keystore password securely:**
   - Use a password manager (1Password, LastPass)
   - Store backup keystore in secure cloud storage
   - Document password in secure location

---

## 📁 Keystore Inventory

**Found keystores:**
1. `/Users/nishantgupta/gitawisdom-release-key.jks` ⚠️ (Original, password unknown)
2. `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/android/gitawisdom-upload-key.jks` ❌ (Wrong SHA-1)
3. `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/android/gitawisdom-new-upload.jks` ⚠️ (Different password)

**Expected by Google Play:**
- SHA-1: `09:4B:60:8C:38:1D:2F:8C:FF:27:2E:FC:89:A8:2D:C7:3A:05:48:1E`

---

## 🔒 Future Prevention

1. **Enable Google Play App Signing** (if not already)
2. **Use a password manager** for keystore passwords
3. **Backup keystore files** to secure cloud storage
4. **Document keystore details** in project README
5. **Create keystore recovery procedure** documentation

---

**Next Step:** Check Play Console to see if App Signing is enabled (see CHECK_PLAY_APP_SIGNING.md)
