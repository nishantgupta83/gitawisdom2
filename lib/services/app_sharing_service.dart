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
  
  /// Store URLs
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.hub4apps.gitawisdom';
  static const String _appStoreUrl = 'https://apps.apple.com'; // App Store search until published

  /// Fallback website URL
  static const String _websiteUrl = 'https://hub4apps.com';

  /// Development/testing URLs
  static const String _devPlayStoreUrl = 'https://play.google.com/store/apps/details?id=com.hub4apps.gitawisdom';
  static const String _devAppStoreUrl = 'https://apps.apple.com';
  
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
      return _websiteUrl;
    }
  }
  
  /// Share the app with friends
  Future<void> shareApp({String? customMessage}) async {
    final message = customMessage ?? _buildDefaultShareMessage();
    final storeLink = _isDevelopment ? _devPlayStoreUrl : _playStoreUrl;

    try {
      await Share.share(
        '$message\n\n📱 Download GitaWisdom:\n$storeLink',
        subject: '$_appName – Your Daily Spiritual Guide',
      );
      debugPrint('📤 Shared app link');
    } catch (e) {
      debugPrint('❌ Error sharing app: $e');
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

''';

    // Add guidance steps if available
    if (actionSteps != null && actionSteps.isNotEmpty) {
      message += '\n\n🔮 Guidance Steps:';
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
📜 Daily Guidance from Bhagavad Gita

Chapter $chapter, Verse $verseNumber:
"$verseText"

Find daily inspiration and 700+ verses with $_appName.''';

    await shareFeature('Daily Verses', message);
  }

  /// Share content directly to WhatsApp
  ///
  /// [message] - The message to share on WhatsApp
  /// [phoneNumber] - Optional phone number to send to specific contact
  Future<bool> shareToWhatsApp(String message, {String? phoneNumber}) async {
    try {
      // Encode the message for URL
      final encodedMessage = Uri.encodeComponent(message);

      String whatsappUrl;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Share to specific contact
        final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
        whatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';
      } else {
        // Open WhatsApp with message (user can choose contact)
        whatsappUrl = 'https://wa.me/?text=$encodedMessage';
      }

      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('📱 Shared to WhatsApp successfully');
        return true;
      } else {
        debugPrint('❌ WhatsApp not installed or URL cannot be launched');
        // Fallback to regular sharing
        await Share.share(message, subject: '$_appName - Shared via WhatsApp');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sharing to WhatsApp: $e');
      // Fallback to regular sharing
      try {
        await Share.share(message, subject: '$_appName - Shared via WhatsApp');
        return false;
      } catch (shareError) {
        debugPrint('❌ Fallback sharing also failed: $shareError');
        return false;
      }
    }
  }

  /// Share scenario to WhatsApp with formatted message
  Future<bool> shareScenarioToWhatsApp(String scenarioTitle, String heartResponse, String dutyResponse, String wisdom, {List<String>? actionSteps}) async {
    String message = '''🎭 *GitaWisdom Daily Dilemma*

*Situation:* $scenarioTitle

❤️ *Heart says:* $heartResponse

⚖️ *Duty demands:* $dutyResponse

🔮 *Ancient Wisdom:* $wisdom''';

    // Add guidance steps if available
    if (actionSteps != null && actionSteps.isNotEmpty) {
      message += '\n\n*Guidance Steps:*';
      for (int i = 0; i < actionSteps.length; i++) {
        message += '\n${i + 1}. ${actionSteps[i]}';
      }
    }

    message += '\n\n✨ _Find more wisdom for modern life with GitaWisdom app_';
    message += '\n${_getStoreUrl()}';

    return await shareToWhatsApp(message);
  }

  /// Share verse to WhatsApp with formatted message
  Future<bool> shareVerseToWhatsApp(String verseText, String chapter, String verseNumber, {String? translation}) async {
    String message = '''📜 *Daily Wisdom from Bhagavad Gita*

*Chapter $chapter, Verse $verseNumber:*
"$verseText"''';

    if (translation != null && translation.isNotEmpty) {
      message += '\n\n*Meaning:* $translation';
    }

    message += '\n\n✨ _Get daily inspiration with 700+ verses on GitaWisdom_';
    message += '\n${_getStoreUrl()}';

    return await shareToWhatsApp(message);
  }

  /// Share chapter summary to WhatsApp
  Future<bool> shareChapterToWhatsApp(String chapterTitle, String summary, int chapterNumber) async {
    String message = '''📖 *Bhagavad Gita Chapter $chapterNumber*

*$chapterTitle*

$summary

✨ _Explore all 18 chapters with modern applications on GitaWisdom_
${_getStoreUrl()}''';

    return await shareToWhatsApp(message);
  }

  /// Check if WhatsApp is installed and available
  Future<bool> isWhatsAppAvailable() async {
    try {
      final uri = Uri.parse('https://wa.me/');
      return await canLaunchUrl(uri);
    } catch (e) {
      debugPrint('❌ Error checking WhatsApp availability: $e');
      return false;
    }
  }

  /// Show WhatsApp sharing options (contact picker would be implemented in UI)
  /// This is a helper method that apps can use to show sharing options
  Future<void> showWhatsAppShareDialog({
    required String message,
    required Function(bool success) onComplete,
  }) async {
    try {
      final success = await shareToWhatsApp(message);
      onComplete(success);
    } catch (e) {
      debugPrint('❌ WhatsApp share dialog error: $e');
      onComplete(false);
    }
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
  String _buildDefaultShareMessage() {
    return '''Discover $_appName – Ancient Wisdom for Modern Life

$_appDescription

✨ Features:
• Heart vs Duty guidance for real-life dilemmas
• 18 complete Gita chapters with modern applications
• Daily verses for inspiration''';
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