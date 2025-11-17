/// Model class for user game statistics
/// Tracks overall game progress, points, level, and achievements for each user
class GameStats {
  final int? id;
  final int userId;
  final int totalPoints;
  final int currentLevel;
  final int gamesPlayed;
  final int achievementsUnlocked;
  final DateTime createdAt;
  final DateTime lastPlayed;

  GameStats({
    this.id,
    required this.userId,
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.gamesPlayed = 0,
    this.achievementsUnlocked = 0,
    DateTime? createdAt,
    DateTime? lastPlayed,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastPlayed = lastPlayed ?? DateTime.now();

  /// Convert GameStats to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'totalPoints': totalPoints,
      'currentLevel': currentLevel,
      'gamesPlayed': gamesPlayed,
      'achievementsUnlocked': achievementsUnlocked,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  /// Create GameStats from Map (database query result)
  factory GameStats.fromMap(Map<String, dynamic> map) {
    return GameStats(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      totalPoints: map['totalPoints'] as int? ?? 0,
      currentLevel: map['currentLevel'] as int? ?? 1,
      gamesPlayed: map['gamesPlayed'] as int? ?? 0,
      achievementsUnlocked: map['achievementsUnlocked'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastPlayed: DateTime.parse(map['lastPlayed'] as String),
    );
  }

  /// Create a copy of GameStats with updated fields
  GameStats copyWith({
    int? id,
    int? userId,
    int? totalPoints,
    int? currentLevel,
    int? gamesPlayed,
    int? achievementsUnlocked,
    DateTime? createdAt,
    DateTime? lastPlayed,
  }) {
    return GameStats(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      createdAt: createdAt ?? this.createdAt,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  /// Calculate level based on total points
  /// Level thresholds: Level 1: 0-99, Level 2: 100-249, Level 3: 250-499, etc.
  static int calculateLevel(int points) {
    if (points < 100) return 1;
    if (points < 250) return 2;
    if (points < 500) return 3;
    if (points < 1000) return 4;
    if (points < 2000) return 5;
    if (points < 3500) return 6;
    if (points < 5500) return 7;
    if (points < 8000) return 8;
    if (points < 11000) return 9;
    return 10; // Max level
  }

  /// Get points needed for next level
  static int pointsForNextLevel(int currentLevel) {
    switch (currentLevel) {
      case 1:
        return 100;
      case 2:
        return 250;
      case 3:
        return 500;
      case 4:
        return 1000;
      case 5:
        return 2000;
      case 6:
        return 3500;
      case 7:
        return 5500;
      case 8:
        return 8000;
      case 9:
        return 11000;
      default:
        return 11000; // Max level reached
    }
  }

  /// Get progress percentage to next level
  double getProgressToNextLevel() {
    if (currentLevel >= 10) return 100.0; // Max level

    final currentThreshold = currentLevel == 1 ? 0 : pointsForNextLevel(currentLevel - 1);
    final nextThreshold = pointsForNextLevel(currentLevel);
    final pointsInCurrentLevel = totalPoints - currentThreshold;
    final pointsNeededForLevel = nextThreshold - currentThreshold;

    return (pointsInCurrentLevel / pointsNeededForLevel * 100).clamp(0.0, 100.0);
  }

  @override
  String toString() {
    return 'GameStats(id: $id, userId: $userId, totalPoints: $totalPoints, '
        'currentLevel: $currentLevel, gamesPlayed: $gamesPlayed, '
        'achievementsUnlocked: $achievementsUnlocked)';
  }
}

