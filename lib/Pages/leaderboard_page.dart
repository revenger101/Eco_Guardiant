import 'package:flutter/material.dart';
import '../services/game_progress_service.dart';
import '../services/auth_service.dart';

class LeaderboardPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const LeaderboardPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final GameProgressService _gameProgressService = GameProgressService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _leaderboard = [];
  int? _currentUserRank;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    try {
      // Check if user is logged in
      if (_authService.currentUser != null) {
        _currentUserId = _authService.currentUser!.id;
        
        // Load leaderboard and user's rank
        final leaderboard = await _gameProgressService.getLeaderboard(limit: 100);
        final userRank = await _gameProgressService.getCurrentUserRank();

        setState(() {
          _leaderboard = leaderboard;
          _currentUserRank = userRank;
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
            content: Text('Error loading leaderboard: $e'),
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
          'Leaderboard',
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
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              color: const Color(0xFF4CAF50),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User's Rank Card
                    if (_currentUserRank != null) ...[
                      _buildUserRankCard(),
                      const SizedBox(height: 24),
                    ],

                    // Top 3 Podium
                    if (_leaderboard.length >= 3) ...[
                      _buildTopThreePodium(),
                      const SizedBox(height: 24),
                    ],

                    // Leaderboard Title
                    Text(
                      'All Rankings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Leaderboard List
                    _buildLeaderboardList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserRankCard() {
    final userEntry = _leaderboard.firstWhere(
      (entry) => entry['userId'] == _currentUserId,
      orElse: () => {
        'rank': _currentUserRank ?? 0,
        'userId': _currentUserId ?? 0,
        'userName': widget.userName,
        'totalPoints': 0,
        'currentLevel': 1,
        'achievementsUnlocked': 0,
        'gamesPlayed': 0,
      },
    );

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
          const Text(
            'Your Rank',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildUserStatItem(
                Icons.emoji_events,
                '#${userEntry['rank']}',
                'Rank',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildUserStatItem(
                Icons.stars,
                '${userEntry['totalPoints']}',
                'Points',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildUserStatItem(
                Icons.trending_up,
                'Lvl ${userEntry['currentLevel']}',
                'Level',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTopThreePodium() {
    final top3 = _leaderboard.take(3).toList();
    
    // Arrange as: 2nd, 1st, 3rd
    final arranged = [
      if (top3.length > 1) top3[1], // 2nd place
      if (top3.isNotEmpty) top3[0], // 1st place
      if (top3.length > 2) top3[2], // 3rd place
    ];

    final heights = [120.0, 150.0, 100.0]; // Heights for 2nd, 1st, 3rd
    final colors = [
      Colors.grey.shade400, // Silver
      const Color(0xFFFFD700), // Gold
      Colors.brown.shade400, // Bronze
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(arranged.length, (index) {
        final entry = arranged[index];
        final actualRank = entry['rank'] as int? ?? (index + 1);
        final colorIndex = actualRank == 1 ? 1 : (actualRank == 2 ? 0 : 2);

        return Expanded(
          child: _buildPodiumCard(
            entry,
            heights[colorIndex],
            colors[colorIndex],
          ),
        );
      }),
    );
  }

  Widget _buildPodiumCard(Map<String, dynamic> entry, double height, Color color) {
    final isCurrentUser = entry['userId'] == _currentUserId;
    final rank = entry['rank'] as int? ?? 0;
    final userName = entry['userName'] as String? ?? '';
    final totalPoints = entry['totalPoints'] as int? ?? 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Crown for 1st place
          if (rank == 1)
            const Icon(
              Icons.workspace_premium,
              color: Color(0xFFFFD700),
              size: 32,
            ),
          const SizedBox(height: 8),

          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              border: Border.all(
                color: isCurrentUser ? const Color(0xFF4CAF50) : Colors.white,
                width: isCurrentUser ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
              color: isCurrentUser ? const Color(0xFF4CAF50) : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),

          // Podium
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'points',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    if (_leaderboard.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No rankings available yet',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Play games to earn points and climb the leaderboard!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final entry = _leaderboard[index];
        final isCurrentUser = entry['userId'] == _currentUserId;
        final isTopThree = (entry['rank'] as int? ?? 0) <= 3;

        return _buildLeaderboardCard(entry, isCurrentUser, isTopThree);
      },
    );
  }

  Widget _buildLeaderboardCard(Map<String, dynamic> entry, bool isCurrentUser, bool isTopThree) {
    final rank = entry['rank'] as int? ?? 0;
    final userName = entry['userName'] as String? ?? '';
    final totalPoints = entry['totalPoints'] as int? ?? 0;
    final currentLevel = entry['currentLevel'] as int? ?? 1;
    final achievementsUnlocked = entry['achievementsUnlocked'] as int? ?? 0;

    Color rankColor;
    IconData rankIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      rankIcon = Icons.workspace_premium;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400; // Silver
      rankIcon = Icons.workspace_premium;
    } else if (rank == 3) {
      rankColor = Colors.brown.shade400; // Bronze
      rankIcon = Icons.workspace_premium;
    } else {
      rankColor = Colors.grey.shade600;
      rankIcon = Icons.person;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF4CAF50)
              : (isTopThree ? rankColor.withValues(alpha: 0.3) : Colors.grey.shade200),
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: isTopThree
                  ? LinearGradient(
                      colors: [rankColor, rankColor.withValues(alpha: 0.7)],
                    )
                  : null,
              color: isTopThree ? null : Colors.grey.shade100,
              shape: BoxShape.circle,
              boxShadow: isTopThree
                  ? [
                      BoxShadow(
                        color: rankColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isTopThree
                  ? Icon(rankIcon, color: Colors.white, size: 24)
                  : Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade800,
                        ),
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip(Icons.stars, '$totalPoints pts', Colors.amber.shade600),
                    const SizedBox(width: 8),
                    _buildStatChip(Icons.trending_up, 'Lvl $currentLevel', Colors.blue.shade500),
                    const SizedBox(width: 8),
                    _buildStatChip(Icons.emoji_events, '$achievementsUnlocked', Colors.purple.shade500),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

