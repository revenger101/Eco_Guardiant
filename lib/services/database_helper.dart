import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/game_stats.dart';
import '../models/achievement.dart';
import '../models/user_achievement.dart';


/// DatabaseHelper class to manage SQLite database operations
/// Implements Singleton pattern to ensure only one instance exists
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Private constructor
  DatabaseHelper._internal();

  // Factory constructor returns the same instance
  factory DatabaseHelper() {
    return _instance;
  }

  /// Get database instance, create if doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    // Get the database path
    String path = join(await getDatabasesPath(), 'eco_guardians.db');

    // Open the database
    return await openDatabase(
      path,
      version: 3, // Updated version for daily logins and high scores
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        lastLogin TEXT
      )
    ''');

    // Game stats table
    await db.execute('''
      CREATE TABLE game_stats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        totalPoints INTEGER NOT NULL DEFAULT 0,
        currentLevel INTEGER NOT NULL DEFAULT 1,
        gamesPlayed INTEGER NOT NULL DEFAULT 0,
        achievementsUnlocked INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        lastPlayed TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(userId)
      )
    ''');

    // Achievements table
    await db.execute('''
      CREATE TABLE achievements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        iconName TEXT NOT NULL,
        pointsAwarded INTEGER NOT NULL,
        category TEXT NOT NULL,
        unlockCriteria TEXT NOT NULL,
        requiredValue INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // User achievements table
    await db.execute('''
      CREATE TABLE user_achievements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        achievementId INTEGER NOT NULL,
        unlockedAt TEXT NOT NULL,
        progress INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (achievementId) REFERENCES achievements (id) ON DELETE CASCADE,
        UNIQUE(userId, achievementId)
      )
    ''');

    // Daily logins table
    await db.execute('''
      CREATE TABLE daily_logins(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        loginDate TEXT NOT NULL,
        streakCount INTEGER NOT NULL DEFAULT 1,
        rewardPoints INTEGER NOT NULL DEFAULT 0,
        lastLoginTimestamp TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(userId, loginDate)
      )
    ''');

    // High scores table
    await db.execute('''
      CREATE TABLE high_scores(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        gameCategory TEXT NOT NULL,
        highScore INTEGER NOT NULL DEFAULT 0,
        achievedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(userId, gameCategory)
      )
    ''');

    // Initialize default achievements
    await _initializeDefaultAchievements(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add game progress tables
      await db.execute('''
        CREATE TABLE game_stats(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          totalPoints INTEGER NOT NULL DEFAULT 0,
          currentLevel INTEGER NOT NULL DEFAULT 1,
          gamesPlayed INTEGER NOT NULL DEFAULT 0,
          achievementsUnlocked INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL,
          lastPlayed TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          UNIQUE(userId)
        )
      ''');

      await db.execute('''
        CREATE TABLE achievements(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          iconName TEXT NOT NULL,
          pointsAwarded INTEGER NOT NULL,
          category TEXT NOT NULL,
          unlockCriteria TEXT NOT NULL,
          requiredValue INTEGER NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE user_achievements(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          achievementId INTEGER NOT NULL,
          unlockedAt TEXT NOT NULL,
          progress INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (achievementId) REFERENCES achievements (id) ON DELETE CASCADE,
          UNIQUE(userId, achievementId)
        )
      ''');

      // Initialize default achievements
      await _initializeDefaultAchievements(db);
    }

    if (oldVersion < 3) {
      // Add daily logins table
      await db.execute('''
        CREATE TABLE daily_logins(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          loginDate TEXT NOT NULL,
          streakCount INTEGER NOT NULL DEFAULT 1,
          rewardPoints INTEGER NOT NULL DEFAULT 0,
          lastLoginTimestamp TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          UNIQUE(userId, loginDate)
        )
      ''');

      // Add high scores table
      await db.execute('''
        CREATE TABLE high_scores(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          gameCategory TEXT NOT NULL,
          highScore INTEGER NOT NULL DEFAULT 0,
          achievedAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          UNIQUE(userId, gameCategory)
        )
      ''');
    }
  }

  /// Initialize default achievements
  Future<void> _initializeDefaultAchievements(Database db) async {
    final achievements = [
      // General achievements
      {'name': 'First Steps', 'description': 'Play your first game', 'iconName': 'eco', 'pointsAwarded': 10, 'category': 'general', 'unlockCriteria': 'games_played', 'requiredValue': 1},
      {'name': 'Eco Enthusiast', 'description': 'Earn 100 total points', 'iconName': 'emoji_events', 'pointsAwarded': 20, 'category': 'general', 'unlockCriteria': 'total_points', 'requiredValue': 100},
      {'name': 'Eco Warrior', 'description': 'Earn 500 total points', 'iconName': 'military_tech', 'pointsAwarded': 50, 'category': 'general', 'unlockCriteria': 'total_points', 'requiredValue': 500},
      {'name': 'Eco Champion', 'description': 'Earn 1000 total points', 'iconName': 'workspace_premium', 'pointsAwarded': 100, 'category': 'general', 'unlockCriteria': 'total_points', 'requiredValue': 1000},
      {'name': 'Level Master', 'description': 'Reach level 5', 'iconName': 'trending_up', 'pointsAwarded': 75, 'category': 'general', 'unlockCriteria': 'level', 'requiredValue': 5},
      {'name': 'Dedicated Player', 'description': 'Play 10 games', 'iconName': 'sports_esports', 'pointsAwarded': 30, 'category': 'general', 'unlockCriteria': 'games_played', 'requiredValue': 10},

      // Beach Cleanup achievements
      {'name': 'Beach Cleaner', 'description': 'Score 50 points in Beach Cleanup', 'iconName': 'beach_access', 'pointsAwarded': 15, 'category': 'beach_cleanup', 'unlockCriteria': 'game_score', 'requiredValue': 50},
      {'name': 'Trash Master', 'description': 'Score 100 points in Beach Cleanup', 'iconName': 'delete_sweep', 'pointsAwarded': 30, 'category': 'beach_cleanup', 'unlockCriteria': 'game_score', 'requiredValue': 100},

      // Forest Guardian achievements
      {'name': 'Tree Planter', 'description': 'Plant 10 trees in Forest Guardian', 'iconName': 'park', 'pointsAwarded': 15, 'category': 'forest_guardian', 'unlockCriteria': 'game_score', 'requiredValue': 100},
      {'name': 'Forest Protector', 'description': 'Plant 20 trees in Forest Guardian', 'iconName': 'forest', 'pointsAwarded': 30, 'category': 'forest_guardian', 'unlockCriteria': 'game_score', 'requiredValue': 200},

      // Ocean Savior achievements
      {'name': 'Ocean Explorer', 'description': 'Score 60 points in Ocean Savior', 'iconName': 'waves', 'pointsAwarded': 15, 'category': 'ocean_savior', 'unlockCriteria': 'game_score', 'requiredValue': 60},
      {'name': 'Marine Biologist', 'description': 'Get perfect score in Ocean Savior', 'iconName': 'science', 'pointsAwarded': 40, 'category': 'ocean_savior', 'unlockCriteria': 'game_score', 'requiredValue': 100},
    ];

    for (var achievement in achievements) {
      await db.insert('achievements', {
        ...achievement,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Insert a new user into the database
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  /// Get user by ID
  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  /// Update user's last login time
  Future<int> updateLastLogin(int userId) async {
    final db = await database;
    return await db.update(
      'users',
      {'lastLogin': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Update user information
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Delete user by ID
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all users (for admin purposes)
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  /// Check if email exists in database
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  // ==================== GAME STATS METHODS ====================

  /// Get or create game stats for a user
  Future<GameStats> getOrCreateGameStats(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_stats',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) {
      // Create new game stats for user
      final newStats = GameStats(userId: userId);
      final id = await db.insert('game_stats', newStats.toMap());
      return newStats.copyWith(id: id);
    }

    return GameStats.fromMap(maps.first);
  }

  /// Update game stats
  Future<int> updateGameStats(GameStats stats) async {
    final db = await database;
    return await db.update(
      'game_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );
  }

  /// Add points to user's total
  Future<GameStats> addPoints(int userId, int points) async {
    final stats = await getOrCreateGameStats(userId);
    final newTotalPoints = stats.totalPoints + points;
    final newLevel = GameStats.calculateLevel(newTotalPoints);

    final updatedStats = stats.copyWith(
      totalPoints: newTotalPoints,
      currentLevel: newLevel,
      gamesPlayed: stats.gamesPlayed + 1,
      lastPlayed: DateTime.now(),
    );

    await updateGameStats(updatedStats);
    return updatedStats;
  }

  /// Get leaderboard (top users by points)
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT
        ROW_NUMBER() OVER (ORDER BY gs.totalPoints DESC) as rank,
        gs.userId,
        u.fullName as userName,
        gs.totalPoints,
        gs.currentLevel,
        gs.achievementsUnlocked,
        gs.gamesPlayed
      FROM game_stats gs
      INNER JOIN users u ON gs.userId = u.id
      ORDER BY gs.totalPoints DESC
      LIMIT ?
    ''', [limit]);

    return results;
  }

  /// Get user's rank on leaderboard
  Future<int> getUserRank(int userId) async {
    final db = await database;

    // First check if user has game stats
    final userStats = await db.query(
      'game_stats',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    // If user has no stats, return 0 (unranked)
    if (userStats.isEmpty) {
      return 0;
    }

    final result = await db.rawQuery('''
      SELECT COUNT(*) + 1 as rank
      FROM game_stats
      WHERE totalPoints > (
        SELECT COALESCE(totalPoints, 0) FROM game_stats WHERE userId = ?
      )
    ''', [userId]);

    return (result.first['rank'] as int?) ?? 0;
  }

  // ==================== ACHIEVEMENT METHODS ====================

  /// Get all achievements
  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('achievements');
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  /// Get achievements by category
  Future<List<Achievement>> getAchievementsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  /// Get user's unlocked achievements
  Future<List<Map<String, dynamic>>> getUserAchievements(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT
        a.*,
        ua.unlockedAt,
        ua.progress
      FROM user_achievements ua
      INNER JOIN achievements a ON ua.achievementId = a.id
      WHERE ua.userId = ? AND ua.progress >= 100
      ORDER BY ua.unlockedAt DESC
    ''', [userId]);

    return results;
  }

  /// Unlock achievement for user
  Future<int> unlockAchievement(int userId, int achievementId) async {
    final db = await database;

    // Check if already unlocked
    final existing = await db.query(
      'user_achievements',
      where: 'userId = ? AND achievementId = ?',
      whereArgs: [userId, achievementId],
    );

    if (existing.isNotEmpty) {
      // Update progress to 100
      return await db.update(
        'user_achievements',
        {'progress': 100, 'unlockedAt': DateTime.now().toIso8601String()},
        where: 'userId = ? AND achievementId = ?',
        whereArgs: [userId, achievementId],
      );
    } else {
      // Insert new achievement
      final userAchievement = UserAchievement(
        userId: userId,
        achievementId: achievementId,
        progress: 100,
      );
      return await db.insert('user_achievements', userAchievement.toMap());
    }
  }

  /// Update achievement progress
  Future<int> updateAchievementProgress(int userId, int achievementId, int progress) async {
    final db = await database;

    final existing = await db.query(
      'user_achievements',
      where: 'userId = ? AND achievementId = ?',
      whereArgs: [userId, achievementId],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'user_achievements',
        {'progress': progress},
        where: 'userId = ? AND achievementId = ?',
        whereArgs: [userId, achievementId],
      );
    } else {
      final userAchievement = UserAchievement(
        userId: userId,
        achievementId: achievementId,
        progress: progress,
      );
      return await db.insert('user_achievements', userAchievement.toMap());
    }
  }

  // ==================== HIGH SCORES METHODS ====================

  /// Save or update high score for a user and game category
  Future<int> saveHighScore(int userId, String gameCategory, int score) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final existing = await db.query(
      'high_scores',
      where: 'userId = ? AND gameCategory = ?',
      whereArgs: [userId, gameCategory],
    );

    if (existing.isNotEmpty) {
      final currentHighScore = existing.first['highScore'] as int;
      // Only update if new score is higher
      if (score > currentHighScore) {
        return await db.update(
          'high_scores',
          {'highScore': score, 'achievedAt': now},
          where: 'userId = ? AND gameCategory = ?',
          whereArgs: [userId, gameCategory],
        );
      }
      return 0; // No update needed
    } else {
      // Insert new high score
      return await db.insert('high_scores', {
        'userId': userId,
        'gameCategory': gameCategory,
        'highScore': score,
        'achievedAt': now,
      });
    }
  }

  /// Get user's high score for a specific game category
  Future<int> getHighScore(int userId, String gameCategory) async {
    final db = await database;

    final result = await db.query(
      'high_scores',
      columns: ['highScore'],
      where: 'userId = ? AND gameCategory = ?',
      whereArgs: [userId, gameCategory],
    );

    if (result.isNotEmpty) {
      return result.first['highScore'] as int;
    }
    return 0;
  }

  /// Get all high scores for a user
  Future<List<Map<String, dynamic>>> getUserHighScores(int userId) async {
    final db = await database;

    return await db.query(
      'high_scores',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'highScore DESC',
    );
  }

  /// Get top high scores for a specific game category (leaderboard)
  Future<List<Map<String, dynamic>>> getGameLeaderboard(String gameCategory, {int limit = 10}) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT
        hs.highScore,
        hs.achievedAt,
        u.fullName as userName,
        u.id as userId
      FROM high_scores hs
      INNER JOIN users u ON hs.userId = u.id
      WHERE hs.gameCategory = ?
      ORDER BY hs.highScore DESC
      LIMIT ?
    ''', [gameCategory, limit]);

    return result;
  }

  // ==================== DAILY LOGINS METHODS ====================

  /// Record a daily login for a user
  Future<Map<String, dynamic>> recordDailyLogin(int userId) async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = today.toIso8601String().split('T')[0];
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = yesterday.toIso8601String().split('T')[0];

    // Check if user already logged in today
    final todayLogin = await db.query(
      'daily_logins',
      where: 'userId = ? AND loginDate = ?',
      whereArgs: [userId, todayStr],
    );

    if (todayLogin.isNotEmpty) {
      // Already logged in today
      return {
        'isNewLogin': false,
        'streakCount': todayLogin.first['streakCount'] as int,
        'rewardPoints': 0,
      };
    }

    // Check yesterday's login to determine streak
    final yesterdayLogin = await db.query(
      'daily_logins',
      where: 'userId = ? AND loginDate = ?',
      whereArgs: [userId, yesterdayStr],
    );

    int streakCount = 1;
    if (yesterdayLogin.isNotEmpty) {
      // Continue streak
      streakCount = (yesterdayLogin.first['streakCount'] as int) + 1;
    }

    // Calculate reward points based on streak
    int rewardPoints = _calculateDailyReward(streakCount);

    // Insert today's login
    await db.insert('daily_logins', {
      'userId': userId,
      'loginDate': todayStr,
      'streakCount': streakCount,
      'rewardPoints': rewardPoints,
      'lastLoginTimestamp': now.toIso8601String(),
    });

    return {
      'isNewLogin': true,
      'streakCount': streakCount,
      'rewardPoints': rewardPoints,
    };
  }

  /// Calculate daily reward points based on streak
  int _calculateDailyReward(int streakCount) {
    // Base reward: 10 points
    // Bonus: +5 points for every 3 days of streak
    // Max bonus at 7 days: 50 points
    int baseReward = 10;
    int bonusReward = (streakCount ~/ 3) * 5;
    int maxBonus = 40;

    return baseReward + (bonusReward > maxBonus ? maxBonus : bonusReward);
  }

  /// Get user's current login streak
  Future<Map<String, dynamic>> getUserLoginStreak(int userId) async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = today.toIso8601String().split('T')[0];

    // Get today's or most recent login
    final recentLogin = await db.query(
      'daily_logins',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'loginDate DESC',
      limit: 1,
    );

    if (recentLogin.isEmpty) {
      return {
        'currentStreak': 0,
        'totalLogins': 0,
        'lastLoginDate': null,
      };
    }

    final lastLoginDate = recentLogin.first['loginDate'] as String;
    final streakCount = recentLogin.first['streakCount'] as int;

    // Get total login days
    final totalLogins = await db.query(
      'daily_logins',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    // Check if streak is still active (logged in today or yesterday)
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = yesterday.toIso8601String().split('T')[0];

    bool isStreakActive = lastLoginDate == todayStr || lastLoginDate == yesterdayStr;

    return {
      'currentStreak': isStreakActive ? streakCount : 0,
      'totalLogins': totalLogins.length,
      'lastLoginDate': lastLoginDate,
    };
  }

  /// Get user's login history
  Future<List<Map<String, dynamic>>> getUserLoginHistory(int userId, {int limit = 30}) async {
    final db = await database;

    return await db.query(
      'daily_logins',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'loginDate DESC',
      limit: limit,
    );
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Delete the database (for testing purposes)
  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'eco_guardians.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}

