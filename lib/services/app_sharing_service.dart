// lib/services/app_sharing_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for sharing the app with proper store links
/// 
/// Handles platform-specific store URLs and provides fallbacks
/// for development and testing scenarios.
class AppSharingService {
  // Singleton pattern
  static final AppSharingService _instance = AppSharingService._internal();
  factory AppSharingService() => _instance;
  AppSharingService._internal();
  
  /// Store URLs - UPDATE THESE AFTER PUBLISHING! 🚨
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.hub4apps.gitawisdom';
  static const String _appStoreUrl = 'https://apps.apple.com/app/gitawisdom/id[YOUR_APP_ID]'; // Update with actual App Store ID
  
  /// Fallback website URL
  static const String _websiteUrl = 'https://hub4apps.com';
  
  /// Development/testing URLs (used when stores aren't available yet)
  static const String _devPlayStoreUrl = 'https://play.google.com/store/search?q=gitawisdom&c=apps';
  static const String _devAppStoreUrl = 'https://apps.apple.com/search?term=gitawisdom';
  
  /// App information
  static const String _appName = 'GitaWisdom';
  static const String _appDescription = 'Ancient wisdom for modern life - Experience the timeless teachings of the Bhagavad Gita applied to contemporary situations.';
  
  /// Check if we're in a development/testing environment
  bool get _isDevelopment => kDebugMode;
  
  /// Get the appropriate store URL based on platform and environment
  String _getStoreUrl() {
    if (Platform.isAndroid) {
      return _isDevelopment ? _devPlayStoreUrl : _playStoreUrl;
    } else if (Platform.isIOS) {
      return _isDevelopment ? _devAppStoreUrl : _appStoreUrl;
    } else {
      // Web or other platforms - fallback to website
      return _websiteUrl;
    }
  }
  
  /// Get platform-specific store name
  String _getStoreName() {
    if (Platform.isAndroid) {
      return 'Play Store';
    } else if (Platform.isIOS) {
      return 'App Store';
    } else {
      return 'our website';
    }
  }
  
  /// Share the app with friends
  /// 
  /// [context] - Optional context for additional customization
  /// [customMessage] - Optional custom message to include
  Future<void> shareApp({String? customMessage}) async {
    final storeUrl = _getStoreUrl();
    final storeName = _getStoreName();
    
    final message = customMessage ?? _buildDefaultShareMessage(storeName);
    final fullMessage = '$message\n\n$storeUrl';
    
    try {
      await Share.share(
        fullMessage,
        subject: '$_appName – Your Daily Spiritual Guide',
      );
      
      debugPrint('📤 Shared app: $storeName');
    } catch (e) {
      debugPrint('❌ Error sharing app: $e');
      // Fallback: try to open the URL directly
      await _openStoreDirectly();
    }
  }
  
  /// Share a specific feature or content
  /// 
  /// [featureName] - Name of the feature being shared
  /// [content] - Specific content to share
  Future<void> shareFeature(String featureName, String content) async {
    final storeUrl = _getStoreUrl();
    final message = '''
$content

Discover more wisdom with $_appName - $featureName and 18 Gita chapters with modern applications.

Download: $storeUrl''';
    
    try {
      await Share.share(
        message,
        subject: '$_appName – $featureName',
      );
      
      debugPrint('📤 Shared feature: $featureName');
    } catch (e) {
      debugPrint('❌ Error sharing feature: $e');
    }
  }
  
  /// Share a specific scenario with heart vs duty guidance and wisdom steps
  Future<void> shareScenario(String scenarioTitle, String heartResponse, String dutyResponse, String wisdom, {List<String>? actionSteps}) async {
    String message = '''
🎭 Modern Dilemma: $scenarioTitle

❤️ Heart says: $heartResponse

⚖️ Duty demands: $dutyResponse

📖 Ancient wisdom: $wisdom''';

    // Add wisdom steps if available
    if (actionSteps != null && actionSteps.isNotEmpty) {
      message += '\n\n🔮 Wisdom Steps:';
      for (int i = 0; i < actionSteps.length; i++) {
        message += '\n${i + 1}. ${actionSteps[i]}';
      }
    }

    message += '\n\nExplore more scenarios and find guidance with $_appName.';
    
    await shareFeature('Heart vs Duty Guidance', message);
  }
  
  /// Share a Gita verse
  Future<void> shareVerse(String verseText, String chapter, String verseNumber) async {
    final message = '''
📜 Daily Wisdom from Bhagavad Gita

Chapter $chapter, Verse $verseNumber:
"$verseText"

Find daily inspiration and 700+ verses with $_appName.''';
    
    await shareFeature('Daily Verses', message);
  }
  
  /// Open store directly (fallback method)
  Future<void> _openStoreDirectly() async {
    final storeUrl = _getStoreUrl();
    
    try {
      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('🔗 Opened store directly: $storeUrl');
      } else {
        debugPrint('❌ Cannot launch store URL: $storeUrl');
      }
    } catch (e) {
      debugPrint('❌ Error opening store: $e');
    }
  }
  
  /// Build the default share message
  String _buildDefaultShareMessage(String storeName) {
    if (_isDevelopment) {
      return '''
Discover $_appName – Ancient Wisdom for Modern Life

Experience the timeless teachings of the Bhagavad Gita applied to contemporary situations.

✨ Features:
• Heart vs Duty guidance for real-life dilemmas
• 18 complete Gita chapters with modern applications  
• Daily verses for inspiration

🔍 Search for "$_appName" on the $storeName (Coming Soon!)''';
    } else {
      return '''
Discover $_appName – Ancient Wisdom for Modern Life

$_appDescription

✨ Features:
• Heart vs Duty guidance for real-life dilemmas
• 18 complete Gita chapters with modern applications  
• Daily verses for inspiration

Download now on the $storeName:''';
    }
  }
  
  /// Get share analytics (for future implementation)
  Map<String, dynamic> getShareAnalytics() {
    return {
      'platform': Platform.operatingSystem,
      'store_url': _getStoreUrl(),
      'is_development': _isDevelopment,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// Validate store URLs (for testing)
  Future<bool> validateStoreUrls() async {
    final playStoreValid = await _isUrlValid(_playStoreUrl);
    final appStoreValid = await _isUrlValid(_appStoreUrl);
    
    debugPrint('🔍 Store URL validation:');
    debugPrint('   Play Store: ${playStoreValid ? "✅" : "❌"} $_playStoreUrl');
    debugPrint('   App Store: ${appStoreValid ? "✅" : "❌"} $_appStoreUrl');
    
    return playStoreValid && appStoreValid;
  }
  
  /// Check if a URL is valid (basic check)
  Future<bool> _isUrlValid(String url) async {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'https' || uri.scheme == 'http');
    } catch (e) {
      return false;
    }
  }
  
  /// Update store URLs (call this after publishing)
  /// 
  /// This method is for future use when you want to update URLs dynamically
  static void updateStoreUrls({
    String? playStoreUrl,
    String? appStoreUrl,
  }) {
    // In a real app, you might store these in shared preferences
    // or fetch them from a remote config
    debugPrint('📝 Store URLs would be updated:');
    if (playStoreUrl != null) debugPrint('   Play Store: $playStoreUrl');
    if (appStoreUrl != null) debugPrint('   App Store: $appStoreUrl');
  }
}