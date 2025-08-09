
// lib/models/verse.dart

import 'package:hive/hive.dart';

part 'verse.g.dart';

/// ---------------------------------------------
/// MODEL: Verse
/// ---------------------------------------------
/// Represents a single verse from the Bhagavad Gita.
/// Stored in the `gita_verses` table with the following columns:
///   • gv_verse_id (int): The verse number within the chapter.
///   • gv_description (String): The full text of the verse.
///
/// Provides JSON serialization for seamless Supabase integration.

@HiveType(typeId: 4)
class Verse extends HiveObject {
  /// The verse number within its chapter.
  @HiveField(0)
  final int verseId;

  /// The text content of the verse.
  @HiveField(1)
  final String description;

  /// The chapter ID this verse belongs to.
  @HiveField(2)
  final int? chapterId;

  /// Constructs a [Verse] instance.
  Verse({
    required this.verseId,
    required this.description,
    this.chapterId,
  });

  /// Creates a [Verse] from a JSON map returned by Supabase.
  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      verseId: json['gv_verses_id'] as int,
      description: json['gv_verses'] as String,
      chapterId: json['gv_chapter_id'] as int?,
    );
  }

  /// Converts this [Verse] to a JSON map suitable for Supabase.
  Map<String, dynamic> toJson() => {
        'gv_verses_id': verseId,
        'gv_verses': description,
        if (chapterId != null) 'gv_chapter_id': chapterId,
      };
}
