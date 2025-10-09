// lib/models/journal_entry.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

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
      id: json['id'] as String,
      reflection: json['reflection'] as String,
      rating: json['rating'] as int,
      dateCreated: DateTime.parse(json['created_at'] as String),
      scenarioId: null, // Scenarios not linked in current schema
      category: json['category'] as String? ?? 'General',
    );
  }

  /// Convert to JSON for Supabase storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reflection': reflection,
      'rating': rating,
      'category': category,
      'created_at': dateCreated.toIso8601String(),
      'sync_status': 'synced',
    };
  }

  /// Create entry with current timestamp
  factory JournalEntry.create({
    required String reflection,
    required int rating,
    int? scenarioId,
    String category = 'General',
  }) {
    const uuid = Uuid();
    return JournalEntry(
      id: uuid.v4(), // Generate proper UUID instead of timestamp
      reflection: reflection,
      rating: rating,
      dateCreated: DateTime.now(),
      scenarioId: scenarioId,
      category: category,
    );
  }
}
