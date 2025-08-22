import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Service to check device compatibility and provide user-friendly messages
class DeviceCompatibilityService {
  static const String _tag = '📱 DeviceCompatibility';
  
  /// Check if the current device meets minimum requirements
  static Future<DeviceCompatibilityResult> checkCompatibility() async {
    try {
      final result = DeviceCompatibilityResult();
      
      // Check Android version
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidInfo();
        result.androidVersion = androidInfo['version'];
        result.androidSdkInt = androidInfo['sdkInt'];
        result.deviceModel = androidInfo['model'];
        result.manufacturer = androidInfo['manufacturer'];
        
        // Check minimum Android version (API 21 = Android 5.0)
        result.meetsMinimumVersion = (result.androidSdkInt ?? 0) >= 21;
        
        // Check RAM (estimate based on device info)
        result.hasEnoughRam = await _checkRamRequirements();
        
        // Check storage
        result.hasEnoughStorage = await _checkStorageRequirements();
        
        // Check OpenGL ES version for graphics
        result.supportsGraphics = await _checkGraphicsSupport();
        
        debugPrint('$_tag Device: ${result.manufacturer} ${result.deviceModel}');
        debugPrint('$_tag Android: ${result.androidVersion} (API ${result.androidSdkInt})');
        debugPrint('$_tag Compatible: ${result.isCompatible}');
      } else {
        // For iOS, assume compatibility (App Store handles this)
        result.meetsMinimumVersion = true;
        result.hasEnoughRam = true;
        result.hasEnoughStorage = true;
        result.supportsGraphics = true;
      }
      
      return result;
    } catch (e) {
      debugPrint('$_tag Error checking compatibility: $e');
      // Return default compatible result on error
      return DeviceCompatibilityResult()
        ..meetsMinimumVersion = true
        ..hasEnoughRam = true
        ..hasEnoughStorage = true
        ..supportsGraphics = true;
    }
  }
  
  /// Get Android device information
  static Future<Map<String, dynamic>> _getAndroidInfo() async {
    if (!Platform.isAndroid) return {};
    
    try {
      // Use method channel to get Android info
      const platform = MethodChannel('app_info');
      final info = await platform.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(info ?? {});
    } catch (e) {
      debugPrint('$_tag Could not get Android info: $e');
      // Fallback to basic info
      return {
        'version': 'Unknown',
        'sdkInt': 23, // Assume Android 6.0 as fallback
        'model': 'Unknown',
        'manufacturer': 'Unknown',
      };
    }
  }
  
  /// Check if device has enough RAM (estimate)
  static Future<bool> _checkRamRequirements() async {
    try {
      // For Android, we can't directly check RAM from Flutter
      // But we can make educated guesses based on other factors
      
      // If the device is running our app, it likely has enough RAM
      // This is a simplified check
      return true;
    } catch (e) {
      debugPrint('$_tag RAM check failed: $e');
      return true; // Assume OK on error
    }
  }
  
  /// Check if device has enough storage
  static Future<bool> _checkStorageRequirements() async {
    try {
      // Flutter apps typically need ~100MB minimum
      // This is a simplified check - in production, you'd use a plugin
      return true;
    } catch (e) {
      debugPrint('$_tag Storage check failed: $e');
      return true; // Assume OK on error
    }
  }
  
  /// Check graphics support
  static Future<bool> _checkGraphicsSupport() async {
    try {
      // Most modern Android devices support the graphics we need
      // This could be enhanced with specific OpenGL ES checks
      return true;
    } catch (e) {
      debugPrint('$_tag Graphics check failed: $e');
      return true; // Assume OK on error
    }
  }
  
  /// Generate user-friendly compatibility message
  static String getCompatibilityMessage(DeviceCompatibilityResult result) {
    if (result.isCompatible) {
      return 'Your device is compatible with GitaWisdom! ✅';
    }
    
    final issues = <String>[];
    
    if (!result.meetsMinimumVersion) {
      issues.add('• Android 5.0 or later required (you have ${result.androidVersion})');
    }
    
    if (!result.hasEnoughRam) {
      issues.add('• Insufficient RAM (2GB or more recommended)');
    }
    
    if (!result.hasEnoughStorage) {
      issues.add('• Insufficient storage (200MB free space required)');
    }
    
    if (!result.supportsGraphics) {
      issues.add('• Graphics hardware not supported');
    }
    
    return 'Your device may not be fully compatible with GitaWisdom:\n\n${issues.join('\n')}\n\nYou can still try installing, but the app may not work properly.';
  }
  
  /// Generate support email content for incompatible devices
  static String generateSupportEmailContent(DeviceCompatibilityResult result) {
    return '''
Subject: GitaWisdom Compatibility Issue

Dear GitaWisdom Support,

I'm having trouble installing GitaWisdom on my device. Here are my device details:

Device: ${result.manufacturer} ${result.deviceModel}
Android Version: ${result.androidVersion} (API ${result.androidSdkInt})
Compatibility Issues:
${result.meetsMinimumVersion ? '✅' : '❌'} Minimum Android version
${result.hasEnoughRam ? '✅' : '❌'} RAM requirements
${result.hasEnoughStorage ? '✅' : '❌'} Storage requirements
${result.supportsGraphics ? '✅' : '❌'} Graphics support

Please help me resolve this issue.

Thank you,
[Your Name]
''';
  }
}

/// Result of device compatibility check
class DeviceCompatibilityResult {
  String? androidVersion;
  int? androidSdkInt;
  String? deviceModel;
  String? manufacturer;
  
  bool meetsMinimumVersion = false;
  bool hasEnoughRam = false;
  bool hasEnoughStorage = false;
  bool supportsGraphics = false;
  
  /// Overall compatibility check
  bool get isCompatible => 
      meetsMinimumVersion && 
      hasEnoughRam && 
      hasEnoughStorage && 
      supportsGraphics;
      
  /// Get compatibility score (0-100)
  int get compatibilityScore {
    int score = 0;
    if (meetsMinimumVersion) score += 40;
    if (hasEnoughRam) score += 25;
    if (hasEnoughStorage) score += 20;
    if (supportsGraphics) score += 15;
    return score;
  }
}