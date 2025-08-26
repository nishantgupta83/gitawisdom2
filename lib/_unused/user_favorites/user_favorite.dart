// lib/models/user_favorite.dart

import 'package:hive/hive.dart';

part 'user_favorite.g.dart';

@HiveType(typeId: 6)
class UserFavorite extends HiveObject {
  @HiveField(0)
  final String scenarioTitle;

  @HiveField(1)
  final DateTime favoritedAt;

  UserFavorite({
    required this.scenarioTitle,
    DateTime? favoritedAt,
  }) : favoritedAt = favoritedAt ?? DateTime.now();

  /// Factory constructor for creating from JSON (Supabase data)
  factory UserFavorite.fromJson(Map<String, dynamic> json) {
    return UserFavorite(
      scenarioTitle: json['scenario_title'] as String,
      favoritedAt: DateTime.parse(json['favorited_at'] as String),
    );
  }

  /// Convert to JSON for Supabase storage
  Map<String, dynamic> toJson() => {
        'scenario_title': scenarioTitle,
        'favorited_at': favoritedAt.toIso8601String(),
      };
}