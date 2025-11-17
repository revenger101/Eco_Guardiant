import '../models/game_stats.dart';
import '../models/achievement.dart';
import 'database_helper.dart';
import 'auth_service.dart';

/// Service to manage game progress, points, levels, and statistics
class GameProgressService {
  static final GameProgressService _instance = GameProgressService._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();

  GameProgressService._internal();

  factory GameProgressService() => _instance;

  /// Record game completion and award points
  /// Returns updated GameStats and list of newly unlocked achievements
  Future<Map<String, dynamic>> recordGameCompletion({
    required String gameCategory,
    required int score,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      // Check and save high score
      final previousHighScore = await _dbHelper.getHighScore(currentUser.id!, gameCategory);
      final isNewHighScore = score > previousHighScore;

      if (isNewHighScore) {
        await _dbHelper.saveHighScore(currentUser.id!, gameCategory, score);
      }

      // Add points to user's total
      final updatedStats = await _dbHelper.addPoints(currentUser.id!, score);

      // Check for newly unlocked achievements
      final newAchievements = await _checkAndUnlockAchievements(
        currentUser.id!,
        gameCategory,
        score,
        updatedStats,
      );

      // Update achievements unlocked count
      if (newAchievements.isNotEmpty) {
        final stats = await _dbHelper.getOrCreateGameStats(currentUser.id!);
        final updatedStatsWithAchievements = stats.copyWith(
          achievementsUnlocked: stats.achievementsUnlocked + newAchievements.length,
        );
        await _dbHelper.updateGameStats(updatedStatsWithAchievements);
      }

      return {
        'success': true,
        'message': 'Game progress saved!',
        'stats': updatedStats,
        'newAchievements': newAchievements,
        'leveledUp': updatedStats.currentLevel > (updatedStats.currentLevel - 1),
        'isNewHighScore': isNewHighScore,
        'highScore': isNewHighScore ? score : previousHighScore,
        'previousHighScore': previousHighScore,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to save progress: ${e.toString()}',
      };
    }
  }

  /// Check and unlock achievements based on game completion
  Future<List<Achievement>> _checkAndUnlockAchievements(
    int userId,
    String gameCategory,
    int score,
    GameStats stats,
  ) async {
    final List<Achievement> newlyUnlocked = [];

    // Get all achievements
    final allAchievements = await _dbHelper.getAllAchievements();

    // Get user's current achievements
    final userAchievements = await _dbHelper.getUserAchievements(userId);
    final unlockedIds = userAchievements.map((ua) => ua['id'] as int).toSet();

    for (var achievement in allAchievements) {
      // Skip if already unlocked
      if (unlockedIds.contains(achievement.id)) continue;

      bool shouldUnlock = false;

      // Check unlock criteria
      switch (achievement.unlockCriteria) {
        case 'games_played':
          shouldUnlock = stats.gamesPlayed >= achievement.requiredValue;
          break;
        case 'total_points':
          shouldUnlock = stats.totalPoints >= achievement.requiredValue;
          break;
        case 'level':
          shouldUnlock = stats.currentLevel >= achievement.requiredValue;
          break;
        case 'game_score':
          // Only check game-specific achievements for matching category
          if (achievement.category == gameCategory) {
            shouldUnlock = score >= achievement.requiredValue;
          }
          break;
      }

      if (shouldUnlock) {
        await _dbHelper.unlockAchievement(userId, achievement.id!);
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  /// Get current user's game stats
  Future<GameStats?> getCurrentUserStats() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return null;

      return await _dbHelper.getOrCreateGameStats(currentUser.id!);
    } catch (e) {
      return null;
    }
  }

  /// Get user's rank on leaderboard
  Future<int> getCurrentUserRank() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return 0;

      return await _dbHelper.getUserRank(currentUser.id!);
    } catch (e) {
      return 0;
    }
  }

  /// Get leaderboard entries
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      return await _dbHelper.getLeaderboard(limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Get user's unlocked achievements
  Future<List<Map<String, dynamic>>> getUserAchievements() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return [];

      return await _dbHelper.getUserAchievements(currentUser.id!);
    } catch (e) {
      return [];
    }
  }

  /// Get all available achievements
  Future<List<Achievement>> getAllAchievements() async {
    try {
      return await _dbHelper.getAllAchievements();
    } catch (e) {
      return [];
    }
  }

  /// Get achievements by category
  Future<List<Achievement>> getAchievementsByCategory(String category) async {
    try {
      return await _dbHelper.getAchievementsByCategory(category);
    } catch (e) {
      return [];
    }
  }

  /// Calculate bonus points for achievements
  int calculateAchievementBonus(List<Achievement> achievements) {
    return achievements.fold(0, (sum, achievement) => sum + achievement.pointsAwarded);
  }

  /// Get level progress information
  Map<String, dynamic> getLevelProgress(GameStats stats) {
    final currentThreshold = stats.currentLevel == 1 ? 0 : GameStats.pointsForNextLevel(stats.currentLevel - 1);
    final nextThreshold = GameStats.pointsForNextLevel(stats.currentLevel);
    final pointsInCurrentLevel = stats.totalPoints - currentThreshold;
    final pointsNeededForLevel = nextThreshold - currentThreshold;
    final progressPercentage = stats.getProgressToNextLevel();

    return {
      'currentLevel': stats.currentLevel,
      'totalPoints': stats.totalPoints,
      'pointsInCurrentLevel': pointsInCurrentLevel,
      'pointsNeededForNextLevel': pointsNeededForLevel - pointsInCurrentLevel,
      'nextLevelThreshold': nextThreshold,
      'progressPercentage': progressPercentage,
      'isMaxLevel': stats.currentLevel >= 10,
    };
  }

  /// Get high score for a specific game category
  Future<int> getHighScore(String gameCategory) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return 0;

    try {
      return await _dbHelper.getHighScore(currentUser.id!, gameCategory);
    } catch (e) {
      return 0;
    }
  }

  /// Get all high scores for current user
  Future<List<Map<String, dynamic>>> getAllHighScores() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return [];

    try {
      return await _dbHelper.getUserHighScores(currentUser.id!);
    } catch (e) {
      return [];
    }
  }

  /// Get game-specific leaderboard
  Future<List<Map<String, dynamic>>> getGameLeaderboard(String gameCategory, {int limit = 10}) async {
    try {
      return await _dbHelper.getGameLeaderboard(gameCategory, limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Add points to user's total (for daily rewards, etc.)
  Future<GameStats?> addPoints(int userId, int points) async {
    try {
      return await _dbHelper.addPoints(userId, points);
    } catch (e) {
      return null;
    }
  }
}

