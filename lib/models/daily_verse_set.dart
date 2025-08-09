import 'package:hive/hive.dart';
import 'verse.dart';

part 'daily_verse_set.g.dart';

@HiveType(typeId: 2)
class DailyVerseSet extends HiveObject {
  @HiveField(0)
  final String date; // Format: YYYY-MM-DD

  @HiveField(1)
  final List<Verse> verses;

  @HiveField(2)
  final List<int> chapterIds;

  @HiveField(3)
  final DateTime createdAt;

  DailyVerseSet({
    required this.date,
    required this.verses,
    required this.chapterIds,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Helper method to check if this verse set is for today
  bool get isToday {
    final today = DateTime.now();
    final todayString = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    return date == todayString;
  }

  // Helper method to get formatted date string for today
  static String getTodayString() {
    final today = DateTime.now();
    return '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
  }

  // Factory method to create verse set for today
  factory DailyVerseSet.forToday({
    required List<Verse> verses,
    required List<int> chapterIds,
  }) {
    return DailyVerseSet(
      date: getTodayString(),
      verses: verses,
      chapterIds: chapterIds,
    );
  }

  @override
  String toString() {
    return 'DailyVerseSet{date: $date, verses: ${verses.length}, chapters: $chapterIds}';
  }
}