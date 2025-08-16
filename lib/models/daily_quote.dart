// lib/models/daily_quote.dart

import 'package:hive/hive.dart';

part 'daily_quote.g.dart';

/// ---------------------------------------------
/// MODEL: DailyQuote
/// ---------------------------------------------
/// Represents a daily quote from the Bhagavad Gita or spiritual wisdom.
/// Stored in the `daily_quote` table with multilingual support.

@HiveType(typeId: 11) // Use typeId 11 to avoid conflicts
class DailyQuote extends HiveObject {
  /// Primary key in the database
  @HiveField(0)
  final String id; // dq_id

  /// The quote or motivational text
  @HiveField(1)
  final String description; // dq_description

  /// Optional reference: author, book, movie, etc.
  @HiveField(2)
  final String? reference; // dq_reference

  /// When this quote was created (for audit/history)
  @HiveField(3)
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
        : int.tryParse(rawId.toString()) ??
            (throw Exception('Invalid dq_id: $rawId'));
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

/// ---------------------------------------------
/// MULTILINGUAL EXTENSIONS FOR DAILY QUOTE
/// ---------------------------------------------

extension DailyQuoteMultilingualExtensions on DailyQuote {
  /// Creates a DailyQuote from multilingual RPC function response with fallback
  static DailyQuote fromMultilingualJson(Map<String, dynamic> json) {
    return DailyQuote(
      id: json['dq_id'] as String,
      description: json['dq_description'] as String,
      reference: json['dq_reference'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts to JSON for multilingual translation tables
  Map<String, dynamic> toTranslationJson(String langCode) {
    return {
      'quote_id': id,
      'lang_code': langCode,
      'description': description,
      'reference': reference,
    };
  }

  /// Creates DailyQuote from daily_quote_translations table response
  /// Note: This requires the original created_at to be provided separately
  static DailyQuote fromTranslationJson(
      Map<String, dynamic> json, String quoteId, DateTime createdAt) {
    return DailyQuote(
      id: quoteId, // Original quote ID
      description: json['description'] as String,
      reference: json['reference'] as String?,
      createdAt: createdAt, // Original creation time
    );
  }

  /// Returns true if this quote has translation data
  bool get hasTranslationData =>
      description.isNotEmpty && description.length > 10;

  /// Creates a copy with updated translation fields
  DailyQuote withTranslation({
    String? description,
    String? reference,
  }) {
    return DailyQuote(
      id: id,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      createdAt: createdAt,
    );
  }

  /// Returns a shortened version of the quote for previews
  String get preview {
    if (description.length <= 150) return description;
    return '${description.substring(0, 147)}...';
  }

  /// Returns the word count of the quote
  int get wordCount => description.split(RegExp(r'\s+')).length;

  /// Returns true if this is a short quote (good for notifications)
  bool get isShortQuote => wordCount <= 20 && description.length <= 120;

  /// Returns true if this is a long quote (good for reflection)
  bool get isLongQuote => wordCount > 50 || description.length > 300;

  /// Returns the quote category based on content analysis
  String get suggestedCategory {
    final lowerDesc = description.toLowerCase();
    
    if (lowerDesc.contains(RegExp(r'\b(karma|action|duty|work)\b'))) {
      return 'Karma & Action';
    } else if (lowerDesc.contains(RegExp(r'\b(devotion|love|surrender|faith)\b'))) {
      return 'Devotion & Faith';
    } else if (lowerDesc.contains(RegExp(r'\b(knowledge|wisdom|understanding|truth)\b'))) {
      return 'Knowledge & Wisdom';
    } else if (lowerDesc.contains(RegExp(r'\b(peace|calm|meditation|mind)\b'))) {
      return 'Peace & Meditation';
    } else if (lowerDesc.contains(RegExp(r'\b(dharma|righteous|moral|virtue)\b'))) {
      return 'Dharma & Virtue';
    } else {
      return 'General Wisdom';
    }
  }

  /// Returns the estimated reading time in seconds
  int get estimatedReadingTimeSeconds {
    // Average reading speed: 200 words per minute
    final wordsPerSecond = 200 / 60;
    return (wordCount / wordsPerSecond).ceil();
  }
}

/// ---------------------------------------------
/// EXTENSIONS FOR LIST<DAILY_QUOTE>
/// ---------------------------------------------

extension DailyQuoteListExtensions on List<DailyQuote> {
  /// Returns quotes sorted by creation date (newest first)
  List<DailyQuote> get sortedByDate =>
      [...this]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Returns quotes sorted by length (shortest first)
  List<DailyQuote> get sortedByLength =>
      [...this]..sort((a, b) => a.description.length.compareTo(b.description.length));

  /// Returns only short quotes suitable for notifications
  List<DailyQuote> get shortQuotesOnly =>
      where((quote) => quote.isShortQuote).toList();

  /// Returns only long quotes suitable for deep reflection
  List<DailyQuote> get longQuotesOnly =>
      where((quote) => quote.isLongQuote).toList();

  /// Returns quotes that contain any of the given keywords
  List<DailyQuote> searchByKeywords(List<String> keywords) {
    return where((quote) {
      final lowerDesc = quote.description.toLowerCase();
      return keywords.any((keyword) => 
          lowerDesc.contains(keyword.toLowerCase()));
    }).toList();
  }

  /// Groups quotes by their suggested categories
  Map<String, List<DailyQuote>> get groupedByCategory {
    final Map<String, List<DailyQuote>> grouped = {};
    for (final quote in this) {
      final category = quote.suggestedCategory;
      grouped[category] = [...(grouped[category] ?? []), quote];
    }
    return grouped;
  }

  /// Returns a random quote from the list
  DailyQuote? get randomQuote {
    if (isEmpty) return null;
    final now = DateTime.now();
    final index = now.millisecondsSinceEpoch % length;
    return this[index];
  }

  /// Returns quotes that have complete translation data
  List<DailyQuote> get withCompleteTranslations =>
      where((quote) => quote.hasTranslationData).toList();

  /// Returns the average word count across all quotes
  double get averageWordCount {
    if (isEmpty) return 0.0;
    final totalWords = map((quote) => quote.wordCount).reduce((a, b) => a + b);
    return totalWords / length;
  }
}