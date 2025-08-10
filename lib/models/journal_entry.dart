// lib/models/journal_entry.dart

import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String reflection;

  @HiveField(2)
  final int rating;

  @HiveField(3)
  final DateTime dateCreated;

  @HiveField(4)
  final int? scenarioId;   // Link to specific scenario

  @HiveField(5)
  final String category;   // e.g., "Personal Growth", "Meditation", "Daily Reflection"

  JournalEntry({
    required this.id,
    required this.reflection,
    required this.rating,
    required this.dateCreated,
    this.scenarioId,
    this.category = 'General',
  });

  /// Factory constructor for creating from JSON (Supabase data)
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['je_id'] as String,
      reflection: json['je_reflection'] as String,
      rating: json['je_rating'] as int,
      dateCreated: DateTime.parse(json['je_date_created'] as String),
      scenarioId: json['je_scenario_id'] as int?, // May be null in existing records
      category: json['je_category'] as String? ?? 'General', // Default if missing
    );
  }

  /// Convert to JSON for Supabase storage
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'je_id': id,
      'je_reflection': reflection,
      'je_rating': rating,
      'je_date_created': dateCreated.toIso8601String(),
      'je_category': category,
    };
    
    // Include scenario ID if present
    if (scenarioId != null) {
      json['je_scenario_id'] = scenarioId;
    }
    
    return json;
  }

  /// Create entry with current timestamp
  factory JournalEntry.create({
    required String reflection,
    required int rating,
    int? scenarioId,
    String category = 'General',
  }) {
    return JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reflection: reflection,
      rating: rating,
      dateCreated: DateTime.now(),
      scenarioId: scenarioId,
      category: category,
    );
  }
}
