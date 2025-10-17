// lib/services/settings_service.dart

import 'dart:async';
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
    
    final box = Hive.box(boxName);
    const firstRunKey = 'first_run_completed';

    if (!box.containsKey(firstRunKey)) {
      await box.put(darkKey, false);
      await box.put(musicKey, true);
      await box.put(firstRunKey, true);
    }
  }

  Box? _box;
  Box get box {
    try {
      return _box ??= Hive.box(boxName);
    } catch (e) {
      debugPrint('⚠️ Error accessing settings box: $e');
      // Return emergency fallback - will cause getter methods to use defaults
      rethrow;
    }
  }

  Timer? _saveTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  // Cache for immediate UI updates
  bool? _cachedDarkMode;
  
  @override
  void dispose() {
    _saveTimer?.cancel();
    _shadowSaveTimer?.cancel();
    super.dispose();
  }

  bool get isDarkMode {
    try {
      _cachedDarkMode ??= box.get(darkKey, defaultValue: false) as bool;
      return _cachedDarkMode!;
    } catch (e) {
      debugPrint('⚠️ Error reading isDarkMode: $e');
      return false; // Safe fallback
    }
  }

  set isDarkMode(bool v) {
    _cachedDarkMode = v;
    notifyListeners();

    _saveTimer?.cancel();
    _saveTimer = Timer(_debounceDuration, () {
      box.put(darkKey, v);
    });
  }

  String get language {
    try {
      return box.get(langKey, defaultValue: 'en') as String;
    } catch (e) {
      debugPrint('⚠️ Error reading language: $e');
      return 'en'; // Safe fallback
    }
  }
  set language(String v) {
    box.put(langKey, v);
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

  String get fontSize {
    try {
      return box.get(fontKey, defaultValue: 'small') as String;
    } catch (e) {
      debugPrint('⚠️ Error reading fontSize: $e');
      return 'small'; // Safe fallback
    }
  }
  set fontSize(String v) {
    box.put(fontKey, v);
    notifyListeners();
  }

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void setTheme(ThemeMode mode) {
    isDarkMode = (mode == ThemeMode.dark);
  }

  void setFontSize(String size) {
    fontSize = size;
  }

  bool get musicEnabled {
    try {
      return box.get(musicKey, defaultValue: true) as bool;
    } catch (e) {
      debugPrint('⚠️ Error reading musicEnabled: $e');
      return true; // Safe fallback
    }
  }
  set musicEnabled(bool v) {
    box.put(musicKey, v);
    notifyListeners();
  }

  bool? _cachedTextShadow;
  Timer? _shadowSaveTimer;

  bool get textShadowEnabled {
    try {
      _cachedTextShadow ??= box.get(shadowKey, defaultValue: false) as bool;
      return _cachedTextShadow!;
    } catch (e) {
      debugPrint('⚠️ Error reading textShadowEnabled: $e');
      return false; // Safe fallback
    }
  }

  set textShadowEnabled(bool v) {
    _cachedTextShadow = v;
    notifyListeners();

    _shadowSaveTimer?.cancel();
    _shadowSaveTimer = Timer(_debounceDuration, () {
      box.put(shadowKey, v);
    });
  }

  double get backgroundOpacity {
    try {
      return box.get(opacityKey, defaultValue: 1.0) as double;
    } catch (e) {
      debugPrint('⚠️ Error reading backgroundOpacity: $e');
      return 1.0; // Safe fallback
    }
  }
  set backgroundOpacity(double v) => box.put(opacityKey, v);
}
