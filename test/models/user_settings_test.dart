// test/models/user_settings_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:GitaWisdom/models/user_settings.dart';

void main() {
  group('FontSize Enum', () {
    test('should have all font sizes', () {
      expect(FontSize.values, hasLength(3));
      expect(FontSize.values, contains(FontSize.small));
      expect(FontSize.values, contains(FontSize.medium));
      expect(FontSize.values, contains(FontSize.large));
    });

    test('should convert to string value', () {
      expect(FontSize.small.value, equals('small'));
      expect(FontSize.medium.value, equals('medium'));
      expect(FontSize.large.value, equals('large'));
    });

    test('should convert from string value', () {
      expect(FontSize.fromString('small'), equals(FontSize.small));
      expect(FontSize.fromString('medium'), equals(FontSize.medium));
      expect(FontSize.fromString('large'), equals(FontSize.large));
    });

    test('should default to medium for invalid string', () {
      expect(FontSize.fromString('invalid'), equals(FontSize.medium));
      expect(FontSize.fromString(''), equals(FontSize.medium));
    });
  });

  group('ThemePreference Enum', () {
    test('should have all theme preferences', () {
      expect(ThemePreference.values, hasLength(3));
      expect(ThemePreference.values, contains(ThemePreference.light));
      expect(ThemePreference.values, contains(ThemePreference.dark));
      expect(ThemePreference.values, contains(ThemePreference.system));
    });

    test('should convert to string value', () {
      expect(ThemePreference.light.value, equals('light'));
      expect(ThemePreference.dark.value, equals('dark'));
      expect(ThemePreference.system.value, equals('system'));
    });

    test('should convert from string value', () {
      expect(ThemePreference.fromString('light'), equals(ThemePreference.light));
      expect(ThemePreference.fromString('dark'), equals(ThemePreference.dark));
      expect(ThemePreference.fromString('system'), equals(ThemePreference.system));
    });

    test('should default to system for invalid string', () {
      expect(ThemePreference.fromString('invalid'), equals(ThemePreference.system));
      expect(ThemePreference.fromString(''), equals(ThemePreference.system));
    });
  });

  group('UserSettings Constructor', () {
    test('should create settings with required fields', () {
      final now = DateTime.now();
      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-123',
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.id, equals('test-id'));
      expect(settings.userDeviceId, equals('device-123'));
      expect(settings.createdAt, equals(now));
      expect(settings.updatedAt, equals(now));
    });

    test('should create settings with default values', () {
      final now = DateTime.now();
      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-123',
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.readingGoalMinutes, equals(10));
      expect(settings.notificationEnabled, isTrue);
      expect(settings.preferredFontSize, equals(FontSize.medium));
      expect(settings.readingStreak, equals(0));
      expect(settings.longestStreak, equals(0));
      expect(settings.totalReadingTimeMinutes, equals(0));
      expect(settings.chaptersCompleted, isEmpty);
      expect(settings.versesRead, isEmpty);
      expect(settings.scenariosExplored, isEmpty);
      expect(settings.totalBookmarks, equals(0));
      expect(settings.totalJournalEntries, equals(0));
      expect(settings.achievementsUnlocked, isEmpty);
      expect(settings.widgetDailyVerseEnabled, isTrue);
      expect(settings.widgetProgressEnabled, isTrue);
      expect(settings.widgetBookmarksEnabled, isTrue);
      expect(settings.themePreference, equals(ThemePreference.system));
      expect(settings.audioEnabled, isTrue);
      expect(settings.hapticFeedbackEnabled, isTrue);
    });

    test('should set default notification time to 8:00 AM', () {
      final now = DateTime.now();
      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-123',
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.notificationTime.hour, equals(8));
      expect(settings.notificationTime.minute, equals(0));
    });

    test('should create settings with all custom values', () {
      final now = DateTime.now();
      final notifTime = DateTime(2024, 1, 1, 9, 30);
      final lastRead = DateTime(2024, 1, 15);

      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-123',
        readingGoalMinutes: 30,
        notificationTime: notifTime,
        notificationEnabled: false,
        preferredFontSize: FontSize.large,
        readingStreak: 5,
        longestStreak: 10,
        lastReadDate: lastRead,
        totalReadingTimeMinutes: 150,
        chaptersCompleted: [1, 2, 3],
        versesRead: [1, 2, 3, 4, 5],
        scenariosExplored: [10, 20, 30],
        totalBookmarks: 15,
        totalJournalEntries: 8,
        achievementsUnlocked: ['first_chapter', 'daily_reader'],
        widgetDailyVerseEnabled: false,
        widgetProgressEnabled: false,
        widgetBookmarksEnabled: false,
        themePreference: ThemePreference.dark,
        audioEnabled: false,
        hapticFeedbackEnabled: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.readingGoalMinutes, equals(30));
      expect(settings.notificationTime, equals(notifTime));
      expect(settings.notificationEnabled, isFalse);
      expect(settings.preferredFontSize, equals(FontSize.large));
      expect(settings.readingStreak, equals(5));
      expect(settings.longestStreak, equals(10));
      expect(settings.lastReadDate, equals(lastRead));
      expect(settings.totalReadingTimeMinutes, equals(150));
      expect(settings.chaptersCompleted, equals([1, 2, 3]));
      expect(settings.versesRead, equals([1, 2, 3, 4, 5]));
      expect(settings.scenariosExplored, equals([10, 20, 30]));
      expect(settings.totalBookmarks, equals(15));
      expect(settings.totalJournalEntries, equals(8));
      expect(settings.achievementsUnlocked, equals(['first_chapter', 'daily_reader']));
      expect(settings.widgetDailyVerseEnabled, isFalse);
      expect(settings.widgetProgressEnabled, isFalse);
      expect(settings.widgetBookmarksEnabled, isFalse);
      expect(settings.themePreference, equals(ThemePreference.dark));
      expect(settings.audioEnabled, isFalse);
      expect(settings.hapticFeedbackEnabled, isFalse);
    });
  });

  group('UserSettings.createDefault Factory', () {
    test('should create default settings with generated UUID', () {
      final settings = UserSettings.createDefault(
        userDeviceId: 'device-456',
      );

      expect(settings.id, isNotEmpty);
      expect(settings.id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')));
      expect(settings.userDeviceId, equals('device-456'));
    });

    test('should set timestamps to current time', () {
      final before = DateTime.now();
      final settings = UserSettings.createDefault(
        userDeviceId: 'device-456',
      );
      final after = DateTime.now();

      expect(settings.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(settings.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      expect(settings.updatedAt, equals(settings.createdAt));
    });

    test('should create with all default values', () {
      final settings = UserSettings.createDefault(
        userDeviceId: 'device-456',
      );

      expect(settings.readingGoalMinutes, equals(10));
      expect(settings.notificationEnabled, isTrue);
      expect(settings.preferredFontSize, equals(FontSize.medium));
      expect(settings.themePreference, equals(ThemePreference.system));
    });
  });

  group('JSON Serialization', () {
    test('should serialize to JSON correctly', () {
      final now = DateTime(2024, 1, 15, 10, 30, 0);
      final notifTime = DateTime(2024, 1, 1, 9, 30);
      final lastRead = DateTime(2024, 1, 14);

      final settings = UserSettings(
        id: 'test-123',
        userDeviceId: 'device-456',
        readingGoalMinutes: 20,
        notificationTime: notifTime,
        notificationEnabled: true,
        preferredFontSize: FontSize.large,
        readingStreak: 3,
        longestStreak: 5,
        lastReadDate: lastRead,
        totalReadingTimeMinutes: 100,
        chaptersCompleted: [1, 2],
        versesRead: [1, 2, 3],
        scenariosExplored: [10, 20],
        totalBookmarks: 5,
        totalJournalEntries: 3,
        achievementsUnlocked: ['achievement1'],
        widgetDailyVerseEnabled: true,
        widgetProgressEnabled: false,
        widgetBookmarksEnabled: true,
        themePreference: ThemePreference.dark,
        audioEnabled: true,
        hapticFeedbackEnabled: false,
        createdAt: now,
        updatedAt: now,
      );

      final json = settings.toJson();

      expect(json['id'], equals('test-123'));
      expect(json['user_device_id'], equals('device-456'));
      expect(json['reading_goal_minutes'], equals(20));
      expect(json['notification_time'], equals('09:30:00'));
      expect(json['notification_enabled'], equals(true));
      expect(json['preferred_font_size'], equals('large'));
      expect(json['reading_streak'], equals(3));
      expect(json['longest_streak'], equals(5));
      expect(json['last_read_date'], equals('2024-01-14'));
      expect(json['total_reading_time_minutes'], equals(100));
      expect(json['chapters_completed'], equals([1, 2]));
      expect(json['verses_read'], equals([1, 2, 3]));
      expect(json['scenarios_explored'], equals([10, 20]));
      expect(json['total_bookmarks'], equals(5));
      expect(json['total_journal_entries'], equals(3));
      expect(json['achievements_unlocked'], equals(['achievement1']));
      expect(json['widget_daily_verse_enabled'], equals(true));
      expect(json['widget_progress_enabled'], equals(false));
      expect(json['widget_bookmarks_enabled'], equals(true));
      expect(json['theme_preference'], equals('dark'));
      expect(json['audio_enabled'], equals(true));
      expect(json['haptic_feedback_enabled'], equals(false));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-789',
        'user_device_id': 'device-abc',
        'reading_goal_minutes': 15,
        'notification_time': '10:45:00',
        'notification_enabled': false,
        'preferred_font_size': 'small',
        'reading_streak': 7,
        'longest_streak': 12,
        'last_read_date': '2024-01-15',
        'total_reading_time_minutes': 200,
        'chapters_completed': [1, 2, 3, 4],
        'verses_read': [1, 2, 3, 4, 5, 6],
        'scenarios_explored': [5, 10, 15],
        'total_bookmarks': 10,
        'total_journal_entries': 6,
        'achievements_unlocked': ['achievement1', 'achievement2'],
        'widget_daily_verse_enabled': false,
        'widget_progress_enabled': true,
        'widget_bookmarks_enabled': false,
        'theme_preference': 'light',
        'audio_enabled': false,
        'haptic_feedback_enabled': true,
        'created_at': '2024-01-15T10:30:00.000Z',
        'updated_at': '2024-01-16T12:00:00.000Z',
      };

      final settings = UserSettings.fromJson(json);

      expect(settings.id, equals('test-789'));
      expect(settings.userDeviceId, equals('device-abc'));
      expect(settings.readingGoalMinutes, equals(15));
      expect(settings.notificationTime.hour, equals(10));
      expect(settings.notificationTime.minute, equals(45));
      expect(settings.notificationEnabled, equals(false));
      expect(settings.preferredFontSize, equals(FontSize.small));
      expect(settings.readingStreak, equals(7));
      expect(settings.longestStreak, equals(12));
      expect(settings.lastReadDate!.year, equals(2024));
      expect(settings.totalReadingTimeMinutes, equals(200));
      expect(settings.chaptersCompleted, equals([1, 2, 3, 4]));
      expect(settings.versesRead, equals([1, 2, 3, 4, 5, 6]));
      expect(settings.scenariosExplored, equals([5, 10, 15]));
      expect(settings.totalBookmarks, equals(10));
      expect(settings.totalJournalEntries, equals(6));
      expect(settings.achievementsUnlocked, equals(['achievement1', 'achievement2']));
      expect(settings.themePreference, equals(ThemePreference.light));
    });

    test('should handle JSON roundtrip', () {
      final now = DateTime.now();
      final notifTime = DateTime(2024, 1, 1, 8, 15);

      final original = UserSettings(
        id: 'roundtrip-test',
        userDeviceId: 'device-xyz',
        readingGoalMinutes: 25,
        notificationTime: notifTime,
        notificationEnabled: true,
        preferredFontSize: FontSize.medium,
        readingStreak: 4,
        longestStreak: 8,
        lastReadDate: DateTime(2024, 1, 15),
        totalReadingTimeMinutes: 120,
        chaptersCompleted: [1, 2, 3],
        versesRead: [1, 2, 3, 4],
        scenariosExplored: [10, 20],
        totalBookmarks: 7,
        totalJournalEntries: 4,
        achievementsUnlocked: ['test'],
        themePreference: ThemePreference.system,
        createdAt: now,
        updatedAt: now,
      );

      final json = original.toJson();
      final restored = UserSettings.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.userDeviceId, equals(original.userDeviceId));
      expect(restored.readingGoalMinutes, equals(original.readingGoalMinutes));
      expect(restored.notificationTime.hour, equals(original.notificationTime.hour));
      expect(restored.notificationTime.minute, equals(original.notificationTime.minute));
      expect(restored.preferredFontSize, equals(original.preferredFontSize));
      expect(restored.readingStreak, equals(original.readingStreak));
      expect(restored.themePreference, equals(original.themePreference));
    });

    test('should handle null values in JSON deserialization', () {
      final json = {
        'id': 'test',
        'user_device_id': 'device',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final settings = UserSettings.fromJson(json);

      expect(settings.readingGoalMinutes, equals(10)); // default
      expect(settings.notificationEnabled, equals(true)); // default
      expect(settings.preferredFontSize, equals(FontSize.medium)); // default
      expect(settings.chaptersCompleted, isEmpty);
      expect(settings.versesRead, isEmpty);
      expect(settings.achievementsUnlocked, isEmpty);
    });
  });

  group('copyWith Method', () {
    test('should create copy with updated fields', () {
      final now = DateTime.now();
      final original = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        readingGoalMinutes: 10,
        createdAt: now,
        updatedAt: now,
      );

      final copy = original.copyWith(
        readingGoalMinutes: 20,
        notificationEnabled: false,
      );

      expect(copy.id, equals('test-id'));
      expect(copy.readingGoalMinutes, equals(20));
      expect(copy.notificationEnabled, isFalse);
    });

    test('should update timestamp when copying', () {
      final now = DateTime.now();
      final original = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        createdAt: now,
        updatedAt: now,
      );

      final before = DateTime.now();
      final copy = original.copyWith(readingGoalMinutes: 15);
      final after = DateTime.now();

      expect(copy.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(copy.updatedAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      expect(copy.createdAt, equals(now));
    });

    test('should preserve unchanged fields', () {
      final now = DateTime.now();
      final original = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        readingGoalMinutes: 10,
        readingStreak: 5,
        themePreference: ThemePreference.dark,
        createdAt: now,
        updatedAt: now,
      );

      final copy = original.copyWith(readingGoalMinutes: 15);

      expect(copy.id, equals(original.id));
      expect(copy.userDeviceId, equals(original.userDeviceId));
      expect(copy.readingStreak, equals(original.readingStreak));
      expect(copy.themePreference, equals(original.themePreference));
      expect(copy.readingGoalMinutes, equals(15));
    });
  });

  group('Computed Properties', () {
    test('formattedNotificationTime should format time correctly', () {
      final now = DateTime.now();
      final notifTime = DateTime(2024, 1, 1, 9, 30);

      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        notificationTime: notifTime,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.formattedNotificationTime, equals('09:30'));
    });

    test('readingProgressPercentage should calculate correctly', () {
      final now = DateTime.now();

      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        chaptersCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9], // 9 out of 18
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.readingProgressPercentage, equals(0.5)); // 9/18 = 0.5
    });

    test('hasActiveStreak should return true for positive streak', () {
      final now = DateTime.now();

      final withStreak = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        readingStreak: 5,
        createdAt: now,
        updatedAt: now,
      );

      final withoutStreak = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        readingStreak: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(withStreak.hasActiveStreak, isTrue);
      expect(withoutStreak.hasActiveStreak, isFalse);
    });

    test('readToday should check if last read was today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final readToday = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        lastReadDate: today,
        createdAt: now,
        updatedAt: now,
      );

      final readYesterday = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        lastReadDate: yesterday,
        createdAt: now,
        updatedAt: now,
      );

      final neverRead = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        createdAt: now,
        updatedAt: now,
      );

      expect(readToday.readToday, isTrue);
      expect(readYesterday.readToday, isFalse);
      expect(neverRead.readToday, isFalse);
    });

    test('achievementSummary should return complete summary', () {
      final now = DateTime.now();

      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        chaptersCompleted: [1, 2, 3],
        versesRead: [1, 2, 3, 4, 5],
        scenariosExplored: [10, 20],
        totalBookmarks: 8,
        totalJournalEntries: 4,
        achievementsUnlocked: ['achievement1', 'achievement2'],
        readingStreak: 7,
        longestStreak: 12,
        totalReadingTimeMinutes: 150,
        createdAt: now,
        updatedAt: now,
      );

      final summary = settings.achievementSummary;

      expect(summary['chaptersCompleted'], equals(3));
      expect(summary['versesRead'], equals(5));
      expect(summary['scenarios'], equals(2));
      expect(summary['bookmarks'], equals(8));
      expect(summary['journal'], equals(4));
      expect(summary['achievements'], equals(2));
      expect(summary['streak'], equals(7));
      expect(summary['longestStreak'], equals(12));
      expect(summary['totalTime'], equals(150));
    });

    test('isValid should validate required fields', () {
      final now = DateTime.now();

      final valid = UserSettings(
        id: 'valid-id',
        userDeviceId: 'device-1',
        readingGoalMinutes: 10,
        createdAt: now,
        updatedAt: now,
      );

      final emptyId = UserSettings(
        id: '',
        userDeviceId: 'device-1',
        createdAt: now,
        updatedAt: now,
      );

      final emptyDevice = UserSettings(
        id: 'test-id',
        userDeviceId: '',
        createdAt: now,
        updatedAt: now,
      );

      final zeroGoal = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        readingGoalMinutes: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(valid.isValid, isTrue);
      expect(emptyId.isValid, isFalse);
      expect(emptyDevice.isValid, isFalse);
      expect(zeroGoal.isValid, isFalse);
    });
  });

  group('Equality and HashCode', () {
    test('should be equal for same id and device', () {
      final now = DateTime.now();
      final settings1 = UserSettings(
        id: 'same-id',
        userDeviceId: 'device-1',
        createdAt: now,
        updatedAt: now,
      );

      final settings2 = UserSettings(
        id: 'same-id',
        userDeviceId: 'device-1',
        readingGoalMinutes: 20, // Different value
        createdAt: now,
        updatedAt: now,
      );

      expect(settings1, equals(settings2));
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('should not be equal for different ids', () {
      final now = DateTime.now();
      final settings1 = UserSettings(
        id: 'id-1',
        userDeviceId: 'device-1',
        createdAt: now,
        updatedAt: now,
      );

      final settings2 = UserSettings(
        id: 'id-2',
        userDeviceId: 'device-1',
        createdAt: now,
        updatedAt: now,
      );

      expect(settings1, isNot(equals(settings2)));
    });
  });

  group('toString Method', () {
    test('should provide meaningful string representation', () {
      final now = DateTime.now();
      final settings = UserSettings(
        id: 'test-123',
        userDeviceId: 'device-456',
        readingStreak: 5,
        chaptersCompleted: [1, 2, 3],
        createdAt: now,
        updatedAt: now,
      );

      final str = settings.toString();

      expect(str, contains('test-123'));
      expect(str, contains('device-456'));
      expect(str, contains('5'));
      expect(str, contains('3'));
    });
  });

  group('Edge Cases', () {
    test('should handle very long reading streak', () {
      final now = DateTime.now();
      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        readingStreak: 1000,
        longestStreak: 1500,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.readingStreak, equals(1000));
      expect(settings.longestStreak, equals(1500));
    });

    test('should handle large reading time', () {
      final now = DateTime.now();
      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        totalReadingTimeMinutes: 100000,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.totalReadingTimeMinutes, equals(100000));
    });

    test('should handle all chapters completed', () {
      final now = DateTime.now();
      final allChapters = List.generate(18, (i) => i + 1);

      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        chaptersCompleted: allChapters,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.chaptersCompleted, hasLength(18));
      expect(settings.readingProgressPercentage, equals(1.0));
    });

    test('should handle many verses read', () {
      final now = DateTime.now();
      final manyVerses = List.generate(500, (i) => i + 1);

      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        versesRead: manyVerses,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.versesRead, hasLength(500));
    });

    test('should handle many scenarios explored', () {
      final now = DateTime.now();
      final manyScenarios = List.generate(1000, (i) => i + 1);

      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        scenariosExplored: manyScenarios,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.scenariosExplored, hasLength(1000));
    });

    test('should handle many achievements', () {
      final now = DateTime.now();
      final manyAchievements = List.generate(100, (i) => 'achievement$i');

      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        achievementsUnlocked: manyAchievements,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.achievementsUnlocked, hasLength(100));
    });

    test('should handle midnight notification time', () {
      final now = DateTime.now();
      final midnight = DateTime(2024, 1, 1, 0, 0);

      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        notificationTime: midnight,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.notificationTime.hour, equals(0));
      expect(settings.notificationTime.minute, equals(0));
      expect(settings.formattedNotificationTime, equals('00:00'));
    });

    test('should handle late night notification time', () {
      final now = DateTime.now();
      final lateNight = DateTime(2024, 1, 1, 23, 59);

      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        notificationTime: lateNight,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.notificationTime.hour, equals(23));
      expect(settings.notificationTime.minute, equals(59));
      expect(settings.formattedNotificationTime, equals('23:59'));
    });

    test('should handle all theme preferences', () {
      final now = DateTime.now();

      for (final theme in ThemePreference.values) {
        final settings = UserSettings(
          id: 'test-$theme',
          userDeviceId: 'device-1',
          themePreference: theme,
          createdAt: now,
          updatedAt: now,
        );

        expect(settings.themePreference, equals(theme));
      }
    });

    test('should handle all font sizes', () {
      final now = DateTime.now();

      for (final fontSize in FontSize.values) {
        final settings = UserSettings(
          id: 'test-$fontSize',
          userDeviceId: 'device-1',
          preferredFontSize: fontSize,
          createdAt: now,
          updatedAt: now,
        );

        expect(settings.preferredFontSize, equals(fontSize));
      }
    });

    test('should handle high reading goal', () {
      final now = DateTime.now();
      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        readingGoalMinutes: 240, // 4 hours
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.readingGoalMinutes, equals(240));
    });

    test('should handle many bookmarks and journal entries', () {
      final now = DateTime.now();
      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        totalBookmarks: 10000,
        totalJournalEntries: 5000,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.totalBookmarks, equals(10000));
      expect(settings.totalJournalEntries, equals(5000));
    });

    test('should handle all widget configurations', () {
      final now = DateTime.now();
      final settings = UserSettings(
        id: 'test-id',
        userDeviceId: 'device-1',
        widgetDailyVerseEnabled: true,
        widgetProgressEnabled: false,
        widgetBookmarksEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.widgetDailyVerseEnabled, isTrue);
      expect(settings.widgetProgressEnabled, isFalse);
      expect(settings.widgetBookmarksEnabled, isTrue);
    });
  });
}
