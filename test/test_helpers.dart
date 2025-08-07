// test/test_helpers.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oldwisdom/services/settings_service.dart';
import 'package:gotrue/src/storage/gotrue_storage.dart'; // adjust import if needed

/// A minimal in‐memory storage to satisfy Supabase’s GoTrueStorage API.
class MockLocalStorage implements GoTrueStorage {
  final Map<String, String> _store = {};
  @override Future<void> clear() async => _store.clear();
  @override Future<void> removeItem(String key) async => _store.remove(key);
  @override Future<void> setItem(String key, String value) async => _store[key] = value;
  @override Future<String?> getItem(String key) async => _store[key];
}

/// Call this in every test’s setUpAll or setUp before your first pumpWidget/test.
Future<void> commonTestSetup() async {
  // 1) ensure binding
  TestWidgetsFlutterBinding.ensureInitialized();

  // 2) mock path_provider so Hive.initFlutter() works
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  pathProviderChannel.setMockMethodCallHandler((call) async {
    return Directory.systemTemp.path;
  });

  // 3) mock shared_preferences for Supabase local storage
  const prefsChannel = MethodChannel('plugins.flutter.io/shared_preferences');
  prefsChannel.setMockMethodCallHandler((call) async => <String, dynamic>{});

  // 4) mock just_audio so AudioService calls don’t blow up
  const audioChannel =
      MethodChannel('com.ryanheise.just_audio.methods');
  audioChannel.setMockMethodCallHandler((call) async => null);

  // 5) init Hive & open your settings box
  await Hive.initFlutter();
  await SettingsService.init();
  await Hive.openBox(SettingsService.boxName);

  // 6) initialize Supabase with a dummy endpoint + our mock storage
  await Supabase.initialize(
    url: 'https://dummy.supabase.co',
    anonKey: 'demo-key',
    localStorage: MockLocalStorage(),
  );
}

