// lib/models/annotation.dart

import 'package:hive/hive.dart';

part 'annotation.g.dart';

@HiveType(typeId: 5)
class Annotation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String verseId; // chapterId.verseId format

  @HiveField(2)
  final String selectedText;

  @HiveField(3)
  final int startIndex;

  @HiveField(4)
  final int endIndex;

  @HiveField(5)
  final String highlightColor;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  Annotation({
    required this.id,
    required this.verseId,
    required this.selectedText,
    required this.startIndex,
    required this.endIndex,
    required this.highlightColor,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verseId': verseId,
      'selectedText': selectedText,
      'startIndex': startIndex,
      'endIndex': endIndex,
      'highlightColor': highlightColor,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'],
      verseId: json['verseId'],
      selectedText: json['selectedText'],
      startIndex: json['startIndex'],
      endIndex: json['endIndex'],
      highlightColor: json['highlightColor'],
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Annotation copyWith({
    String? id,
    String? verseId,
    String? selectedText,
    int? startIndex,
    int? endIndex,
    String? highlightColor,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Annotation(
      id: id ?? this.id,
      verseId: verseId ?? this.verseId,
      selectedText: selectedText ?? this.selectedText,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      highlightColor: highlightColor ?? this.highlightColor,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Predefined highlight colors
class HighlightColors {
  static const String yellow = '#FFF59D';
  static const String green = '#C8E6C9';
  static const String blue = '#BBDEFB';
  static const String pink = '#F8BBD9';
  static const String orange = '#FFE0B2';
  static const String purple = '#E1BEE7';

  static const List<String> colors = [
    yellow,
    green,
    blue,
    pink,
    orange,
    purple,
  ];

  static const Map<String, String> colorNames = {
    yellow: 'Yellow',
    green: 'Green',
    blue: 'Blue',
    pink: 'Pink',
    orange: 'Orange',
    purple: 'Purple',
  };
}