import 'package:flutter/material.dart';
import 'package:projectwithlouled/Pages/profile_page.dart';
import 'package:projectwithlouled/Pages/achievements_page.dart';
import 'package:projectwithlouled/Pages/leaderboard_page.dart';
import 'package:projectwithlouled/Pages/daily_rewards_page.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onProfileTap; // ADD THIS
  final String userName;
  final String userEmail;
  final String? profileImageUrl;

  const Sidebar({
    super.key,
    required this.onLogout,
    required this.onProfileTap, // ADD THIS TO CONSTRUCTOR
    required this.userName,
    required this.userEmail,
    this.profileImageUrl,
  });

  void _navigateToProfile(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          userName: userName,
          userEmail: userEmail,
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pop(context); // Close drawer
    // Already on home page, so no navigation needed
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementsPage(
          userName: userName,
          userEmail: userEmail,
        ),
      ),
    );
  }

  void _navigateToLeaderboard(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderboardPage(
          userName: userName,
          userEmail: userEmail,
        ),
      ),
    );
  }

  void _navigateToDailyRewards(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyRewardsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      backgroundColor: Colors.white,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.green.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Eco-themed Header
            _buildEcoHeader(context),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 20),
                  _buildEcoNavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isActive: true,
                    onTap: () => _navigateToHome(context),
                    color: Colors.blue.shade500,
                  ),
                  _buildEcoNavItem(
                    icon: Icons.person_outline,
                    label: 'My Profile',
                    isActive: false,
                    onTap: () => _navigateToProfile(context),
                    color: Colors.green.shade500,
                  ),
                  _buildEcoNavItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Achievements',
                    isActive: false,
                    onTap: () => _navigateToAchievements(context),
                    color: Colors.amber.shade600,
                  ),
                  _buildEcoNavItem(
                    icon: Icons.leaderboard_outlined,
                    label: 'Leaderboard',
                    isActive: false,
                    onTap: () => _navigateToLeaderboard(context),
                    color: Colors.purple.shade500,
                  ),
                  _buildEcoNavItem(
                    icon: Icons.card_giftcard_outlined,
                    label: 'Daily Rewards',
                    isActive: false,
                    onTap: () => _navigateToDailyRewards(context),
                    color: Colors.orange.shade500,
                  ),
                  _buildEcoNavItem(
                    icon: Icons.eco_outlined,
                    label: 'Eco Impact',
                    isActive: false,
                    onTap: () {},
                    color: Colors.teal.shade500,
                  ),
                  _buildEcoNavItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    isActive: false,
                    onTap: () {},
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 20),

                  // Eco Stats Section
                  _buildEcoStatsSection(),
                ],
              ),
            ),

            // Logout Section
            _buildEcoLogoutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoHeader(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
            Color(0xFF1B5E20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade800.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: 20,
            right: 20,
            child: Icon(
              Icons.eco,
              color: Colors.white.withOpacity(0.1),
              size: 80,
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile Picture with Eco Badge
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: profileImageUrl != null
                            ? DecorationImage(
                          image: NetworkImage(profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: profileImageUrl == null
                          ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.8),
                              Colors.green.shade100,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.green,
                          size: 40,
                        ),
                      )
                          : null,
                    ),
                    // Eco Level Badge
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // User Name
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),

                // User Email
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),

                // Eco Level Indicator
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
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.amber.shade300,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Level 5 Eco Warrior',
                        style: TextStyle(
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

  Widget _buildEcoNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: isActive ? Border.all(color: color.withOpacity(0.3), width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon with eco background
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isActive ? color : color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Label
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? color : Colors.grey.shade700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Active indicator or arrow
                if (isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade400,
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEcoStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        border: Border.all(color: Colors.green.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.leaderboard,
                color: Colors.green.shade600,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Quick Stats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('125', 'CO₂ kg', Icons.cloud, Colors.blue.shade500),
              _buildMiniStat('24', 'Games', Icons.play_arrow, Colors.green.shade500),
              _buildMiniStat('8', 'Trees', Icons.park, Colors.orange.shade500),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEcoLogoutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Eco Impact Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.eco,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Positive Impact',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'You\'ve helped save the planet!',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Logout Button
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.red.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: onLogout,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      // Logout Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Logout Text
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              'Sign out of your account',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.red.shade400,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}