// test/test_helpers.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GitaWisdom/services/settings_service.dart';
import 'package:GitaWisdom/models/verse.dart';
import 'package:GitaWisdom/models/daily_verse_set.dart';
import 'package:GitaWisdom/models/scenario.dart';
import 'package:GitaWisdom/models/journal_entry.dart';
import 'package:GitaWisdom/models/chapter.dart';

/// A minimal in‐memory storage to satisfy Supabase's storage API.
class MockLocalStorage {
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

  // 5) init Hive & register type adapters for new models
  await Hive.initFlutter();
  
  // Register Hive adapters for new models (if not already registered)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(VerseAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(DailyVerseSetAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ScenarioAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(JournalEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(ChapterAdapter());
  }
  
  await SettingsService.init();
  await Hive.openBox(SettingsService.boxName);
  
  // Open test boxes for caching models
  await Hive.openBox<DailyVerseSet>('daily_verses');
  await Hive.openBox<Scenario>('scenarios');
  await Hive.openBox<JournalEntry>('journal_entries');

  // 6) initialize Supabase with a dummy endpoint + our mock storage
    await Supabase.initialize(
          url: 'https://dummy.supabase.co',
          anonKey: 'demo-key',
        );
}

/// Clean up test data and close Hive boxes
Future<void> commonTestCleanup() async {
  try {
    // Close all test boxes gracefully
    for (var box in Hive.openedBoxes) {
      if (box.isOpen) {
        await box.close();
      }
    }
    // Clear all boxes from memory
    Hive.init('');
  } catch (e) {
    // Ignore cleanup errors in tests
    print('Test cleanup warning: $e');
  }
}

/// Create test daily verse set
DailyVerseSet createTestDailyVerseSet({
  String? date,
  List<Verse>? verses,
  List<int>? chapterIds,
}) {
  return DailyVerseSet(
    date: date ?? '2024-01-15',
    verses: verses ?? [
      Verse(verseId: 1, description: 'Test verse 1', chapterId: 1),
      Verse(verseId: 2, description: 'Test verse 2', chapterId: 2),
    ],
    chapterIds: chapterIds ?? [1, 2],
  );
}

/// Create test scenario
Scenario createTestScenario({
  String? title,
  String? category,
  int? chapter,
}) {
  return Scenario(
    title: title ?? 'Test Career Decision',
    description: 'Should I take this new job opportunity?',
    category: category ?? 'Career',
    chapter: chapter ?? 1,
    heartResponse: 'Follow your passion and dreams',
    dutyResponse: 'Consider your responsibilities and commitments',
    gitaWisdom: 'Perform your duty without attachment to results',
    verse: 'You have a right to perform your prescribed duty, but do not covet the fruits of action',
    verseNumber: '2.47',
    tags: ['career', 'decision', 'duty'],
    actionSteps: ['Analyze pros and cons', 'Consult trusted advisors', 'Make decision aligned with dharma'],
    createdAt: DateTime(2024, 1, 15),
  );
}

/// Create test journal entry
JournalEntry createTestJournalEntry({
  String? id,
  String? reflection,
  int? rating,
}) {
  return JournalEntry(
    id: id ?? 'test-entry-123',
    reflection: reflection ?? 'Today I learned about the importance of performing duty without attachment',
    rating: rating ?? 4,
    dateCreated: DateTime(2024, 1, 15, 10, 30),
  );
}

