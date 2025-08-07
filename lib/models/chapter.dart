// lib/models/chapter.dart

import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 1)
class Chapter extends HiveObject {
  @HiveField(0)
  final int chapterId;              // ch_chapter_id

  @HiveField(1)
  final String title;               // ch_title

  @HiveField(2)
  final String? subtitle;           // ch_subtitle

  @HiveField(3)
  final String? summary;            // ch_summary

  @HiveField(4)
  final int? verseCount;            // ch_verse_count

  @HiveField(5)
  final String? theme;              // ch_theme

  @HiveField(6)
  final List<String>? keyTeachings; // ch_key_teachings

  Chapter({
    required this.chapterId,
    required this.title,
    this.subtitle,
    this.summary,
    this.verseCount,
    this.theme,
    this.keyTeachings,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['ch_chapter_id'] as int,
      title: json['ch_title'] as String,
      subtitle: json['ch_subtitle'] as String?,
      summary: json['ch_summary'] as String?,
      verseCount: json['ch_verse_count'] as int?,
      theme: json['ch_theme'] as String?,
      keyTeachings: (json['ch_key_teachings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ch_chapter_id': chapterId,
      'ch_title': title,
      'ch_subtitle': subtitle,
      'ch_summary': summary,
      'ch_verse_count': verseCount,
      'ch_theme': theme,
      'ch_key_teachings': keyTeachings,
    };
  }
}
