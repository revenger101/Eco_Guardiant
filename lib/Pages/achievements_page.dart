import 'package:flutter/material.dart';
import '../services/game_progress_service.dart';
import '../services/auth_service.dart';
import '../models/achievement.dart';

class AchievementsPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const AchievementsPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final GameProgressService _gameProgressService = GameProgressService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  List<Achievement> _allAchievements = [];
  List<Map<String, dynamic>> _userAchievements = [];
  int _totalUnlocked = 0;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      // Check if user is logged in
      if (_authService.currentUser != null) {
        // Load all achievements and user's unlocked achievements
        final allAchievements = await _gameProgressService.getAllAchievements();
        final userAchievements = await _gameProgressService.getUserAchievements();

        setState(() {
          _allAchievements = allAchievements;
          _userAchievements = userAchievements;
          _totalUnlocked = userAchievements.length;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading achievements: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Achievement> _getFilteredAchievements() {
    if (_selectedCategory == 'all') {
      return _allAchievements;
    }
    return _allAchievements.where((a) => a.category == _selectedCategory).toList();
  }

  bool _isAchievementUnlocked(int achievementId) {
    return _userAchievements.any((ua) => ua['id'] == achievementId);
  }

  int _getAchievementProgress(int achievementId) {
    try {
      final userAchievement = _userAchievements.firstWhere(
        (ua) => ua['id'] == achievementId,
        orElse: () => {},
      );
      return userAchievement['progress'] as int? ?? 0;
    } catch (e) {
      return 0;
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
          'Achievements',
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
            onPressed: _loadAchievements,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Summary Card
                  _buildProgressSummaryCard(),
                  const SizedBox(height: 24),

                  // Category Filter
                  _buildCategoryFilter(),
                  const SizedBox(height: 20),

                  // Achievements Grid
                  _buildAchievementsGrid(),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressSummaryCard() {
    final totalAchievements = _allAchievements.length;
    final progressPercentage = totalAchievements > 0
        ? (_totalUnlocked / totalAchievements * 100).toInt()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Achievement Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_totalUnlocked of $totalAchievements unlocked',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$progressPercentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'id': 'all', 'label': 'All', 'icon': Icons.grid_view},
      {'id': 'general', 'label': 'General', 'icon': Icons.star},
      {'id': 'beach_cleanup', 'label': 'Beach', 'icon': Icons.beach_access},
      {'id': 'forest_guardian', 'label': 'Forest', 'icon': Icons.park},
      {'id': 'ocean_savior', 'label': 'Ocean', 'icon': Icons.waves},
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category['id'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked, int progress) {
    final iconData = _getIconForAchievement(achievement.iconName);
    final categoryColor = _getCategoryColor(achievement.category);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? categoryColor.withValues(alpha: 0.3) : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? categoryColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Locked overlay
          if (!isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: isUnlocked
                        ? LinearGradient(
                            colors: [categoryColor, categoryColor.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUnlocked ? null : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isUnlocked ? iconData : Icons.lock,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  achievement.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.grey.shade800 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isUnlocked ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 8),

                // Points badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isUnlocked
                        ? const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          )
                        : null,
                    color: isUnlocked ? null : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars,
                        size: 14,
                        color: isUnlocked ? Colors.white : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${achievement.pointsAwarded}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar for locked achievements
                if (!isUnlocked && progress > 0) ...[
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Unlocked checkmark
          if (isUnlocked)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForAchievement(String iconName) {
    switch (iconName) {
      case 'first_steps':
        return Icons.directions_walk;
      case 'eco_enthusiast':
        return Icons.eco;
      case 'eco_warrior':
        return Icons.shield;
      case 'eco_champion':
        return Icons.emoji_events;
      case 'level_master':
        return Icons.trending_up;
      case 'dedicated_player':
        return Icons.favorite;
      case 'beach_cleaner':
        return Icons.beach_access;
      case 'trash_master':
        return Icons.delete_sweep;
      case 'tree_planter':
        return Icons.park;
      case 'forest_protector':
        return Icons.forest;
      case 'ocean_explorer':
        return Icons.waves;
      case 'marine_biologist':
        return Icons.water;
      default:
        return Icons.star;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'general':
        return const Color(0xFF4CAF50);
      case 'beach_cleanup':
        return Colors.blue.shade500;
      case 'forest_guardian':
        return Colors.green.shade600;
      case 'ocean_savior':
        return Colors.teal.shade500;
      default:
        return const Color(0xFF4CAF50);
    }
  }

  Widget _buildAchievementsGrid() {
    final filteredAchievements = _getFilteredAchievements();

    if (filteredAchievements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No achievements in this category',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredAchievements.length,
      itemBuilder: (context, index) {
        final achievement = filteredAchievements[index];
        final isUnlocked = _isAchievementUnlocked(achievement.id!);
        final progress = _getAchievementProgress(achievement.id!);

        return _buildAchievementCard(achievement, isUnlocked, progress);
      },
    );
  }
}
