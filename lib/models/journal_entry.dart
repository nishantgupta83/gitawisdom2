// lib/models/journal_entry.dart

/*
import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 2)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int? scenarioId;   // ← now nullable

  @HiveField(2)
  final String reflection;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final int rating;

  @HiveField(5)
  final DateTime dateCreated;

  JournalEntry({
    required this.id,
    this.scenarioId,
    required this.reflection,
    required this.category,
    required this.rating,
    required this.dateCreated,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id:            json['je_id']           as String,
      scenarioId:    json['je_scenario_id']  as int?,        // safe cast
      reflection:    json['je_reflection']   as String,
      category:      json['je_category']     as String,
      rating:        json['je_rating']       as int,
      dateCreated:   DateTime.parse(json['je_date_created'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'je_id':            id,
        'je_scenario_id':   scenarioId,
        'je_reflection':    reflection,
        'je_category':      category,
        'je_rating':        rating,
        'je_date_created':  dateCreated.toIso8601String(),
      };
}


*/

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

  JournalEntry({
    required this.id,
    required this.reflection,
    required this.rating,
    DateTime? dateCreated,
  }) : dateCreated = dateCreated ?? DateTime.now();
}
