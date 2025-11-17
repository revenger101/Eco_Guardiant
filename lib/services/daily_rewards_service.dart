import 'database_helper.dart';
import 'auth_service.dart';
import 'game_progress_service.dart';

/// Service for managing daily login rewards and streaks
class DailyRewardsService {
  static final DailyRewardsService _instance = DailyRewardsService._internal();
  factory DailyRewardsService() => _instance;
  DailyRewardsService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  final GameProgressService _gameProgressService = GameProgressService();

  /// Check and record daily login, award points if applicable
  Future<Map<String, dynamic>> checkDailyLogin() async {
    final user = _authService.currentUser;
    if (user == null) {
      return {
        'success': false,
        'error': 'No user logged in',
      };
    }

    try {
      // Record the daily login
      final loginResult = await _dbHelper.recordDailyLogin(user.id!);

      // If this is a new login (not already logged in today)
      if (loginResult['isNewLogin'] == true) {
        final rewardPoints = loginResult['rewardPoints'] as int;
        
        // Award the reward points to the user's game stats
        if (rewardPoints > 0) {
          await _gameProgressService.addPoints(user.id!, rewardPoints);
        }

        return {
          'success': true,
          'isNewLogin': true,
          'streakCount': loginResult['streakCount'],
          'rewardPoints': rewardPoints,
          'message': 'Daily login reward claimed!',
        };
      } else {
        // Already logged in today
        return {
          'success': true,
          'isNewLogin': false,
          'streakCount': loginResult['streakCount'],
          'rewardPoints': 0,
          'message': 'Already claimed today\'s reward',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get current user's login streak information
  Future<Map<String, dynamic>> getCurrentStreak() async {
    final user = _authService.currentUser;
    if (user == null) {
      return {
        'currentStreak': 0,
        'totalLogins': 0,
        'lastLoginDate': null,
      };
    }

    try {
      return await _dbHelper.getUserLoginStreak(user.id!);
    } catch (e) {
      return {
        'currentStreak': 0,
        'totalLogins': 0,
        'lastLoginDate': null,
        'error': e.toString(),
      };
    }
  }

  /// Get user's login history
  Future<List<Map<String, dynamic>>> getLoginHistory({int limit = 30}) async {
    final user = _authService.currentUser;
    if (user == null) {
      return [];
    }

    try {
      return await _dbHelper.getUserLoginHistory(user.id!, limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Calculate reward points for a given streak count
  int calculateRewardPoints(int streakCount) {
    // Base reward: 10 points
    // Bonus: +5 points for every 3 days of streak
    // Max bonus at 7 days: 50 points
    int baseReward = 10;
    int bonusReward = (streakCount ~/ 3) * 5;
    int maxBonus = 40;
    
    return baseReward + (bonusReward > maxBonus ? maxBonus : bonusReward);
  }

  /// Get reward tier information for display
  Map<String, dynamic> getRewardTier(int streakCount) {
    if (streakCount >= 7) {
      return {
        'tier': 'Legendary',
        'color': 0xFFFFD700, // Gold
        'icon': '🏆',
        'points': 50,
      };
    } else if (streakCount >= 5) {
      return {
        'tier': 'Epic',
        'color': 0xFF9C27B0, // Purple
        'icon': '💎',
        'points': calculateRewardPoints(streakCount),
      };
    } else if (streakCount >= 3) {
      return {
        'tier': 'Rare',
        'color': 0xFF2196F3, // Blue
        'icon': '⭐',
        'points': calculateRewardPoints(streakCount),
      };
    } else {
      return {
        'tier': 'Common',
        'color': 0xFF4CAF50, // Green
        'icon': '🌱',
        'points': calculateRewardPoints(streakCount),
      };
    }
  }

  /// Check if user has logged in today
  Future<bool> hasLoggedInToday() async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayStr = today.toIso8601String().split('T')[0];

      final history = await _dbHelper.getUserLoginHistory(user.id!, limit: 1);
      
      if (history.isNotEmpty) {
        final lastLoginDate = history.first['loginDate'] as String;
        return lastLoginDate == todayStr;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get next reward preview (what user will get tomorrow)
  Map<String, dynamic> getNextRewardPreview(int currentStreak) {
    final nextStreak = currentStreak + 1;
    final nextReward = calculateRewardPoints(nextStreak);
    final nextTier = getRewardTier(nextStreak);

    return {
      'nextStreak': nextStreak,
      'nextReward': nextReward,
      'nextTier': nextTier['tier'],
      'nextIcon': nextTier['icon'],
    };
  }
}

