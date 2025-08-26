// lib/services/settings_service.dart

import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart'; // for ChangeNotifier
import 'package:flutter/material.dart';  // for ThemeMode

class SettingsService extends ChangeNotifier {
  static const String boxName = 'settings';
  static const String darkKey = 'isDarkMode';
  static const String langKey = 'language';
  static const String fontKey = 'fontSize';
  static const String musicKey = 'music_enabled';
  static const String shadowKey = 'text_shadow_enabled';
  static const String opacityKey = 'background_opacity';

  /// Call once at startup:
  static Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
    
    // Set default settings only on first app install (not every startup)
    final box = Hive.box(boxName);
    const firstRunKey = 'first_run_completed';
    
    if (!box.containsKey(firstRunKey)) {
      // First time app is installed - set preferred defaults
      await box.put(darkKey, false);  // Start in light mode
      await box.put(musicKey, true);  // Start with music enabled
      await box.put(firstRunKey, true);  // Mark first run as completed
      debugPrint('🎯 First app install - set default: light mode, music enabled');
    }
  }

  final Box _box = Hive.box(boxName);

 // bool get isDarkMode => _box.get(darkKey, defaultValue: false) as bool;
 // set isDarkMode(bool v) => _box.put(darkKey, v);

    bool get isDarkMode => _box.get(darkKey, defaultValue: false) as bool;
    set isDarkMode(bool v) {
        _box.put(darkKey, v);
        notifyListeners();
      }

  String get language => _box.get(langKey, defaultValue: 'en') as String;
  set language(String v) {
    _box.put(langKey, v);
    notifyListeners();
  }

  /// Set app language with enhanced notifications
  void setAppLanguage(String langCode) {
    if (language != langCode) {
      language = langCode;
      // Notify UI to rebuild with new language
      notifyListeners();
    }
  }

  String get fontSize => _box.get(fontKey, defaultValue: 'small') as String;
 // set fontSize(String v) => _box.put(fontKey, v);
    set fontSize(String v) {
        _box.put(fontKey, v);
        notifyListeners();
      }



    // ----------------------------------------------------------------------------
    // Convenience getters/setters for theming & font (for your ChangeNotifierProvider)
    // ----------------------------------------------------------------------------

    /// Returns the app’s current ThemeMode.
    ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

    /// Switch between light/dark.
    void setTheme(ThemeMode mode) {
        isDarkMode = (mode == ThemeMode.dark);
        // notifyListeners() already called by the setter
      }

    /// Change the global font size setting.
    void setFontSize(String size) {
        fontSize = size;
        // notifyListeners() already called by the setter
      }

    /// Manage background music on/off.
    bool get musicEnabled => _box.get(musicKey, defaultValue: true) as bool;
    set musicEnabled(bool v) {
        _box.put(musicKey, v);
        notifyListeners();
      }

  bool get textShadowEnabled => _box.get(shadowKey, defaultValue: false) as bool;
  set textShadowEnabled(bool v) => _box.put(shadowKey, v);

  double get backgroundOpacity => _box.get(opacityKey, defaultValue: 1.0) as double;
  set backgroundOpacity(double v) => _box.put(opacityKey, v);
}
