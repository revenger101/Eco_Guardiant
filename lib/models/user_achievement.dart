/// Model class for user achievements
/// Tracks which achievements each user has unlocked and when
class UserAchievement {
  final int? id;
  final int userId;
  final int achievementId;
  final DateTime unlockedAt;
  final int progress; // Current progress towards achievement (0-100%)

  UserAchievement({
    this.id,
    required this.userId,
    required this.achievementId,
    DateTime? unlockedAt,
    this.progress = 0,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  /// Convert UserAchievement to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'achievementId': achievementId,
      'unlockedAt': unlockedAt.toIso8601String(),
      'progress': progress,
    };
  }

  /// Create UserAchievement from Map (database query result)
  factory UserAchievement.fromMap(Map<String, dynamic> map) {
    return UserAchievement(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      achievementId: map['achievementId'] as int,
      unlockedAt: DateTime.parse(map['unlockedAt'] as String),
      progress: map['progress'] as int? ?? 0,
    );
  }

  /// Create a copy of UserAchievement with updated fields
  UserAchievement copyWith({
    int? id,
    int? userId,
    int? achievementId,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  /// Check if achievement is unlocked (progress >= 100)
  bool get isUnlocked => progress >= 100;

  @override
  String toString() {
    return 'UserAchievement(id: $id, userId: $userId, achievementId: $achievementId, '
        'progress: $progress%, isUnlocked: $isUnlocked)';
  }
}

