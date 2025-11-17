/// Model class for leaderboard entries
/// Represents a user's ranking on the leaderboard
class LeaderboardEntry {
  final int rank;
  final int userId;
  final String userName;
  final int totalPoints;
  final int currentLevel;
  final int achievementsUnlocked;
  final int gamesPlayed;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.totalPoints,
    required this.currentLevel,
    required this.achievementsUnlocked,
    required this.gamesPlayed,
  });

  /// Create LeaderboardEntry from Map (database query result)
  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, int rank) {
    return LeaderboardEntry(
      rank: rank,
      userId: map['userId'] as int,
      userName: map['userName'] as String,
      totalPoints: map['totalPoints'] as int,
      currentLevel: map['currentLevel'] as int,
      achievementsUnlocked: map['achievementsUnlocked'] as int? ?? 0,
      gamesPlayed: map['gamesPlayed'] as int? ?? 0,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'rank': rank,
      'userId': userId,
      'userName': userName,
      'totalPoints': totalPoints,
      'currentLevel': currentLevel,
      'achievementsUnlocked': achievementsUnlocked,
      'gamesPlayed': gamesPlayed,
    };
  }

  @override
  String toString() {
    return 'LeaderboardEntry(rank: $rank, userName: $userName, '
        'totalPoints: $totalPoints, level: $currentLevel)';
  }
}

