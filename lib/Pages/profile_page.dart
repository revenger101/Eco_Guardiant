import 'package:flutter/material.dart';
import '../services/game_progress_service.dart';
import '../services/auth_service.dart';
import '../models/game_stats.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GameProgressService _gameProgressService = GameProgressService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  GameStats? _userStats;
  List<Map<String, dynamic>> _recentAchievements = [];
  int _currentLevel = 1;
  int _currentPoints = 0;
  int _pointsToNextLevel = 250;
  double _levelProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      if (_authService.currentUser != null) {
        // Load user stats
        final stats = await _gameProgressService.getCurrentUserStats();

        if (stats != null) {
          // Load recent achievements (last 4 unlocked)
          final allAchievements = await _gameProgressService.getUserAchievements();
          final recentAchievements = allAchievements.take(4).toList();

          // Calculate level progress
          final levelProgress = _gameProgressService.getLevelProgress(stats);

          setState(() {
            _userStats = stats;
            _recentAchievements = recentAchievements;
            _currentLevel = stats.currentLevel;
            _currentPoints = stats.totalPoints;
            _pointsToNextLevel = levelProgress['nextLevelThreshold'] as int;
            _levelProgress = (levelProgress['progressPercentage'] as double) / 100.0;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey.shade700,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.grey.shade700,
            ),
            onPressed: _loadProfileData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header Card
                  _buildProfileHeader(),
                  const SizedBox(height: 24),

                  // Environmental Impact Stats
                  _buildImpactStats(),
                  const SizedBox(height: 24),

                  // Level Progress
                  _buildLevelProgress(),
                  const SizedBox(height: 24),

                  // Recent Achievements
                  _buildAchievementsSection(),
                  const SizedBox(height: 24),

                  // Account Settings
                  _buildSettingsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade800.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.amber.shade300,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Level $_currentLevel Eco Warrior',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco,
                color: Colors.green.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Environmental Impact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildImpactStatCard(
                'Total Points',
                '$_currentPoints',
                Icons.stars,
                Colors.amber.shade600,
                'Eco points earned',
              ),
              _buildImpactStatCard(
                'Games Played',
                '${_userStats?.gamesPlayed ?? 0}',
                Icons.play_arrow,
                Colors.orange.shade500,
                'Environmental missions',
              ),
              _buildImpactStatCard(
                'Achievements',
                '${_userStats?.achievementsUnlocked ?? 0}',
                Icons.emoji_events,
                Colors.purple.shade500,
                'Unlocked badges',
              ),
              _buildImpactStatCard(
                'Current Level',
                '$_currentLevel',
                Icons.trending_up,
                Colors.green.shade500,
                'Eco warrior rank',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.amber.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Level Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              // Background
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Progress
              Container(
                height: 12,
                width: (MediaQuery.of(context).size.width - 72) * _levelProgress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level $_currentLevel',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$_currentPoints points',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(_levelProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _currentLevel >= 10 ? 'Max Level!' : 'to Level ${_currentLevel + 1}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_currentLevel < 10) ...[
            const SizedBox(height: 8),
            Text(
              '${_pointsToNextLevel - _currentPoints} points needed',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.amber.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                'View All',
                style: TextStyle(
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _recentAchievements.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No achievements yet',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Play games to unlock achievements!',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: _recentAchievements
                      .map((achievement) => _buildAchievementItem(achievement))
                      .toList(),
                ),
        ],
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'beach_access':
        return Icons.beach_access;
      case 'park':
        return Icons.park;
      case 'waves':
        return Icons.waves;
      case 'eco':
        return Icons.eco;
      case 'cloud':
        return Icons.cloud;
      case 'recycling':
        return Icons.recycling;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'beach_cleanup':
        return Colors.blue.shade500;
      case 'forest_guardian':
        return Colors.green.shade600;
      case 'ocean_savior':
        return Colors.teal.shade500;
      case 'climate_warrior':
        return Colors.orange.shade500;
      default:
        return Colors.green.shade500;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Recently';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) return 'Today';
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
      return '${(difference.inDays / 30).floor()} months ago';
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    final name = achievement['name'] as String? ?? 'Achievement';
    final description = achievement['description'] as String? ?? '';
    final iconName = achievement['iconName'] as String? ?? 'emoji_events';
    final category = achievement['category'] as String? ?? 'general';
    final progress = achievement['progress'] as int? ?? 100;
    final unlockedAt = achievement['unlockedAt'] as String?;

    final icon = _getIconFromName(iconName);
    final color = _getCategoryColor(category);
    final isUnlocked = progress >= 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isUnlocked ? color.withValues(alpha: 0.3) : Colors.grey.shade200,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Achievement Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Achievement Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (isUnlocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(unlockedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Points Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  color: color,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${achievement['points'] ?? 0}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    final settingsItems = [
      _SettingsItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Game alerts and updates',
        onTap: () {},
      ),
      _SettingsItem(
        icon: Icons.security_outlined,
        title: 'Privacy & Security',
        subtitle: 'Manage your data and privacy',
        onTap: () {},
      ),
      _SettingsItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get help and contact support',
        onTap: () {},
      ),
      _SettingsItem(
        icon: Icons.info_outline,
        title: 'About Eco Guardians',
        subtitle: 'App version and information',
        onTap: () {},
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: settingsItems
                .map((item) => _buildSettingsItem(item))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(_SettingsItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int progress;
  final String date;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.progress,
    required this.date,
  });
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}