// Simple meditation models for Apple compliance
enum MusicTheme {
  meditation,
  nature,
  reading,
  silence,
}

class MeditationSession {
  final String id;
  final DateTime startedAt;
  final int plannedDurationSeconds;
  final int actualDurationSeconds;
  final MusicTheme musicTheme;
  final bool isCompleted;
  final double? userRating;
  final String? notes;

  MeditationSession({
    required this.id,
    required this.startedAt,
    required this.plannedDurationSeconds,
    required this.actualDurationSeconds,
    required this.musicTheme,
    required this.isCompleted,
    this.userRating,
    this.notes,
  });

  factory MeditationSession.create({
    required int durationSeconds,
    required MusicTheme musicTheme,
  }) {
    return MeditationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: DateTime.now(),
      plannedDurationSeconds: durationSeconds,
      actualDurationSeconds: 0,
      musicTheme: musicTheme,
      isCompleted: false,
    );
  }

  MeditationSession copyWith({
    String? id,
    DateTime? startedAt,
    int? plannedDurationSeconds,
    int? actualDurationSeconds,
    MusicTheme? musicTheme,
    bool? isCompleted,
    double? userRating,
    String? notes,
  }) {
    return MeditationSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      plannedDurationSeconds: plannedDurationSeconds ?? this.plannedDurationSeconds,
      actualDurationSeconds: actualDurationSeconds ?? this.actualDurationSeconds,
      musicTheme: musicTheme ?? this.musicTheme,
      isCompleted: isCompleted ?? this.isCompleted,
      userRating: userRating ?? this.userRating,
      notes: notes ?? this.notes,
    );
  }
}