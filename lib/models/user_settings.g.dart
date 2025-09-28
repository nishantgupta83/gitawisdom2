// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 11;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      id: fields[0] as String,
      userDeviceId: fields[1] as String,
      readingGoalMinutes: fields[2] as int,
      notificationTime: fields[3] as DateTime?,
      notificationEnabled: fields[4] as bool,
      preferredFontSize: fields[5] as FontSize,
      readingStreak: fields[6] as int,
      longestStreak: fields[7] as int,
      lastReadDate: fields[8] as DateTime?,
      totalReadingTimeMinutes: fields[9] as int,
      chaptersCompleted: (fields[10] as List).cast<int>(),
      versesRead: (fields[11] as List).cast<int>(),
      scenariosExplored: (fields[12] as List).cast<int>(),
      totalBookmarks: fields[13] as int,
      totalJournalEntries: fields[14] as int,
      achievementsUnlocked: (fields[15] as List).cast<String>(),
      widgetDailyVerseEnabled: fields[16] as bool,
      widgetProgressEnabled: fields[17] as bool,
      widgetBookmarksEnabled: fields[18] as bool,
      themePreference: fields[19] as ThemePreference,
      audioEnabled: fields[20] as bool,
      hapticFeedbackEnabled: fields[21] as bool,
      createdAt: fields[22] as DateTime,
      updatedAt: fields[23] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userDeviceId)
      ..writeByte(2)
      ..write(obj.readingGoalMinutes)
      ..writeByte(3)
      ..write(obj.notificationTime)
      ..writeByte(4)
      ..write(obj.notificationEnabled)
      ..writeByte(5)
      ..write(obj.preferredFontSize)
      ..writeByte(6)
      ..write(obj.readingStreak)
      ..writeByte(7)
      ..write(obj.longestStreak)
      ..writeByte(8)
      ..write(obj.lastReadDate)
      ..writeByte(9)
      ..write(obj.totalReadingTimeMinutes)
      ..writeByte(10)
      ..write(obj.chaptersCompleted)
      ..writeByte(11)
      ..write(obj.versesRead)
      ..writeByte(12)
      ..write(obj.scenariosExplored)
      ..writeByte(13)
      ..write(obj.totalBookmarks)
      ..writeByte(14)
      ..write(obj.totalJournalEntries)
      ..writeByte(15)
      ..write(obj.achievementsUnlocked)
      ..writeByte(16)
      ..write(obj.widgetDailyVerseEnabled)
      ..writeByte(17)
      ..write(obj.widgetProgressEnabled)
      ..writeByte(18)
      ..write(obj.widgetBookmarksEnabled)
      ..writeByte(19)
      ..write(obj.themePreference)
      ..writeByte(20)
      ..write(obj.audioEnabled)
      ..writeByte(21)
      ..write(obj.hapticFeedbackEnabled)
      ..writeByte(22)
      ..write(obj.createdAt)
      ..writeByte(23)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
