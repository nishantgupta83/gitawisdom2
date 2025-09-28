// lib/models/bookmark.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bookmark.g.dart';

/// Bookmark types supported by the app
enum BookmarkType {
  verse,
  chapter,
  scenario;

  String get value => name;

  static BookmarkType fromString(String value) {
    return BookmarkType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BookmarkType.verse,
    );
  }
}

/// Available highlight colors for bookmarks
enum HighlightColor {
  yellow,
  green,
  blue,
  pink,
  purple;

  String get value => name;

  static HighlightColor fromString(String value) {
    return HighlightColor.values.firstWhere(
      (color) => color.value == value,
      orElse: () => HighlightColor.yellow,
    );
  }
}

/// Sync status for offline/online bookmarks
enum SyncStatus {
  synced,
  pending,
  offline;

  String get value => name;

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SyncStatus.offline,
    );
  }
}

@HiveType(typeId: 9)
class Bookmark extends HiveObject {
  /// Unique identifier for the bookmark
  @HiveField(0)
  final String id;

  /// Device identifier for offline sync
  @HiveField(1)
  final String userDeviceId;

  /// Type of content being bookmarked
  @HiveField(2)
  final BookmarkType bookmarkType;

  /// ID reference to the specific content (verse_id, chapter_id, scenario_id)
  @HiveField(3)
  final int referenceId;

  /// Chapter ID for grouping and widget display
  @HiveField(4)
  final int chapterId;

  /// Display title for quick reference
  @HiveField(5)
  final String title;

  /// First 100 chars for iOS widget and quick display
  @HiveField(6)
  final String? contentPreview;

  /// User's personal notes on the bookmark
  @HiveField(7)
  final String? notes;

  /// User-defined tags for organization
  @HiveField(8)
  final List<String> tags;

  /// Whether text is highlighted
  @HiveField(9)
  final bool isHighlighted;

  /// Color used for highlighting
  @HiveField(10)
  final HighlightColor highlightColor;

  /// When the bookmark was created
  @HiveField(11)
  final DateTime createdAt;

  /// When the bookmark was last updated
  @HiveField(12)
  final DateTime updatedAt;

  /// Sync status for offline/online management
  @HiveField(13)
  final SyncStatus syncStatus;

  Bookmark({
    required this.id,
    required this.userDeviceId,
    required this.bookmarkType,
    required this.referenceId,
    required this.chapterId,
    required this.title,
    this.contentPreview,
    this.notes,
    this.tags = const [],
    this.isHighlighted = false,
    this.highlightColor = HighlightColor.yellow,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.offline,
  });

  /// Creates a Bookmark from Supabase JSON response
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      userDeviceId: json['user_device_id'] as String,
      bookmarkType: BookmarkType.fromString(json['bookmark_type'] as String),
      referenceId: json['reference_id'] as int,
      chapterId: json['chapter_id'] as int,
      title: json['title'] as String,
      contentPreview: json['content_preview'] as String?,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isHighlighted: json['is_highlighted'] as bool? ?? false,
      highlightColor: HighlightColor.fromString(
        json['highlight_color'] as String? ?? 'yellow',
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: SyncStatus.fromString(
        json['sync_status'] as String? ?? 'synced',
      ),
    );
  }

  /// Converts bookmark to JSON for Supabase storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_device_id': userDeviceId,
      'bookmark_type': bookmarkType.value,
      'reference_id': referenceId,
      'chapter_id': chapterId,
      'title': title,
      'content_preview': contentPreview,
      'notes': notes,
      'tags': tags,
      'is_highlighted': isHighlighted,
      'highlight_color': highlightColor.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus.value,
    };
  }

  /// Creates a new bookmark with current timestamp
  factory Bookmark.create({
    required String userDeviceId,
    required BookmarkType bookmarkType,
    required int referenceId,
    required int chapterId,
    required String title,
    String? contentPreview,
    String? notes,
    List<String> tags = const [],
    bool isHighlighted = false,
    HighlightColor highlightColor = HighlightColor.yellow,
  }) {
    final now = DateTime.now();
    const uuid = Uuid();
    return Bookmark(
      id: uuid.v4(), // Generate proper UUID instead of timestamp
      userDeviceId: userDeviceId,
      bookmarkType: bookmarkType,
      referenceId: referenceId,
      chapterId: chapterId,
      title: title,
      contentPreview: contentPreview,
      notes: notes,
      tags: tags,
      isHighlighted: isHighlighted,
      highlightColor: highlightColor,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Creates a copy with updated fields
  Bookmark copyWith({
    String? id,
    String? userDeviceId,
    BookmarkType? bookmarkType,
    int? referenceId,
    int? chapterId,
    String? title,
    String? contentPreview,
    String? notes,
    List<String>? tags,
    bool? isHighlighted,
    HighlightColor? highlightColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Bookmark(
      id: id ?? this.id,
      userDeviceId: userDeviceId ?? this.userDeviceId,
      bookmarkType: bookmarkType ?? this.bookmarkType,
      referenceId: referenceId ?? this.referenceId,
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      contentPreview: contentPreview ?? this.contentPreview,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      highlightColor: highlightColor ?? this.highlightColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Returns true if bookmark needs to be synced
  bool get needsSync => syncStatus != SyncStatus.synced;

  /// Returns true if bookmark is valid
  bool get isValid => 
      id.isNotEmpty && 
      userDeviceId.isNotEmpty && 
      title.isNotEmpty && 
      referenceId > 0 && 
      chapterId > 0;

  /// Returns bookmark reference in format: type:chapter.reference
  String get reference {
    switch (bookmarkType) {
      case BookmarkType.verse:
        return 'verse:$chapterId.$referenceId';
      case BookmarkType.chapter:
        return 'chapter:$referenceId';
      case BookmarkType.scenario:
        return 'scenario:$chapterId.$referenceId';
    }
  }

  @override
  String toString() {
    return 'Bookmark(id: $id, type: $bookmarkType, title: $title, sync: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark &&
        other.id == id &&
        other.userDeviceId == userDeviceId &&
        other.bookmarkType == bookmarkType &&
        other.referenceId == referenceId;
  }

  @override
  int get hashCode {
    return Object.hash(id, userDeviceId, bookmarkType, referenceId);
  }
}