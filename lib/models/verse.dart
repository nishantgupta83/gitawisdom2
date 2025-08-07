
// lib/models/verse.dart

/// ---------------------------------------------
/// MODEL: Verse
/// ---------------------------------------------
/// Represents a single verse from the Bhagavad Gita.
/// Stored in the `gita_verses` table with the following columns:
///   • gv_verse_id (int): The verse number within the chapter.
///   • gv_description (String): The full text of the verse.
///
/// Provides JSON serialization for seamless Supabase integration.

class Verse {
  /// The verse number within its chapter.
  final int verseId;

  /// The text content of the verse.
  final String description;

  /// Constructs a [Verse] instance.
  Verse({
    required this.verseId,
    required this.description,
  });

  /// Creates a [Verse] from a JSON map returned by Supabase.
  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      verseId: json['gv_verses_id'] as int,
      description: json['gv_verses'] as String,
    );
  }

  /// Converts this [Verse] to a JSON map suitable for Supabase.
  Map<String, dynamic> toJson() => {
        'gv_verses_id': verseId,
        'gv_verses': description,
      };
}
