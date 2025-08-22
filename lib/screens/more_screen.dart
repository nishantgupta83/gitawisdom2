/*
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../services/settings_service.dart';
import '../services/audio_service.dart';
import '../screens/about_screen.dart';
import '../screens/references_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final _settings = SettingsService();
  bool _musicOn = true;
  String _version = '';

  @override
  void initState() {
    super.initState();
    // Load app version
    PackageInfo.fromPlatform().then((info) {
      setState(() => _version = '${info.version}+${info.buildNumber}');
    });
    // Load music enabled state
    AudioService.instance.loadEnabled().then((v) {
      setState(() => _musicOn = v);
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $url')),
      );
    }
  }

  void _sendFeedback() {
  //  final uri = Uri(
  //    scheme: 'mailto',
  //    path: 'hub4app@gmail.com',
  //    queryParameters: { 'subject': 'OldWisdom || App Feedback' },
 //   );
 //   _launchUrl(uri.toString());

  final now = DateTime.now();
  final formattedDate = DateFormat('yyyyMMdd-HHmmss').format(now);

  final subject = Uri.encodeComponent('Gitawisdom || Feedback $formattedDate');
  final body = Uri.encodeComponent(
    'Hi Team,\n\nWould like to give feedback!\nn[Please add your feedback here...]\n\n\n' );

/*  final uri = Uri(
    scheme: 'mailto',
    path: 'hub4app@gmail.com',
    queryParameters: {
      'subject': subject,
      'body': body,
    },*/

   final url = 'mailto:support@hub4apps.com?subject=$subject&body=$body';

 //);

  launchUrl(Uri.parse(url));

 // _launchUrl(uri.toString());
  }

  Future<void> _clearCache() async {
    // Clear all settings
    final box = Hive.box(SettingsService.boxName);
    await box.clear();
    // Optionally clear other boxes if needed:
    // await Hive.box<Chapter>('chapters').clear();
    // await Hive.box<JournalEntry>('journal_entries').clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared')),
    );
    setState(() {});
  }

void _showWebsiteQr() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {                    // ← note this new name
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Visit our website',
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Your SVG QR code
            SvgPicture.asset(
              'assets/images/hub4apps_qr.svg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(sheetContext).pop(),  // ← use sheetContext!
              child: const Text('Close'),
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: ListView(
        children: [
          // Appearance section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Appearance', style: theme.textTheme.titleMedium),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _settings.isDarkMode,
            onChanged: (v) {
              setState(() => _settings.isDarkMode = v);
            },
          ),
          // Background Music
          SwitchListTile(
            title: const Text('Background Music'),
            subtitle: const Text('Enable ambient music in the background'),
            value: _musicOn,
            onChanged: (v) {
              setState(() => _musicOn = v);
              AudioService.instance.setEnabled(v);
            },
          ),
          // Font Size
          ListTile(
            title: const Text('Font Size'),
            trailing: DropdownButton<String>(
              value: _settings.fontSize,
              items: const [
                DropdownMenuItem(value: 'small', child: Text('Small')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'large', child: Text('Large')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _settings.fontSize = v);
              },
            ),
          ),

          // Extras section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Extras', style: theme.textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share This App'),
            onTap: () async => await AppSharingService().shareApp(),
          ),
        ListTile(
          leading: const Icon(Icons.qr_code),
          title: const Text('QR Code'),
          subtitle: const Text('Scan to open our website'),
          onTap: _showWebsiteQr,
        ),
    //      ListTile(
    //        leading: const Icon(Icons.star_rate),
    //        title: const Text('Rate & Review'),
    //        onTap: () => _launchUrl('https://your.app.store.link'),
    //      ),
    //      ListTile(
    //        leading: const Icon(Icons.clear_all),
    //        title: const Text('Clear Cache'),
    //        onTap: _clearCache,
    //      ),
          ListTile(
            title: const Text('App Version'),
            trailing: Text(_version, style: theme.textTheme.bodySmall),
          ),

          // Language section
     /*     Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Language', style: theme.textTheme.titleMedium),
          ),
         ListTile(
            title: const Text('App Language'),
            trailing: DropdownButton<String>(
              value: _settings.language,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
              ],
              onChanged: (newLang) {
                if (newLang != null) {
                  setState(() {
                    _settings.language = newLang;
                    // trigger localization reload if implemented
                  });
                }
              },
            ),
          ), */

          // Resources
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Resources', style: theme.textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('References'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReferencesScreen()),
            ),
          ),

          // Support & Legal
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Support & Legal', style: theme.textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            onTap: _sendFeedback,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => _launchUrl('https://hub4apps.com/privacy.html'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Terms of Service'),
            onTap: () => _launchUrl('https://hub4apps.com/terms.html'),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_sharing_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../screens/home_screen.dart';
import '../main.dart';

import '../services/settings_service.dart';
import '../services/cache_service.dart';
import '../services/service_locator.dart';
import '../screens/about_screen.dart';
import '../screens/references_screen.dart';
import '../services/audio_service.dart';
/* MULTILANG_TODO: import '../models/supported_language.dart'; */
import '../l10n/app_localizations.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _darkMode = false;
  bool _musicOn = true;
  String _fontSize = 'small';
  double _fontSizeValue = 0.0; // 0.0 = small, 1.0 = medium, 2.0 = large
  bool _textShadow = true;
  double _backgroundOpacity = 0.3;
  String _cacheSize = 'Calculating...';
  Map<String, double> _cacheSizes = {};
  
  // Personalization expansion state
  bool _isPersonalizationExpanded = false;
  
  // Debouncing for sliders and settings
  Timer? _fontSizeDebounceTimer;
  Timer? _opacityDebounceTimer;
  Timer? _settingsDebounceTimer;
  /* MULTILANG_TODO: Language support variables
  String _currentLanguage = 'en';
  List<SupportedLanguage> _supportedLanguages = [];
  */
  late final _supabaseService = ServiceLocator.instance.enhancedSupabaseService;

  // Helper functions for font size mapping
  String _getFontSizeString(double value) {
    if (value <= 0.5) return 'small';
    if (value <= 1.5) return 'medium';
    return 'large';
  }

  double _getFontSizeValue(String fontSize) {
    switch (fontSize) {
      case 'small': return 0.0;
      case 'medium': return 1.0;
      case 'large': return 2.0;
      default: return 1.0;
    }
  }

  String _getFontSizeLabel(double value) {
    if (value <= 0.5) return 'Small';
    if (value <= 1.5) return 'Medium';
    return 'Large';
  }

  @override
  void initState() {
    super.initState();
    final box = Hive.box(SettingsService.boxName);
    _darkMode = box.get(SettingsService.darkKey, defaultValue: false);
    _musicOn = box.get(SettingsService.musicKey, defaultValue: true);
    _fontSize = box.get(SettingsService.fontKey, defaultValue: 'small');
    _fontSizeValue = _getFontSizeValue(_fontSize);
    _textShadow = box.get(SettingsService.shadowKey, defaultValue: false);
    _backgroundOpacity = box.get(SettingsService.opacityKey, defaultValue: 0.3);
    /* MULTILANG_TODO: _currentLanguage = box.get(SettingsService.langKey, defaultValue: 'en'); */
    
    // Sync UI state with actual audio service state
    _syncAudioState();
    
    /* MULTILANG_TODO: _initializeLanguageSupport(); */
    _loadCacheInfo();
  }

  /// Synchronize UI state with actual audio service state
  void _syncAudioState() {
    final actualAudioEnabled = AudioService.instance.isEnabled;
    if (_musicOn != actualAudioEnabled) {
      debugPrint('🎵 Syncing UI state: $_musicOn -> $actualAudioEnabled');
      setState(() {
        _musicOn = actualAudioEnabled;
      });
    }
  }

  Future<void> _loadCacheInfo() async {
    try {
      final totalSize = await CacheService.getTotalCacheSize();
      final sizes = await CacheService.getCacheSizes();
      
      setState(() {
        _cacheSize = CacheService.formatCacheSize(totalSize);
        _cacheSizes = sizes;
      });
    } catch (e) {
      setState(() {
        _cacheSize = 'Error loading';
      });
    }
  }

  /* MULTILANG_TODO: Language initialization
  Future<void> _initializeLanguageSupport() async {
    try {
      setState(() {
        _supportedLanguages = _supabaseService.supportedLanguages;
      });
      
      debugPrint('🌐 Language support initialized with ${_supportedLanguages.length} languages');
    } catch (e) {
      debugPrint('❌ Error initializing language support: $e');
      // Fallback to default languages
      setState(() {
        _supportedLanguages = SupportedLanguage.defaultLanguages;
      });
    }
  }
  */

  // Launch URL in external browser
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $url')),
        );
      }
    }
  }

  Future<void> _toggleSetting(String key, dynamic value) async {
    // PERFORMANCE OPTIMIZATION: Debounce theme-critical changes
    if (key == SettingsService.darkKey || key == SettingsService.shadowKey) {
      _settingsDebounceTimer?.cancel();
      
      // Update UI immediately for responsive feel
      if (mounted) {
        setState(() {
          if (key == SettingsService.darkKey) _darkMode = value;
          if (key == SettingsService.shadowKey) _textShadow = value;
        });
      }
      
      // Debounce the actual storage and theme update
      _settingsDebounceTimer = Timer(const Duration(milliseconds: 150), () {
        _performSettingUpdate(key, value);
      });
    } else {
      // Non-theme settings: immediate update
      await _performSettingUpdate(key, value);
    }
  }
  
  Future<void> _performSettingUpdate(String key, dynamic value) async {
    try {
      // Update Hive storage asynchronously
      await Hive.box(SettingsService.boxName).put(key, value);
      
      // Update UI state only if widget is still mounted
      if (!mounted) return;
      
      setState(() {
        if (key == SettingsService.darkKey) _darkMode = value;
        if (key == SettingsService.musicKey) _musicOn = value;
        if (key == SettingsService.fontKey) {
          _fontSize = value;
          _fontSizeValue = _getFontSizeValue(value);
        }
        if (key == SettingsService.shadowKey) _textShadow = value;
        if (key == SettingsService.opacityKey) _backgroundOpacity = value;
        /* MULTILANG_TODO: if (key == SettingsService.langKey) _currentLanguage = value; */
      });
    } catch (e) {
      debugPrint('❌ Error updating setting $key: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating setting: $e')),
        );
      }
    }
  }

  /* MULTILANG_TODO: Language changing
  Future<void> _changeLanguage(String newLanguage) async {
    try {
      // Update settings
      final settingsService = SettingsService();
      settingsService.setAppLanguage(newLanguage);
      _toggleSetting(SettingsService.langKey, newLanguage);
      
      // Update supabase service language
      await _supabaseService.setCurrentLanguage(newLanguage);
      
      debugPrint('🌐 Language changed to: $newLanguage');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to ${_getLanguageDisplayName(newLanguage)}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error changing language: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error changing language. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  */

  /* MULTILANG_TODO: Language display name
  String _getLanguageDisplayName(String languageCode) {
    // First try to get from supported languages
    final supportedLang = _supportedLanguages
        .where((lang) => lang.langCode == languageCode)
        .firstOrNull;
    
    if (supportedLang != null) {
      return supportedLang.displayNameWithFlag(useNative: true);
    }
    
    // Fallback to localization
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return languageCode;
    
    switch (languageCode) {
      case 'en':
        return localizations.english;
      case 'es':
        return localizations.spanish;
      case 'hi':
        return localizations.hindi;
      default:
        return languageCode;
    }
  }
  */

  void _updateFontSize(double value) {
    // Cancel previous timer
    _fontSizeDebounceTimer?.cancel();
    
    // Update UI immediately for smooth slider interaction
    setState(() {
      _fontSizeValue = value;
    });
    
    // Debounce the actual setting update
    _fontSizeDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      final newFontSize = _getFontSizeString(value);
      _toggleSetting(SettingsService.fontKey, newFontSize);
    });
  }
  
  void _updateOpacity(double value) {
    // Cancel previous timer
    _opacityDebounceTimer?.cancel();
    
    // Update UI immediately for smooth slider interaction
    setState(() {
      _backgroundOpacity = value;
    });
    
    // Debounce the actual setting update
    _opacityDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _toggleSetting(SettingsService.opacityKey, value);
    });
  }

  Future<void> _clearAllCache() async {
    final confirmed = await _showCacheConfirmation(
      'Clear All Cache',
      'This will remove all cached data (verses, chapters, journal) but keep your settings. The app will need to re-download content.',
    );
    
    if (confirmed) {
      try {
        await CacheService.clearAllCache();
        await _loadCacheInfo();
        _showCacheSuccess('All cache cleared successfully');
      } catch (e) {
        _showCacheError('Error clearing cache: $e');
      }
    }
  }

  Future<void> _clearVerseCache() async {
    final confirmed = await _showCacheConfirmation(
      'Clear Verse Cache',
      'This will remove cached daily verses. New verses will be downloaded tomorrow or when manually refreshed.',
    );
    
    if (confirmed) {
      try {
        await CacheService.clearVerseCache();
        await _loadCacheInfo();
        _showCacheSuccess('Verse cache cleared');
      } catch (e) {
        _showCacheError('Error clearing verse cache: $e');
      }
    }
  }

  Future<void> _clearChapterCache() async {
    final confirmed = await _showCacheConfirmation(
      'Clear Chapter Cache',
      'This will remove cached chapter data. Chapters will be re-downloaded when accessed.',
    );
    
    if (confirmed) {
      try {
        await CacheService.clearChapterCache();
        await _loadCacheInfo();
        _showCacheSuccess('Chapter cache cleared');
      } catch (e) {
        _showCacheError('Error clearing chapter cache: $e');
      }
    }
  }

  Future<void> _clearJournalCache() async {
    final confirmed = await _showCacheConfirmation(
      'Clear Journal Cache',
      'This will permanently delete all your local journal entries. This cannot be undone!',
    );
    
    if (confirmed) {
      try {
        await CacheService.clearJournalCache();
        await _loadCacheInfo();
        _showCacheSuccess('Journal cache cleared');
      } catch (e) {
        _showCacheError('Error clearing journal cache: $e');
      }
    }
  }

  Future<bool> _showCacheConfirmation(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showCacheSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCacheError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _fontSizeDebounceTimer?.cancel();
    _opacityDebounceTimer?.cancel();
    _settingsDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image with dark overlay for dark mode
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.png',
              fit: BoxFit.cover,
              color: isDark ? Colors.black.withAlpha((0.32 * 255).toInt()) : null,
              colorBlendMode: isDark ? BlendMode.darken : null,
            ),
          ),
          
          // Sticky header that stays fixed at top
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              decoration: BoxDecoration(
                // Semi-transparent background for glassmorphism effect
                color: theme.colorScheme.surface.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
                // Subtle border at bottom
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Made with ❤️ for spiritual seekers everywhere',
                    style: GoogleFonts.poiretOne(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Underline bar
                  Container(
                    width: 80,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Settings and Preferences',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Scrollable content area that goes under the header
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 140), // Space for sticky header
              child: ListView(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [
              
              // Personalization expandable section
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ExpansionTile(
                  title: Text(
                    'Personalization',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                    ),
                  ),
                  subtitle: Text(
                    _isPersonalizationExpanded ? 'Collapse settings' : 'Tap to customize appearance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  initiallyExpanded: _isPersonalizationExpanded,
                  onExpansionChanged: (expanded) {
                    if (mounted) {
                      setState(() {
                        _isPersonalizationExpanded = expanded;
                      });
                    }
                  },
                  children: [
                    _settingTile(
                      title: localizations!.darkMode,
                      trailing: Switch(
                        value: _darkMode,
                        onChanged: (val) => _toggleSetting(SettingsService.darkKey, val),
                      ),
                    ),
                    _settingTile(
                      title: localizations.backgroundMusic,
                      trailing: Switch(
                        value: _musicOn,
                        onChanged: (val) async {
                          debugPrint('🎵 User toggled music: $_musicOn -> $val');
                          await _toggleSetting(SettingsService.musicKey, val);
                          AudioService.instance.setEnabled(val);
                          
                          // Update UI state immediately
                          if (mounted) {
                            setState(() {
                              _musicOn = val;
                            });
                          }
                          
                          // Clear any pending resume state when user manually changes setting
                          if (!val) {
                            debugPrint('🎵 User disabled music - clearing resume state');
                          }
                        },
                      ),
                    ),
                    _settingTile(
                      title: localizations.fontSize,
                      subtitle: '${_getFontSizeLabel(_fontSizeValue)} - Adjust text size throughout the app',
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: _fontSizeValue,
                          min: 0.0,
                          max: 2.0,
                          divisions: 2,
                          onChanged: _updateFontSize,
                        ),
                      ),
                    ),
                    _settingTile(
                      title: localizations.textShadow,
                      subtitle: 'Add shadow effect to text',
                      trailing: Switch(
                        value: _textShadow,
                        onChanged: (val) => _toggleSetting(SettingsService.shadowKey, val),
                      ),
                    ),
                    _settingTile(
                      title: localizations.backgroundOpacity,
                      subtitle: '${(_backgroundOpacity * 100).round()}% - Adjust background transparency',
                      trailing: SizedBox(
                        width: 150,
                        child: Slider(
                          value: _backgroundOpacity,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          onChanged: _updateOpacity,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              /* MULTILANG_TODO: Language Section with Enhanced Multilingual Support
              // Language Section with Enhanced Multilingual Support
              _sectionTitle(localizations.language),
              ValueListenableBuilder<Box>(
                valueListenable: Hive.box(SettingsService.boxName).listenable(keys: [SettingsService.langKey]),
                builder: (context, box, _) {
                  final currentLang = box.get(SettingsService.langKey, defaultValue: 'en') as String;
                  return _settingTile(
                    title: localizations.appLanguage,
                    subtitle: _supportedLanguages.isNotEmpty 
                        ? 'Content language for chapters, scenarios, and verses'
                        : 'Loading language options...',
                    trailing: _supportedLanguages.isNotEmpty
                        ? DropdownButton<String>(
                            value: currentLang,
                            isExpanded: false,
                            items: _supportedLanguages
                                .where((lang) => lang.isActive)
                                .map((lang) => DropdownMenuItem(
                                  value: lang.langCode,
                                  child: Text(
                                    lang.displayNameWithFlag(useNative: true),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                                .toList(),
                            onChanged: (newLang) {
                              if (newLang != null && newLang != currentLang) {
                                _changeLanguage(newLang);
                              }
                            },
                          )
                        : const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                  );
                },
              ),
              */
              
              /* MULTILANG_TODO: Language Coverage Information
              // Language Coverage Information
              if (_supportedLanguages.isNotEmpty)
                FutureBuilder<Map<String, dynamic>>(
                  future: _supabaseService.getTranslationCoverage(_currentLanguage),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final coverage = snapshot.data!;
                      final hasPartialTranslations = coverage.values.any((v) => 
                          v is Map && v['percentage'] != null && v['percentage'] < 100);
                      
                      if (hasPartialTranslations) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                          child: Card(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Translation Coverage',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...coverage.entries.map((entry) {
                                    final data = entry.value as Map<String, dynamic>;
                                    final percentage = data['percentage'] as double;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            entry.key.replaceAll('_', ' ').toUpperCase(),
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          Text(
                                            '${percentage.toStringAsFixed(0)}%',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: percentage == 100 
                                                  ? Colors.green 
                                                  : percentage > 50 
                                                      ? Colors.orange 
                                                      : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Missing translations will show in English',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),

              _sectionTitle(localizations.storageAndCache),
             */
              // Simplified Cache Management - Single Button Approach
              // User requested: Simple one-button cache clearing while preserving detailed functionality
              _settingTile(
                title: localizations.cacheSize,
                subtitle: _cacheSize,
                leading: const Icon(Icons.storage),
                onTap: () => _loadCacheInfo(),
              ),
              
              _settingTile(
                title: localizations.clearCache,
                subtitle: 'Remove all app cache to free up space',
                leading: const Icon(Icons.delete_sweep, color: Colors.orange),
                onTap: _clearAllCache,
              ),

              /* ============================================================================
               * DETAILED CACHE MANAGEMENT (PRESERVED FOR FUTURE RESTORATION)
               * 
               * This section contains granular cache management functionality that has been
               * commented out per user request for simplified UX. All functionality is
               * preserved and can be easily restored by uncommenting this block.
               * 
               * Features preserved:
               * - Individual cache size breakdown display
               * - Granular cache clearing (verses, chapters, journal separately)
               * - Real-time cache size monitoring
               * - Confirmation dialogs and success feedback
               * 
               * To restore: Simply uncomment the entire block below.
               * ============================================================================ */
              
              // // Individual cache sizes breakdown
              // if (_cacheSizes.isNotEmpty) ...[
              //   for (final entry in _cacheSizes.entries)
              //     if (entry.value > 0)
              //       Padding(
              //         padding: const EdgeInsets.only(left: 32, right: 16),
              //         child: _settingTile(
              //           title: entry.key,
              //           subtitle: CacheService.formatCacheSize(entry.value),
              //         ),
              //       ),
              // ],
              // 
              // // Granular cache clearing options
              // _settingTile(
              //   title: 'Clear All Cache',
              //   subtitle: 'Remove all cached data except settings',
              //   leading: const Icon(Icons.clear_all, color: Colors.red),
              //   onTap: _clearAllCache,
              // ),
              // 
              // _settingTile(
              //   title: 'Clear Verse Cache',
              //   subtitle: 'Remove daily verse cache',
              //   leading: const Icon(Icons.auto_stories, color: Colors.orange),
              //   onTap: _clearVerseCache,
              // ),
              // 
              // _settingTile(
              //   title: 'Clear Chapter Cache',
              //   subtitle: 'Remove chapter data cache',
              //   leading: const Icon(Icons.menu_book, color: Colors.blue),
              //   onTap: _clearChapterCache,
              // ),
              // 
              // _settingTile(
              //   title: 'Clear Journal Cache',
              //   subtitle: 'Permanently delete journal entries',
              //   leading: const Icon(Icons.delete_forever, color: Colors.red),
              //   onTap: _clearJournalCache,
              // ),
              
              /* ============================================================================ */

              _sectionTitle(localizations.extras),
              _settingTile(
                title: localizations.shareThisApp,
                onTap: () async {
                  await AppSharingService().shareApp();
                },
              ),

              _sectionTitle(localizations.resources),
              _settingTile(
                title: localizations.about,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
              _settingTile(
                title: localizations.references,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReferencesScreen()),
                ),
              ),

              _sectionTitle(localizations.supportAndLegal),
              _settingTile(
                title: localizations.sendFeedback,
                leading: const Icon(Icons.email_outlined),
                  onTap: () async {
                    final now = DateTime.now();
                    final formattedDate = DateFormat('yyyyMMdd-HHmmss').format(now);

                    final subject = Uri.encodeComponent('Gitawisdom || Feedback $formattedDate');
                    final body = Uri.encodeComponent(
                        'Hi Team,\n\nWould like to give feedback!\n[Please add your feedback here...]\n\n');

                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'support@hub4apps.com',
                      query: 'subject=$subject&body=$body',
                    );

                    if (await canLaunchUrl(emailLaunchUri)) {
                      await launchUrl(emailLaunchUri);
                    } else {
                      // Optional: Show snackbar or error dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open email client.')),
                      );
                    }
                  }
              ),
              _settingTile(
                title: 'Privacy Policy',
                leading: const Icon(Icons.privacy_tip_outlined),
                onTap: () => _launchUrl('https://hub4apps.com/privacy.html'),
              ),
              _settingTile(
                title: 'Terms of Service', 
                leading: const Icon(Icons.article_outlined),
                onTap: () => _launchUrl('https://hub4apps.com/terms.html'),
              ),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  'App Version 1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          // Floating Back Button
          Positioned(
            top: 26,
            right: 84,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amberAccent,
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.surface,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  splashRadius: 32,
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                ),
              ),
            ),
          ),
          
          // Floating Home Button
          Positioned(
            top: 26,
            right: 24,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amberAccent,
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.surface,
                child: IconButton(
                  icon: Icon(
                    Icons.home_filled,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  splashRadius: 32,
                  onPressed: () {
                    // Use proper tab navigation to sync bottom navigation state
                    NavigationHelper.goToTab(0); // 0 = Home tab index
                  },
                  tooltip: 'Home',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary.withOpacity(0.9),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _settingTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    Widget? leading,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null ? Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ) : null,
        trailing: trailing,
      ),
    );
  }
}
