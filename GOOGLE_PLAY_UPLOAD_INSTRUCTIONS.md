# GitaWisdom - Google Play Upload Instructions
**Date:** October 9, 2025
**Version:** 2.3.1 (Build 25)
**Status:** ✅ READY FOR UPLOAD

---

## ✅ What Was Done

1. ✅ Generated NEW upload keystore: `gitawisdom-upload-2025.jks`
2. ✅ Exported certificate: `upload_certificate.pem`
3. ✅ Updated keystore configuration
4. ✅ Built production AAB (77.8MB)
5. ✅ Verified signature

---

## 📋 STEP-BY-STEP UPLOAD PROCESS

### Step 1: Register New Upload Key with Google Play (5 minutes)

Since you have **Google Play App Signing enabled**, you need to register your new upload certificate FIRST before uploading the AAB.

1. **Go to Google Play Console:**
   ```
   https://play.google.com/console
   ```

2. **Navigate to App Integrity:**
   ```
   Select GitaWisdom → Release → Setup → App Integrity → App signing
   ```

3. **Find "Upload key certificate" section** (scroll down on the page)

4. **Click "Change upload key"** or "Add upload key certificate"

5. **Upload the certificate file:**
   ```
   File location: /Users/nishantgupta/Documents/GitaGyan/OldWisdom/upload_certificate.pem
   ```

   **OR** you can copy/paste the certificate content:
   ```
   -----BEGIN CERTIFICATE-----
   MIIDgjCCAmqgAwIBAgIHbV9IoBt8wTANBgkqhkiG9w0BAQsFADBvMQswCQYDVQQG
   EwJVUzEQMA4GA1UECBMHVW5rbm93bjEQMA4GA1UEBxMHVW5rbm93bjERMA8GA1UE
   ChMISHViNEFwcHMxFDASBgNVBAsTC01vYmlsZSBBcHBzMRMwEQYDVQQDEwpHaXRh
   V2lzZG9tMCAXDTI1MTAwOTE1Mjc1NloYDzIwNTMwMjI0MTUyNzU2WjBvMQswCQYD
   VQQGEwJVUzEQMA4GA1UECBMHVW5rbm93bjEQMA4GA1UEBxMHVW5rbm93bjERMA8G
   A1UEChMISHViNEFwcHMxFDASBgNVBAsTC01vYmlsZSBBcHBzMRMwEQYDVQQDEwpH
   aXRhV2lzZG9tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwbQ/6XDS
   enL0F1VC1u6OMBiW24Vozlj9BfGneBBUYD35mIKtHMQ3FH5VqY9apxHSr2gPssXo
   PxevvmeoemfL+E4IgnAFhRtJyY+6UXmTV9kmgCPw85rounUwJipwUNUa+UeghMTd
   NVOPKsTn8prnvKycKRH/hyIeoZHU3gbgsTIQeDG6zxONEH9octwdfwwUL8FMuIg8
   rJ4Cm8Nvzz9KGcWHvO7EjDlBv3pWsl3wn4nempig6xJRx9QD/evYTtfFOQ5rsw9H
   4vaKaP5890HXHTs0WG0D+Gicq6lOp2S1yqQtfOdTsPdFK6/tLvfm0/IhPQi5lYOn
   gcqXh+qlDUg4pwIDAQABoyEwHzAdBgNVHQ4EFgQU72npVEBIsxflJDk0/I+kW4Dm
   1gIwDQYJKoZIhvcNAQELBQADggEBAAr3R8mWLyVT6Xjb8NiX4lPawc/NXd0cvD9V
   B500TQkExd7LhSRNDHutlu9hHN2KX6YTAOvGf+AVy1FWYiELX2dI2ATHi9vYDpj2
   VWC4tUOBblL5ilSqffB4yzqhb0tRNwhjJykYhoDA0yW9S1xVpF26hr9neMmUKqDf
   SqONTO27onySC8/nV2Me4Atr+6vVEiwEMhwhwvoIFtaJNenzUQaQiGxRcuN/h5Re
   o/3CjVIJupmb6wAfXK3dCZJeoBrcx8FKiGOFoV/jI+cQ5fLvWDFri5OGJJj14X7i
   aZF8kawSkFjdyQxDSKl2IDk6SqbfIMUU3jb3Xu4SkHY/3b7xes8=
   -----END CERTIFICATE-----
   ```

6. **Verify the fingerprints match:**

   **New Upload Key Fingerprints:**
   - **SHA-1:** `AA:8B:5A:E0:E8:18:F2:2D:86:B9:9B:14:28:2F:E8:39:26:87:BE:30`
   - **SHA-256:** `83:CB:16:BD:8D:8E:D1:C6:83:19:B8:32:B6:60:D5:F0:82:1B:CF:8B:04:DC:EA:45:BE:65:B9:FD:A9:13:6D:25`

   Make sure these match what Google Play shows after you upload the certificate.

7. **Click "Save" or "Confirm"**

✅ **Expected Result:** Google Play will show your new upload certificate registered and associated with your app signing key.

---

### Step 2: Upload the AAB (2 minutes)

**IMPORTANT:** Only do this AFTER Step 1 is complete!

1. **Go to Production Track:**
   ```
   Google Play Console → GitaWisdom → Release → Production
   ```

2. **Click "Create new release"**

3. **Upload the AAB file:**
   ```
   File location: /Users/nishantgupta/Documents/GitaGyan/OldWisdom/build/app/outputs/bundle/release/app-release.aab
   Size: 77.8MB
   ```

   **Drag and drop** the `app-release.aab` file into the upload area.

4. **Wait for processing** (usually 1-2 minutes)

   ✅ **Expected:** Upload successful, no signing errors

5. **Fill in "Release notes"** for version 2.3.1:

   ```
   Critical Bug Fixes:
   - Fixed chapters not loading on device
   - Resolved Google OAuth error display
   - Fixed text alignment in large font mode
   - Removed duplicate search indicators
   - Enabled always-on AI semantic search

   Enhanced Journal Experience:
   - Simplified emoji-only rating system
   - Mint gradient background for calming aesthetic
   - Removed categories for streamlined experience
   - Added haptic feedback

   Account Management:
   - Improved account section organization
   - Fixed account deletion functionality

   Technical Improvements:
   - Updated to production-ready configuration
   - Added iOS Privacy Manifest for App Store compliance
   ```

6. **Review and Submit:**
   - Verify app details are correct
   - Confirm version 2.3.1 (Build 25)
   - Click "Review release"
   - Click "Start rollout to Production"

---

## 🔍 Troubleshooting

### ❌ Error: "App Bundle is signed with the wrong key"

**Solution:** Make sure you completed **Step 1** (register upload certificate) BEFORE uploading the AAB.

### ❌ Error: "Certificate fingerprint doesn't match"

**Solution:** Double-check you uploaded the correct `upload_certificate.pem` file from this location:
```
/Users/nishantgupta/Documents/GitaGyan/OldWisdom/upload_certificate.pem
```

### ❌ Error: "Upload key already registered"

**Solution:** Google Play may have automatically accepted your new key. Try uploading the AAB directly (Step 2).

---

## 📂 Important Files & Passwords

**SAVE THESE SECURELY!**

### New Upload Keystore
```
Location: /Users/nishantgupta/gitawisdom-upload-2025.jks
Password: GitaWisdom2025
Key Alias: upload
Key Password: GitaWisdom2025
```

### Upload Certificate (for Google Play)
```
Location: /Users/nishantgupta/Documents/GitaGyan/OldWisdom/upload_certificate.pem
SHA-1: AA:8B:5A:E0:E8:18:F2:2D:86:B9:9B:14:28:2F:E8:39:26:87:BE:30
SHA-256: 83:CB:16:BD:8D:8E:D1:C6:83:19:B8:32:B6:60:D5:F0:82:1B:CF:8B:04:DC:EA:45:BE:65:B9:FD:A9:13:6D:25
```

### Production AAB
```
Location: /Users/nishantgupta/Documents/GitaGyan/OldWisdom/build/app/outputs/bundle/release/app-release.aab
Size: 77.8MB (81M on disk)
Version: 2.3.1 (Build 25)
```

---

## ⚠️ CRITICAL REMINDERS

1. **BACKUP THE KEYSTORE:**
   ```bash
   # Copy to secure cloud storage (Google Drive, Dropbox, etc.)
   cp /Users/nishantgupta/gitawisdom-upload-2025.jks ~/Dropbox/GitaWisdom-Backup/

   # Store password in password manager (1Password, LastPass, etc.)
   ```

2. **Never lose this keystore!** Without it, you won't be able to publish future updates.

3. **Store password securely:** Write it down and store in safe place + password manager.

4. **Test the upload:** After Google Play accepts the AAB, download and test the signed APK from Google Play Console.

---

## ✅ Success Checklist

- [ ] Registered new upload certificate in Google Play Console (Step 1)
- [ ] Verified certificate fingerprints match
- [ ] Uploaded AAB successfully (Step 2)
- [ ] Added release notes for version 2.3.1
- [ ] Submitted release for review
- [ ] Backed up keystore to secure location
- [ ] Saved password in password manager
- [ ] Tested download from Google Play Console

---

## 🎯 Next Steps After Upload

1. **Monitor Review Status:**
   - Check Play Console for review status (usually 1-3 days)
   - Address any policy violations if flagged

2. **Test the Release:**
   - Once approved, download from Play Store on test device
   - Verify all fixes are working
   - Check journal, search, and account features

3. **Monitor Crash Reports:**
   - Enable crash reporting in Play Console
   - Monitor user feedback in first 48 hours

---

## 📞 Support Resources

- **Google Play Console:** https://play.google.com/console
- **App Signing Help:** https://support.google.com/googleplay/android-developer/answer/9842756
- **Upload Troubleshooting:** https://support.google.com/googleplay/android-developer/answer/9844679

---

**Generated:** October 9, 2025
**App:** GitaWisdom v2.3.1 (Build 25)
**Status:** Ready for Google Play Store Upload
