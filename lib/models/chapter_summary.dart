// lib/models/chapter_summary.dart

import 'package:hive/hive.dart';

part 'chapter_summary.g.dart';

@HiveType(typeId: 3)
class ChapterSummary extends HiveObject {
  @HiveField(0)
  final int chapterId;     // cs_chapter_id
  
  @HiveField(1)
  final String title;      // cs_title
  
  @HiveField(2)
  final String? subtitle;  // cs_subtitle
  
  @HiveField(3)
  final int scenarioCount; // cs_scenario_count
  
  @HiveField(4)
  final int verseCount;    // cs_verse_count

  ChapterSummary({
    required this.chapterId,
    required this.title,
    this.subtitle,
    required this.scenarioCount,
    required this.verseCount,
  });

  factory ChapterSummary.fromJson(Map<String, dynamic> json) {
    return ChapterSummary(
      chapterId: json['cs_chapter_id'] is int
          ? json['cs_chapter_id'] as int
          : int.parse(json['cs_chapter_id'].toString()),
      title: json['cs_title'] as String,
      subtitle: json['cs_subtitle'] as String?,
      scenarioCount: json['cs_scenario_count'] is int
          ? json['cs_scenario_count'] as int
          : int.parse(json['cs_scenario_count'].toString()),
      verseCount: json['cs_verse_count'] is int
          ? json['cs_verse_count'] as int
          : int.parse(json['cs_verse_count'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'cs_chapter_id': chapterId,
        'cs_title': title,
        'cs_subtitle': subtitle,
        'cs_scenario_count': scenarioCount,
        'cs_verse_count': verseCount,
      };
}
