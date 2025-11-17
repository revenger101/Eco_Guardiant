import 'package:flutter/material.dart';
import 'package:projectwithlouled/Pages/games/forest_guardian_game.dart';
import 'package:projectwithlouled/Pages/games/ocean_savior_game.dart';
import '../widget/sidebar.dart';
import '../services/auth_service.dart';
import '../services/game_progress_service.dart';
import 'games/beach_cleanup_game.dart';
import '../widget/chatbot_fab.dart';
import 'package:projectwithlouled/Pages/games/eco_city_builder_game.dart';
import 'package:projectwithlouled/Pages/games/climate_warrior_game.dart';
import 'achievements_page.dart';
import 'leaderboard_page.dart';
import '../Widget/language_switcher.dart';
import 'package:projectwithlouled/Pages/games/Wildlife_Rescue_Game.dart';


class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  final GameProgressService _gameProgressService = GameProgressService();

  List<Map<String, dynamic>> _recentAchievements = [];
  bool _isLoadingAchievements = false;

  // Icon and color maps for achievements (moved outside build method for performance)
  static const Map<String, IconData> _iconMap = {
    'eco': Icons.eco,
    'emoji_events': Icons.emoji_events,
    'military_tech': Icons.military_tech,
    'clean_hands': Icons.clean_hands,
    'park': Icons.park,
    'waves': Icons.waves,
    'pets': Icons.pets,
    'science': Icons.science,
  };

  static const Map<String, Color> _colorMap = {
    'general': Color(0xFF4CAF50),
    'beach_cleanup': Color(0xFF2196F3),
    'forest_guardian': Color(0xFF4CAF50),
    'ocean_savior': Color(0xFF00BCD4),
    'wildlife_rescue': Color(0xFFFF9800),
    'eco_city_builder': Color(0xFF9C27B0),
    'climate_warrior': Color(0xFF9C27B0),
  };

  @override
  void initState() {
    super.initState();
    // Load achievements after the initial frame to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecentAchievements();
    });
  }

  Future<void> _loadRecentAchievements() async {
    if (!mounted) return;

    setState(() => _isLoadingAchievements = true);

    try {
      if (_authService.currentUser != null) {
        final achievements = await _gameProgressService.getUserAchievements();

        if (mounted) {
          setState(() {
            // Get the 3 most recent achievements
            _recentAchievements = achievements.take(3).toList();
            _isLoadingAchievements = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingAchievements = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAchievements = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading achievements: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Get context before async operation
                  final navigator = Navigator.of(context);

                  // Logout using AuthService (clears stored credentials)
                  await _authService.logout();

                  // Close dialog
                  navigator.pop();

                  // Navigate to login page
                  navigator.pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleProfileTap() {
    Navigator.pop(_scaffoldKey.currentContext!);
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
      SnackBar(
        content: const Text('Navigating to Profile'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  // Updated environmental protection games with eco-themes
  final List<Game> games = [
    Game(
      name: 'Beach Cleanup',
      description: 'Clean the beach from plastic and trash to protect marine life',
      icon: Icons.clean_hands,
      color: const Color(0xFF2196F3),
      duration: '15s',
      difficulty: 'Easy',
    ),
    Game(
      name: 'Forest Guardian',
      description: 'Protect the forest from wildfires and illegal logging',
      icon: Icons.park,
      color: const Color(0xFF4CAF50),
      duration: '15s',
      difficulty: 'Medium',
    ),
    Game(
      name: 'Ocean Savior',
      description: 'Remove plastic from oceans and save marine animals',
      icon: Icons.waves,
      color: const Color(0xFF00BCD4),
      duration: 'unlimited',
      difficulty: 'Hard',
    ),
    Game(
      name: 'Wildlife Rescue',
      description: 'Help injured animals and protect endangered species',
      icon: Icons.pets,
      color: const Color(0xFFFF9800),
      duration: '75s',
      difficulty: 'Medium',
    ),
    Game(
      name: 'Eco City Builder',
      description: 'Build sustainable cities with renewable energy',
      icon: Icons.eco,
      color: const Color(0xFF8BC34A),
      duration: '180s',
      difficulty: 'Medium',
    ),
    Game(
      name: 'Climate Warrior',
      description: 'Reduce carbon footprint and fight climate change',
      icon: Icons.wb_sunny,
      color: const Color(0xFF9C27B0),
      duration: '150s',
      difficulty: 'Hard',
    ),
  ];

  void _navigateToGame(Game game) {
    if (game.name == 'Beach Cleanup') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BeachCleanupGame(),
        ),
      );
    } else if (game.name == 'Forest Guardian') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ForestGuardianGame(),
        ),
      );
    } else if (game.name == 'Ocean Savior') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OceanSaviorGame(),
        ),
      );
    } else if (game.name == 'Wildlife Rescue') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WildlifeRescueGame2D(),
        ),
      );
    } else if (game.name == 'Eco City Builder') { // ADD THIS
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EcoCityBuilderGame(),
        ),
      );
    } else if (game.name == 'Climate Warrior') { // ADD THIS
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ClimateWarriorGame(),
        ),
      );
    } else {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Launching ${game.name}...'),
          backgroundColor: game.color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FDF8),
      drawer: Sidebar(
        onLogout: _handleLogout,
        onProfileTap: _handleProfileTap,
        userName: widget.userName,
        userEmail: widget.userEmail,
        profileImageUrl: null,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: Colors.grey.shade700,
            size: 28,
          ),
          onPressed: _openDrawer,
        ),
        title: Text(
          'Eco Games',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          const LanguageSwitcherButton(),
          _buildAppBarIcon(Icons.leaderboard_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeaderboardPage(
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                ),
              ),
            );
          }),
          _buildAppBarIcon(Icons.emoji_events_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AchievementsPage(
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Profile Card
            _buildUserProfileCard(),
            const SizedBox(height: 20),

            // Quick Stats Card
            _buildQuickStatsCard(),
            const SizedBox(height: 20),

            // Recent Achievements
            _buildRecentAchievements(),
            const SizedBox(height: 24),

            // Games Grid
            _buildGamesGrid(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: const ChatbotFAB(),
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Icon(
              Icons.eco,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.userName.split(' ').first}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Level 5 Eco Warrior',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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

  Widget _buildQuickStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, color: const Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Text(
                'Environmental Impact',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Games Played', '24', Icons.play_arrow, const Color(0xFF2196F3)),
              _buildStatItem('CO₂ Reduced', '125 kg', Icons.eco, const Color(0xFF4CAF50)),
              _buildStatItem('Points', '1,850', Icons.leaderboard, const Color(0xFFFF9800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAchievements() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
                  Icon(Icons.emoji_events_rounded, color: const Color(0xFFFF9800), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Achievements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingAchievements
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                )
              : _recentAchievements.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'No achievements yet. Start playing games to unlock achievements!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
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

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    final iconName = achievement['iconName'] as String? ?? 'eco';
    final category = achievement['category'] as String? ?? 'general';
    final icon = _iconMap[iconName] ?? Icons.eco;
    final color = _colorMap[category] ?? const Color(0xFF4CAF50);
    final name = achievement['name'] as String? ?? '';
    final description = achievement['description'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.emoji_events_rounded,
            color: Colors.amber.shade600,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildGamesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.games_rounded, color: const Color(0xFF4CAF50), size: 20),
            const SizedBox(width: 8),
            Text(
              'Available Games',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return _buildGameCard(games[index]);
          },
        ),
      ],
    );
  }

  Widget _buildGameCard(Game game) {
    return GestureDetector(
      onTap: () => _navigateToGame(game),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Icon with better styling
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [game.color.withOpacity(0.15), game.color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                game.icon,
                color: game.color,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Game Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                game.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),

            // Game Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                game.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),

            // Game Info (Duration & Difficulty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Duration
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, size: 10, color: Colors.blue.shade700),
                      const SizedBox(width: 4),
                      Text(
                        game.duration,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Difficulty Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(game.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    game.difficulty,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(game.difficulty),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'hard':
        return const Color(0xFFF44336);
      default:
        return Colors.grey.shade600;
    }
  }
}

class Game {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String duration;
  final String difficulty;

  const Game({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.duration,
    required this.difficulty,
  });
}