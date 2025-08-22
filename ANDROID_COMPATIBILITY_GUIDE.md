# Android Device Compatibility Guide for GitaWisdom

## Release Build Information

### Build Details
- **AAB File**: `build/app/outputs/bundle/release/app-release.aab` (64.3MB)
- **APK File**: `build/app/outputs/flutter-apk/app-release.apk` (75.2MB)
- **Version**: 1.7.0+7
- **Target SDK**: 34 (Android 14)
- **Minimum SDK**: 21 (Android 5.0)
  **Android Version**: 5.0 (API level 21) or higher

## Device Compatibility Requirements

### Minimum Requirements
- **Android Version**: 5.0 (API level 21) or higher
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 200MB free space
- **Internet**: Required for content sync
- **Touch Screen**: Required

### Supported Architectures
- ARM64 (arm64-v8a) - Primary modern devices
- ARMv7 (armeabi-v7a) - Older Android devices
- x86_64 - Emulators and Intel-based devices

### Features Used
- Internet connectivity (INTERNET permission)
- Network state monitoring (ACCESS_NETWORK_STATE permission)
- Wake lock for audio playback (WAKE_LOCK permission)
- Audio playback (background music)
- Local storage (Hive database)
- Material Design UI

## Google Play Store Configuration

### Device Support
```xml
<!-- Recommended device targeting in Google Play Console -->
<supports-screens 
    android:anyDensity="true"
    android:largeScreens="true"
    android:normalScreens="true"
    android:smallScreens="true"
    android:xlargeScreens="true" />

<uses-feature 
    android:name="android.hardware.touchscreen" 
    android:required="true" />
<uses-feature 
    android:name="android.hardware.wifi" 
    android:required="false" />
<uses-feature 
    android:name="android.hardware.telephony" 
    android:required="false" />
```

### Common Compatibility Issues & Solutions

#### Issue 1: "App not compatible with device"
**Cause**: Device doesn't meet minimum requirements
**Solution**: 
- Check Android version (must be 5.0+)
- Verify RAM availability
- Ensure sufficient storage

#### Issue 2: Installation fails
**Cause**: Missing device features or permissions
**Solution**:
- Ensure device has touchscreen
- Check internet connectivity
- Verify Google Play Services

#### Issue 3: App crashes on older devices
**Cause**: Hardware limitations
**Solution**:
- Consider lowering graphics quality
- Optimize memory usage
- Add compatibility checks

### Supported Device Categories
✅ **Fully Supported**:
- Smartphones (Android 8.0+)
- Tablets (Android 8.0+)
- Modern mid-range and flagship devices

⚠️ **Limited Support**:
- Android 5.0-7.1 devices (may have reduced performance)
- Devices with <2GB RAM (may experience slowdowns)
- Very old hardware (may not install)

❌ **Not Supported**:
- Android TV (not optimized)
- Wear OS (not compatible)
- Android Auto (not applicable)

## Troubleshooting for Users

### If app won't install from Play Store:
1. Check Android version: Settings → About Phone → Android Version
2. Free up storage space (need 200MB minimum)
3. Update Google Play Store app
4. Restart device and try again
5. Contact support with device details if still failing

### Alternative Installation:
If Play Store installation fails, users can:
1. Download APK directly (if provided)
2. Enable "Install from unknown sources"
3. Install APK manually

### Device Information to Collect:
When users report compatibility issues, collect:
- Device manufacturer and model
- Android version and API level
- Available RAM and storage
- Google Play Services version
- Error messages received

## Release Checklist

### Before Upload to Play Store:
- ✅ AAB file signed with release key
- ✅ Version code incremented
- ✅ Proguard rules optimized
- ✅ Permissions reviewed
- ✅ Compatibility tested on various devices
- ✅ Performance verified on low-end devices

### Google Play Console Settings:
1. **Device Categories**: Enable phones and tablets
2. **API Levels**: Set minimum to 21 (Android 5.0)
3. **Screen Sizes**: Support all sizes
4. **OpenGL ES**: Version 2.0 minimum
5. **RAM**: No specific requirement (let system decide)

## Monitoring & Analytics

### Key Metrics to Track:
- Install success rate by device type
- Crash rate by Android version
- Performance metrics on different RAM levels
- User retention by device category

### Common Issues to Monitor:
- Out of memory crashes
- Network connectivity issues
- Audio playback problems
- UI rendering on different screen sizes

## Support Contact
For device compatibility issues: support@hub4apps.com

Include device details:
- Model and manufacturer
- Android version
- Available RAM/storage
- Error messages or screenshots
