// lib/models/search_result.dart

import 'package:hive/hive.dart';

part 'search_result.g.dart';

/// Search types that can be searched
enum SearchType {
  verse,
  chapter,
  scenario,
  query;

  String get value => name;

  static SearchType fromString(String value) {
    return SearchType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SearchType.verse,
    );
  }
}

@HiveType(typeId: 12)
class SearchResult extends HiveObject {
  /// Unique identifier for the search result
  @HiveField(0)
  final String id;

  /// Search query that produced this result
  @HiveField(1)
  final String searchQuery;

  /// Type of search result
  @HiveField(2)
  final SearchType resultType;

  /// Display title of the result
  @HiveField(3)
  final String title;

  /// Full text content
  @HiveField(4)
  final String content;

  /// Search snippet with highlighting
  @HiveField(5)
  final String snippet;

  /// Chapter ID (nullable for non-verse results)
  @HiveField(6)
  final int? chapterId;

  /// Verse ID (nullable for non-verse results)
  @HiveField(7)
  final int? verseId;

  /// Scenario ID (nullable for non-scenario results)
  @HiveField(8)
  final int? scenarioId;

  /// Search relevance score
  @HiveField(9)
  final double relevanceScore;

  /// When the search was performed
  @HiveField(10)
  final DateTime searchDate;

  /// Additional metadata
  @HiveField(11)
  final Map<String, dynamic> metadata;

  SearchResult({
    required this.id,
    required this.searchQuery,
    required this.resultType,
    required this.title,
    required this.content,
    required this.snippet,
    this.chapterId,
    this.verseId,
    this.scenarioId,
    required this.relevanceScore,
    required this.searchDate,
    this.metadata = const {},
  });

  /// Creates a SearchResult from Supabase JSON response
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] as String,
      searchQuery: json['search_query'] as String? ?? '',
      resultType: SearchType.fromString(json['result_type'] as String? ?? 'verse'),
      title: json['title'] as String,
      content: json['content'] as String,
      snippet: json['snippet'] as String? ?? '',
      chapterId: json['chapter_id'] as int?,
      verseId: json['verse_id'] as int?,
      scenarioId: json['scenario_id'] as int?,
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
      searchDate: json['search_date'] != null 
          ? DateTime.parse(json['search_date'] as String)
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts search result to JSON for Supabase storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'search_query': searchQuery,
      'result_type': resultType.value,
      'title': title,
      'content': content,
      'snippet': snippet,
      if (chapterId != null) 'chapter_id': chapterId,
      if (verseId != null) 'verse_id': verseId,
      if (scenarioId != null) 'scenario_id': scenarioId,
      'relevance_score': relevanceScore,
      'search_date': searchDate.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'SearchResult(id: $id, query: $searchQuery, type: $resultType, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResult &&
        other.id == id &&
        other.searchQuery == searchQuery &&
        other.resultType == resultType;
  }

  @override
  int get hashCode => Object.hash(id, searchQuery, resultType);
}