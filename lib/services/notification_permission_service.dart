// lib/services/notification_permission_service.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service to handle notification permissions for Android 13+ (API level 33+)
/// Required by Google Play compliance for apps targeting Android 13+
class NotificationPermissionService {
  static final NotificationPermissionService instance = NotificationPermissionService._();
  NotificationPermissionService._();

  bool _hasRequestedPermission = false;

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        return status.isGranted;
      }
      // iOS handles permissions automatically through system prompts
      return true;
    } catch (e) {
      debugPrint('⚠️ Error checking notification permission: $e');
      return false;
    }
  }

  /// Request notification permission if needed (Android 13+)
  /// Only requests once per app install to avoid annoying users
  Future<bool> requestPermissionIfNeeded() async {
    try {
      // Skip if already requested in this session
      if (_hasRequestedPermission) {
        debugPrint('🔔 Notification permission already requested this session');
        return await areNotificationsEnabled();
      }

      // Only request on Android
      if (!Platform.isAndroid) {
        debugPrint('🔔 Notification permissions not needed on iOS');
        return true;
      }

      final status = await Permission.notification.status;

      // If already granted or permanently denied, don't request again
      if (status.isGranted) {
        debugPrint('🔔 Notification permission already granted');
        _hasRequestedPermission = true;
        return true;
      }

      if (status.isPermanentlyDenied) {
        debugPrint('🔔 Notification permission permanently denied by user');
        _hasRequestedPermission = true;
        return false;
      }

      // Only request if permission hasn't been decided yet
      if (status.isDenied) {
        debugPrint('🔔 Requesting notification permission for Android 13+');
        final newStatus = await Permission.notification.request();
        _hasRequestedPermission = true;

        if (newStatus.isGranted) {
          debugPrint('✅ Notification permission granted');
          return true;
        } else if (newStatus.isPermanentlyDenied) {
          debugPrint('❌ Notification permission permanently denied');
          return false;
        } else {
          debugPrint('⚠️ Notification permission denied');
          return false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      _hasRequestedPermission = true; // Don't retry if there's an error
      return false;
    }
  }

  /// Open app settings if user wants to enable notifications
  Future<void> openSettings() async {
    try {
      await openAppSettings();
      debugPrint('📱 Opened app settings for notification permissions');
    } catch (e) {
      debugPrint('❌ Error opening app settings: $e');
    }
  }
}
