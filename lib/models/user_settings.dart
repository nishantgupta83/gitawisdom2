// lib/models/user_settings.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_settings.g.dart';

/// Font size preferences
enum FontSize {
  small,
  medium,
  large;

  String get value => name;

  static FontSize fromString(String value) {
    return FontSize.values.firstWhere(
      (size) => size.value == value,
      orElse: () => FontSize.medium,
    );
  }
}

/// Theme preferences
enum ThemePreference {
  light,
  dark,
  system;

  String get value => name;

  static ThemePreference fromString(String value) {
    return ThemePreference.values.firstWhere(
      (theme) => theme.value == value,
      orElse: () => ThemePreference.system,
    );
  }
}

@HiveType(typeId: 11)
class UserSettings extends HiveObject {
  /// Unique identifier
  @HiveField(0)
  final String id;

  /// Device identifier for sync
  @HiveField(1)
  final String userDeviceId;

  // Reading Goals & Preferences
  @HiveField(2)
  final int readingGoalMinutes;

  @HiveField(3)
  final DateTime notificationTime;

  @HiveField(4)
  final bool notificationEnabled;

  @HiveField(5)
  final FontSize preferredFontSize;

  // Progress Tracking
  @HiveField(6)
  final int readingStreak;

  @HiveField(7)
  final int longestStreak;

  @HiveField(8)
  final DateTime? lastReadDate;

  @HiveField(9)
  final int totalReadingTimeMinutes;

  // Completed Content Tracking
  @HiveField(10)
  final List<int> chaptersCompleted;

  @HiveField(11)
  final List<int> versesRead;

  @HiveField(12)
  final List<int> scenariosExplored;

  // Personal Achievement Data
  @HiveField(13)
  final int totalBookmarks;

  @HiveField(14)
  final int totalJournalEntries;

  @HiveField(15)
  final List<String> achievementsUnlocked;

  // Widget Configuration
  @HiveField(16)
  final bool widgetDailyVerseEnabled;

  @HiveField(17)
  final bool widgetProgressEnabled;

  @HiveField(18)
  final bool widgetBookmarksEnabled;

  // App Customization
  @HiveField(19)
  final ThemePreference themePreference;

  @HiveField(20)
  final bool audioEnabled;

  @HiveField(21)
  final bool hapticFeedbackEnabled;

  // Timestamps
  @HiveField(22)
  final DateTime createdAt;

  @HiveField(23)
  final DateTime updatedAt;

  UserSettings({
    required this.id,
    required this.userDeviceId,
    this.readingGoalMinutes = 10,
    DateTime? notificationTime,
    this.notificationEnabled = true,
    this.preferredFontSize = FontSize.medium,
    this.readingStreak = 0,
    this.longestStreak = 0,
    this.lastReadDate,
    this.totalReadingTimeMinutes = 0,
    this.chaptersCompleted = const [],
    this.versesRead = const [],
    this.scenariosExplored = const [],
    this.totalBookmarks = 0,
    this.totalJournalEntries = 0,
    this.achievementsUnlocked = const [],
    this.widgetDailyVerseEnabled = true,
    this.widgetProgressEnabled = true,
    this.widgetBookmarksEnabled = true,
    this.themePreference = ThemePreference.system,
    this.audioEnabled = true,
    this.hapticFeedbackEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  }) : notificationTime = notificationTime ?? DateTime(2024, 1, 1, 8, 0); // Default 8:00 AM

  /// Creates UserSettings from Supabase JSON response
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    // Parse notification time from TIME format "HH:MM:SS"
    DateTime parseNotificationTime(String? timeStr) {
      if (timeStr == null) return DateTime(2024, 1, 1, 8, 0);
      try {
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(2024, 1, 1, hour, minute);
      } catch (e) {
        return DateTime(2024, 1, 1, 8, 0);
      }
    }

    return UserSettings(
      id: json['id'] as String,
      userDeviceId: json['user_device_id'] as String,
      readingGoalMinutes: json['reading_goal_minutes'] as int? ?? 10,
      notificationTime: parseNotificationTime(json['notification_time'] as String?),
      notificationEnabled: json['notification_enabled'] as bool? ?? true,
      preferredFontSize: FontSize.fromString(json['preferred_font_size'] as String? ?? 'medium'),
      readingStreak: json['reading_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastReadDate: json['last_read_date'] != null 
          ? DateTime.parse(json['last_read_date'] as String)
          : null,
      totalReadingTimeMinutes: json['total_reading_time_minutes'] as int? ?? 0,
      chaptersCompleted: (json['chapters_completed'] as List<dynamic>?)?.cast<int>() ?? [],
      versesRead: (json['verses_read'] as List<dynamic>?)?.cast<int>() ?? [],
      scenariosExplored: (json['scenarios_explored'] as List<dynamic>?)?.cast<int>() ?? [],
      totalBookmarks: json['total_bookmarks'] as int? ?? 0,
      totalJournalEntries: json['total_journal_entries'] as int? ?? 0,
      achievementsUnlocked: (json['achievements_unlocked'] as List<dynamic>?)?.cast<String>() ?? [],
      widgetDailyVerseEnabled: json['widget_daily_verse_enabled'] as bool? ?? true,
      widgetProgressEnabled: json['widget_progress_enabled'] as bool? ?? true,
      widgetBookmarksEnabled: json['widget_bookmarks_enabled'] as bool? ?? true,
      themePreference: ThemePreference.fromString(json['theme_preference'] as String? ?? 'system'),
      audioEnabled: json['audio_enabled'] as bool? ?? true,
      hapticFeedbackEnabled: json['haptic_feedback_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts settings to JSON for Supabase storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_device_id': userDeviceId,
      'reading_goal_minutes': readingGoalMinutes,
      'notification_time': '${notificationTime.hour.toString().padLeft(2, '0')}:${notificationTime.minute.toString().padLeft(2, '0')}:00',
      'notification_enabled': notificationEnabled,
      'preferred_font_size': preferredFontSize.value,
      'reading_streak': readingStreak,
      'longest_streak': longestStreak,
      'last_read_date': lastReadDate?.toIso8601String().split('T')[0],
      'total_reading_time_minutes': totalReadingTimeMinutes,
      'chapters_completed': chaptersCompleted,
      'verses_read': versesRead,
      'scenarios_explored': scenariosExplored,
      'total_bookmarks': totalBookmarks,
      'total_journal_entries': totalJournalEntries,
      'achievements_unlocked': achievementsUnlocked,
      'widget_daily_verse_enabled': widgetDailyVerseEnabled,
      'widget_progress_enabled': widgetProgressEnabled,
      'widget_bookmarks_enabled': widgetBookmarksEnabled,
      'theme_preference': themePreference.value,
      'audio_enabled': audioEnabled,
      'haptic_feedback_enabled': hapticFeedbackEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates default settings for a new user
  factory UserSettings.createDefault({
    required String userDeviceId,
  }) {
    final now = DateTime.now();
    const uuid = Uuid();
    return UserSettings(
      id: uuid.v4(), // Generate proper UUID instead of timestamp
      userDeviceId: userDeviceId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a copy with updated fields
  UserSettings copyWith({
    String? id,
    String? userDeviceId,
    int? readingGoalMinutes,
    DateTime? notificationTime,
    bool? notificationEnabled,
    FontSize? preferredFontSize,
    int? readingStreak,
    int? longestStreak,
    DateTime? lastReadDate,
    int? totalReadingTimeMinutes,
    List<int>? chaptersCompleted,
    List<int>? versesRead,
    List<int>? scenariosExplored,
    int? totalBookmarks,
    int? totalJournalEntries,
    List<String>? achievementsUnlocked,
    bool? widgetDailyVerseEnabled,
    bool? widgetProgressEnabled,
    bool? widgetBookmarksEnabled,
    ThemePreference? themePreference,
    bool? audioEnabled,
    bool? hapticFeedbackEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userDeviceId: userDeviceId ?? this.userDeviceId,
      readingGoalMinutes: readingGoalMinutes ?? this.readingGoalMinutes,
      notificationTime: notificationTime ?? this.notificationTime,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      preferredFontSize: preferredFontSize ?? this.preferredFontSize,
      readingStreak: readingStreak ?? this.readingStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      totalReadingTimeMinutes: totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
      chaptersCompleted: chaptersCompleted ?? this.chaptersCompleted,
      versesRead: versesRead ?? this.versesRead,
      scenariosExplored: scenariosExplored ?? this.scenariosExplored,
      totalBookmarks: totalBookmarks ?? this.totalBookmarks,
      totalJournalEntries: totalJournalEntries ?? this.totalJournalEntries,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      widgetDailyVerseEnabled: widgetDailyVerseEnabled ?? this.widgetDailyVerseEnabled,
      widgetProgressEnabled: widgetProgressEnabled ?? this.widgetProgressEnabled,
      widgetBookmarksEnabled: widgetBookmarksEnabled ?? this.widgetBookmarksEnabled,
      themePreference: themePreference ?? this.themePreference,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Returns formatted notification time
  String get formattedNotificationTime {
    final hour = notificationTime.hour.toString().padLeft(2, '0');
    final minute = notificationTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Returns reading progress percentage (0.0 to 1.0)
  double get readingProgressPercentage {
    const totalChapters = 18; // Bhagavad Gita has 18 chapters
    return chaptersCompleted.length / totalChapters;
  }

  /// Returns true if user has an active reading streak
  bool get hasActiveStreak => readingStreak > 0;

  /// Returns true if user read today
  bool get readToday {
    if (lastReadDate == null) return false;
    final today = DateTime.now();
    final lastRead = lastReadDate!;
    return lastRead.year == today.year &&
           lastRead.month == today.month &&
           lastRead.day == today.day;
  }

  /// Returns achievement progress summary
  Map<String, int> get achievementSummary {
    return {
      'chaptersCompleted': chaptersCompleted.length,
      'versesRead': versesRead.length,
      'scenarios': scenariosExplored.length,
      'bookmarks': totalBookmarks,
      'journal': totalJournalEntries,
      'achievements': achievementsUnlocked.length,
      'streak': readingStreak,
      'longestStreak': longestStreak,
      'totalTime': totalReadingTimeMinutes,
    };
  }

  /// Returns true if settings are valid
  bool get isValid => 
      id.isNotEmpty && 
      userDeviceId.isNotEmpty &&
      readingGoalMinutes > 0;

  @override
  String toString() {
    return 'UserSettings(id: $id, device: $userDeviceId, streak: $readingStreak, chapters: ${chaptersCompleted.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.id == id &&
        other.userDeviceId == userDeviceId;
  }

  @override
  int get hashCode {
    return Object.hash(id, userDeviceId);
  }
}