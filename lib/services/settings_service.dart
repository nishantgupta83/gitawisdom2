// lib/services/settings_service.dart

import 'package:hive/hive.dart';

class SettingsService {
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
  }

  final Box _box = Hive.box(boxName);

  bool get isDarkMode => _box.get(darkKey, defaultValue: false) as bool;
  set isDarkMode(bool v) => _box.put(darkKey, v);

  String get language => _box.get(langKey, defaultValue: 'en') as String;
  set language(String v) => _box.put(langKey, v);

  String get fontSize => _box.get(fontKey, defaultValue: 'small') as String;
  set fontSize(String v) => _box.put(fontKey, v);

  bool get textShadowEnabled => _box.get(shadowKey, defaultValue: true) as bool;
  set textShadowEnabled(bool v) => _box.put(shadowKey, v);

  double get backgroundOpacity => _box.get(opacityKey, defaultValue: 0.3) as double;
  set backgroundOpacity(double v) => _box.put(opacityKey, v);
}
