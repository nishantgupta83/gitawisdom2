

/// Model for a scenario, matching the `scenarios` table.
class Scenario {
  final String title;           // sc_title
  final String description;     // sc_description
  final String category;        // sc_category
  final int chapter;            // sc_chapter
  final String heartResponse;   // sc_heart_response
  final String dutyResponse;    // sc_duty_response
  final String gitaWisdom;      // sc_gita_wisdom
  final String? verse;          // sc_verse
  final String? verseNumber;    // sc_verse_number (text)
  final List<String>? tags;     // sc_tags
  final List<String>? actionSteps; // sc_action_steps
  final DateTime createdAt;     // created_at timestamp

  Scenario({
    required this.title,
    required this.description,
    required this.category,
    required this.chapter,
    required this.heartResponse,
    required this.dutyResponse,
    required this.gitaWisdom,
    this.verse,
    this.verseNumber,
    this.tags,
    this.actionSteps,
    required this.createdAt,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      title: json['sc_title'] as String,
      description: json['sc_description'] as String,
      category: json['sc_category'] as String,
      chapter: json['sc_chapter'] as int,
      heartResponse: json['sc_heart_response'] as String,
      dutyResponse: json['sc_duty_response'] as String,
      gitaWisdom: json['sc_gita_wisdom'] as String,
      verse: json['sc_verse'] as String?,
      verseNumber: json['sc_verse_number'] as String?,
      tags: (json['sc_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      actionSteps: (json['sc_action_steps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'sc_title': title,
        'sc_description': description,
        'sc_category': category,
        'sc_chapter': chapter,
        'sc_heart_response': heartResponse,
        'sc_duty_response': dutyResponse,
        'sc_gita_wisdom': gitaWisdom,
        'sc_verse': verse,
        'sc_verse_number': verseNumber,
        'sc_tags': tags,
        'sc_action_steps': actionSteps,
        'created_at': createdAt.toIso8601String(),
      };
}
