
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

/// ---------------------------------------------
/// MULTILINGUAL EXTENSIONS FOR VERSE
/// ---------------------------------------------

extension VerseMultilingualExtensions on Verse {
  /// Creates a Verse from multilingual RPC function response with fallback
  static Verse fromMultilingualJson(Map<String, dynamic> json) {
    return Verse(
      verseId: json['gv_verses_id'] as int,
      description: json['gv_verses'] as String,
      chapterId: json['gv_chapter_id'] as int?,
    );
  }

  /// Converts to JSON for multilingual translation tables
  Map<String, dynamic> toTranslationJson(String langCode, {
    String? translation,
    String? commentary,
  }) {
    return {
      'verse_id': verseId,
      'chapter_id': chapterId,
      'lang_code': langCode,
      'description': description,
      'translation': translation,
      'commentary': commentary,
    };
  }

  /// Creates Verse from verse_translations table response
  static Verse fromTranslationJson(Map<String, dynamic> json) {
    return Verse(
      verseId: json['verse_id'] as int,
      description: json['description'] as String,
      chapterId: json['chapter_id'] as int,
    );
  }

  /// Returns true if this verse has translation data
  bool get hasTranslationData => description.isNotEmpty;

  /// Creates a copy with updated translation fields
  Verse withTranslation({
    String? description,
    String? translation,
    String? commentary,
  }) {
    return Verse(
      verseId: verseId,
      description: description ?? this.description,
      chapterId: chapterId,
    );
  }

  /// Returns verse reference in the format "Chapter.Verse"
  String get reference {
    if (chapterId != null) {
      return '$chapterId.$verseId';
    }
    return verseId.toString();
  }

  /// Returns true if this is a valid verse (has required fields)
  bool get isValid => verseId > 0 && description.isNotEmpty;

  /// Returns a shortened version of the verse for previews
  String get preview {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }
}
