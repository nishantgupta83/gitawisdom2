// lib/core/theme/theme_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../app_config.dart';
import '../../services/settings_service.dart';
import 'app_theme.dart';

/// Theme provider that manages app theme state and settings
/// Replaces complex ValueListenableBuilder logic from main.dart
class ThemeProvider extends ChangeNotifier {
  late Box _settingsBox;
  
  // Current theme settings
  bool _isDark = AppConfig.defaultDarkMode;
  String _fontPref = AppConfig.defaultFontSize;
  bool _shadowEnabled = AppConfig.defaultShadowEnabled;
  double _backgroundOpacity = AppConfig.defaultBackgroundOpacity;

  // Getters for current theme settings
  bool get isDark => _isDark;
  String get fontPref => _fontPref;
  bool get shadowEnabled => _shadowEnabled;
  double get backgroundOpacity => _backgroundOpacity;
  double get textScale => AppConfig.getTextScale(_fontPref);
  ThemeMode get themeMode => AppTheme.getThemeMode(_isDark);
  
  /// Initialize theme provider with settings box
  Future<void> initialize() async {
    try {
      // Ensure settings box is opened before accessing
      if (!Hive.isBoxOpen(SettingsService.boxName)) {
        _settingsBox = await Hive.openBox(SettingsService.boxName);
      } else {
        _settingsBox = Hive.box(SettingsService.boxName);
      }

      _loadSettings();
      _settingsBox.listenable().addListener(_onSettingsChanged);
      debugPrint('✅ ThemeProvider initialized with box: ${_settingsBox.name}');
    } catch (e) {
      debugPrint('❌ ThemeProvider initialization failed: $e - using defaults');
      // Use defaults if initialization fails
      _isDark = AppConfig.defaultDarkMode;
      _fontPref = AppConfig.defaultFontSize;
      _shadowEnabled = AppConfig.defaultShadowEnabled;
      _backgroundOpacity = AppConfig.defaultBackgroundOpacity;
    }
  }

  /// Load current settings from Hive box
  void _loadSettings() {
    try {
      _isDark = _settingsBox.get(SettingsService.darkKey, defaultValue: AppConfig.defaultDarkMode) as bool;
      _fontPref = _settingsBox.get(SettingsService.fontKey, defaultValue: AppConfig.defaultFontSize) as String;
      _shadowEnabled = _settingsBox.get(SettingsService.shadowKey, defaultValue: AppConfig.defaultShadowEnabled) as bool;
      _backgroundOpacity = _settingsBox.get(SettingsService.opacityKey, defaultValue: AppConfig.defaultBackgroundOpacity) as double;
      debugPrint('🎨 Theme settings loaded: dark=$_isDark, font=$_fontPref, shadow=$_shadowEnabled');
    } catch (e) {
      debugPrint('❌ Failed to load theme settings: $e - using defaults');
      _isDark = AppConfig.defaultDarkMode;
      _fontPref = AppConfig.defaultFontSize;
      _shadowEnabled = AppConfig.defaultShadowEnabled;
      _backgroundOpacity = AppConfig.defaultBackgroundOpacity;
    }
  }

  /// Handle settings changes from Hive box (with debouncing to prevent UI hangs)
  Timer? _themeUpdateTimer;
  static const Duration _themeDebounce = Duration(milliseconds: 100);

  void _onSettingsChanged() {
    // Cancel previous timer to debounce rapid theme changes
    _themeUpdateTimer?.cancel();
    _themeUpdateTimer = Timer(_themeDebounce, () {
      // Safety check: don't access box if it's closed
      if (!_settingsBox.isOpen) {
        return;
      }

      final newIsDark = _settingsBox.get(SettingsService.darkKey, defaultValue: AppConfig.defaultDarkMode) as bool;
      final newFontPref = _settingsBox.get(SettingsService.fontKey, defaultValue: AppConfig.defaultFontSize) as String;
      final newShadowEnabled = _settingsBox.get(SettingsService.shadowKey, defaultValue: AppConfig.defaultShadowEnabled) as bool;
      final newBackgroundOpacity = _settingsBox.get(SettingsService.opacityKey, defaultValue: AppConfig.defaultBackgroundOpacity) as double;
      
      if (newIsDark != _isDark || 
          newFontPref != _fontPref || 
          newShadowEnabled != _shadowEnabled || 
          newBackgroundOpacity != _backgroundOpacity) {
        
        // Notify widget service about theme transition
        // Widget service removed
        
        _isDark = newIsDark;
        _fontPref = newFontPref;
        _shadowEnabled = newShadowEnabled;
        _backgroundOpacity = newBackgroundOpacity;
        
        // Use microtask to prevent main thread blocking
        Future.microtask(() => notifyListeners());
        debugPrint('🎨 Theme updated: dark=$newIsDark, shadow=$newShadowEnabled');
      }
    });
  }

  /// Get light theme with current settings
  ThemeData get lightTheme => AppTheme.buildLightTheme(shadowEnabled: _shadowEnabled);
  
  /// Get dark theme with current settings
  ThemeData get darkTheme => AppTheme.buildDarkTheme(shadowEnabled: _shadowEnabled);
  
  /// Get current theme based on dark mode setting
  ThemeData get currentTheme => _isDark ? darkTheme : lightTheme;

  /// Update theme settings
  Future<void> updateTheme({
    bool? isDark,
    String? fontPref,
    bool? shadowEnabled,
    double? backgroundOpacity,
  }) async {
    try {
      // Ensure settings box is available and open
      if (!Hive.isBoxOpen(SettingsService.boxName)) {
        try {
          _settingsBox = await Hive.openBox(SettingsService.boxName);
        } catch (e) {
          debugPrint('❌ Failed to open settings box: $e');
          return;
        }
      } else {
        _settingsBox = Hive.box(SettingsService.boxName);
      }

      // Check if box is still open before each operation
      if (!_settingsBox.isOpen) {
        debugPrint('❌ Settings box is closed, cannot update theme');
        return;
      }

      if (isDark != null && isDark != _isDark) {
        await _settingsBox.put(SettingsService.darkKey, isDark);
        debugPrint('🎨 Dark mode updated: $isDark');
      }
      if (fontPref != null && fontPref != _fontPref) {
        await _settingsBox.put(SettingsService.fontKey, fontPref);
        debugPrint('🎨 Font preference updated: $fontPref');
      }
      if (shadowEnabled != null && shadowEnabled != _shadowEnabled) {
        await _settingsBox.put(SettingsService.shadowKey, shadowEnabled);
        debugPrint('🎨 Shadow enabled updated: $shadowEnabled');
      }
      if (backgroundOpacity != null && backgroundOpacity != _backgroundOpacity) {
        await _settingsBox.put(SettingsService.opacityKey, backgroundOpacity);
        debugPrint('🎨 Background opacity updated: $backgroundOpacity');
      }
      // Settings change will be handled by _onSettingsChanged
    } catch (e) {
      debugPrint('❌ Failed to update theme settings: $e');
    }
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    await updateTheme(isDark: !_isDark);
  }

  /// Set font size
  Future<void> setFontSize(String size) async {
    await updateTheme(fontPref: size);
  }

  /// Toggle shadow enabled
  Future<void> toggleShadow() async {
    await updateTheme(shadowEnabled: !_shadowEnabled);
  }

  /// Set background opacity
  Future<void> setBackgroundOpacity(double opacity) async {
    await updateTheme(backgroundOpacity: opacity);
  }

  @override
  void dispose() {
    _themeUpdateTimer?.cancel();
    _settingsBox.listenable().removeListener(_onSettingsChanged);
    super.dispose();
  }
}