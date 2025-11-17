import 'package:flutter/material.dart';
import '../services/daily_rewards_service.dart';
import '../services/game_progress_service.dart';
import '../models/game_stats.dart';

class DailyRewardsPage extends StatefulWidget {
  const DailyRewardsPage({super.key});

  @override
  State<DailyRewardsPage> createState() => _DailyRewardsPageState();
}

class _DailyRewardsPageState extends State<DailyRewardsPage> {
  final DailyRewardsService _dailyRewardsService = DailyRewardsService();
  final GameProgressService _gameProgressService = GameProgressService();

  bool _isLoading = true;
  int _currentStreak = 0;
  int _totalLogins = 0;
  bool _hasClaimedToday = false;
  int _todayReward = 0;
  List<Map<String, dynamic>> _loginHistory = [];
  GameStats? _userStats;

  @override
  void initState() {
    super.initState();
    _loadRewardsData();
  }

  Future<void> _loadRewardsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get streak information
      final streakInfo = await _dailyRewardsService.getCurrentStreak();
      
      // Get login history
      final history = await _dailyRewardsService.getLoginHistory(limit: 30);
      
      // Check if claimed today
      final hasClaimedToday = await _dailyRewardsService.hasLoggedInToday();
      
      // Get user stats
      final stats = await _gameProgressService.getCurrentUserStats();

      // Calculate today's reward
      final currentStreak = streakInfo['currentStreak'] as int;
      final todayReward = _dailyRewardsService.calculateRewardPoints(
        hasClaimedToday ? currentStreak : currentStreak + 1
      );

      setState(() {
        _currentStreak = currentStreak;
        _totalLogins = streakInfo['totalLogins'] as int;
        _loginHistory = history;
        _hasClaimedToday = hasClaimedToday;
        _todayReward = todayReward;
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rewards data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _claimDailyReward() async {
    if (_hasClaimedToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You\'ve already claimed today\'s reward!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _dailyRewardsService.checkDailyLogin();

    if (result['success'] == true && result['isNewLogin'] == true) {
      await _loadRewardsData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Daily Reward Claimed!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '+${result['rewardPoints']} points earned',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Daily Rewards',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRewardsData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRewardsData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Streak Card
                    _buildStreakCard(),
                    const SizedBox(height: 16),

                    // Today's Reward Card
                    _buildTodayRewardCard(),
                    const SizedBox(height: 16),

                    // Reward Tiers Info
                    _buildRewardTiersCard(),
                    const SizedBox(height: 16),

                    // Login Calendar
                    _buildLoginCalendar(),
                    const SizedBox(height: 16),

                    // Stats Summary
                    _buildStatsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStreakCard() {
    final tierInfo = _dailyRewardsService.getRewardTier(_currentStreak);
    final tierColor = Color(tierInfo['color'] as int);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tierColor, tierColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            tierInfo['icon'] as String,
            style: const TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 12),
          Text(
            '${tierInfo['tier']} Streak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_currentStreak Day${_currentStreak != 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep it up! 🔥',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayRewardCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hasClaimedToday
                      ? Colors.grey.shade200
                      : const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _hasClaimedToday ? Icons.check_circle : Icons.card_giftcard,
                  color: _hasClaimedToday ? Colors.grey : const Color(0xFF4CAF50),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasClaimedToday ? 'Reward Claimed!' : 'Today\'s Reward',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _hasClaimedToday
                          ? 'Come back tomorrow for more!'
                          : 'Claim your daily reward',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reward Points:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '+$_todayReward',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
          if (!_hasClaimedToday) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _claimDailyReward,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Claim Reward',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardTiersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reward Tiers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTierRow('🌱', 'Common', '1-2 days', '10 pts', const Color(0xFF4CAF50)),
          const SizedBox(height: 12),
          _buildTierRow('⭐', 'Rare', '3-4 days', '15-20 pts', const Color(0xFF2196F3)),
          const SizedBox(height: 12),
          _buildTierRow('💎', 'Epic', '5-6 days', '25-30 pts', const Color(0xFF9C27B0)),
          const SizedBox(height: 12),
          _buildTierRow('🏆', 'Legendary', '7+ days', '35-50 pts', const Color(0xFFFFD700)),
        ],
      ),
    );
  }

  Widget _buildTierRow(String icon, String tier, String days, String points, Color color) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tier,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
              Text(
                days,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          points,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCalendar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Login History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_loginHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No login history yet',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              _loginHistory.length > 7 ? 7 : _loginHistory.length,
              (index) {
                final login = _loginHistory[index];
                final date = login['loginDate'] as String;
                final streak = login['streakCount'] as int;
                final points = login['rewardPoints'] as int;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(date),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Streak: $streak day${streak != 1 ? 's' : ''}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Text(
                          '+$points',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Logins',
                  '$_totalLogins',
                  Icons.calendar_today,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Current Level',
                  '${_userStats?.currentLevel ?? 1}',
                  Icons.trending_up,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Points',
                  '${_userStats?.totalPoints ?? 0}',
                  Icons.emoji_events,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Best Streak',
                  '$_currentStreak',
                  Icons.local_fire_department,
                  const Color(0xFFF44336),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return 'Today';
      } else if (dateOnly == yesterday) {
        return 'Yesterday';
      } else {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}

