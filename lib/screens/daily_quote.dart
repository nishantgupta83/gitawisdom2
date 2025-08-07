/// lib/models/daily_quote.dart
/// Model for the `daily_quote` table in Supabase.

class DailyQuote {
  /// Primary key in the database
  final String id;                // dq_id

  /// The quote or motivational text
  final String description;    // dq_description

  /// Optional reference: author, book, movie, etc.
  final String? reference;     // dq_reference

  /// When this quote was created (for audit/history)
  final DateTime createdAt;

  DailyQuote({
    required this.id,
    required this.description,
    this.reference,
    required this.createdAt,
  });

  factory DailyQuote.fromJson(Map<String, dynamic> json) {
      // Supabase may return numeric fields as String, so handle both cases
    final rawId = json['dq_id'];
    final intId = rawId is int
      ? rawId
      : int.tryParse(rawId.toString()) ?? (throw Exception('Invalid dq_id: $rawId'));
    return DailyQuote(
      id: json['dq_id'] as String,
      description: json['dq_description'] as String,
      reference: json['dq_reference'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'dq_id': id,
        'dq_description': description,
        'dq_reference': reference,
        'created_at': createdAt.toIso8601String(),
      };
}



