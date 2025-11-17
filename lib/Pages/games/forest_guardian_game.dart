import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/game_progress_service.dart';
import '../../models/achievement.dart';

class ForestGuardianGame extends StatefulWidget {
  const ForestGuardianGame({super.key});

  @override
  State<ForestGuardianGame> createState() => _ForestGuardianGameState();
}

class _ForestGuardianGameState extends State<ForestGuardianGame> {
  // Game variables
  int _score = 0;
  int _timeLeft = 15;
  bool _isSavingProgress = false;
  List<Achievement> _newAchievements = [];
  bool _gameStarted = false;
  bool _gameOver = false;
  int _highScore = 0;
  bool _isNewHighScore = false;
  Timer? _gameTimer;
  Timer? _treeSpawnTimer;

  // Tree positions and states
  final List<Tree> _trees = [];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final gameProgressService = GameProgressService();
    final highScore = await gameProgressService.getHighScore('forest_guardian');
    if (mounted) {
      setState(() {
        _highScore = highScore;
      });
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _treeSpawnTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 15;
      _gameStarted = true;
      _gameOver = false;
      _trees.clear();
    });

    // Start game timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });

    // Spawn trees periodically
    _treeSpawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_gameStarted && !_gameOver) {
        _spawnTree();
      }
    });
  }

  void _spawnTree() {
    if (_trees.length < 8) { // Limit number of trees on screen
      setState(() {
        _trees.add(Tree(
          id: DateTime.now().millisecondsSinceEpoch,
          x: math.Random().nextDouble() * 0.8 + 0.1, // 10% to 90% of width
          isChopped: true, // Start as chopped
        ));
      });
    }
  }

  void _plantTree(int treeId) {
    if (!_gameStarted || _gameOver) return;

    setState(() {
      _trees.removeWhere((tree) => tree.id == treeId);
      _score += 10;
    });
  }

  void _endGame() async {
    setState(() {
      _gameOver = true;
      _gameStarted = false;
      _isSavingProgress = true;
    });
    _gameTimer?.cancel();
    _treeSpawnTimer?.cancel();

    // Save game progress and check for achievements
    final gameProgressService = GameProgressService();
    final result = await gameProgressService.recordGameCompletion(
      gameCategory: 'forest_guardian',
      score: _score,
    );

    if (mounted) {
      setState(() {
        _isSavingProgress = false;
        if (result['success']) {
          _newAchievements = result['newAchievements'] ?? [];
          _isNewHighScore = result['isNewHighScore'] ?? false;

          // Show achievement notifications
          if (_newAchievements.isNotEmpty) {
            _showAchievementNotifications();
          }
        }
      });
    }
  }

  void _showAchievementNotifications() {
    for (var achievement in _newAchievements) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Achievement Unlocked!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${achievement.name} (+${achievement.pointsAwarded} pts)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _restartGame() {
    _startGame();
  }

  void _showGameInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'How to Play',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forest Guardian Game',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              _InstructionItem(
                icon: Icons.touch_app,
                text: 'Tap on chopped trees to plant new ones',
              ),
              _InstructionItem(
                icon: Icons.timer,
                text: 'You have 15 seconds to save as many trees as possible',
              ),
              _InstructionItem(
                icon: Icons.eco,
                text: 'Each planted tree gives you 10 points',
              ),
              _InstructionItem(
                icon: Icons.emoji_events,
                text: 'Save the forest from deforestation!',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Got it!',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forest Guardian',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.grey),
            onPressed: _showGameInstructions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Game Header with Stats
          _buildGameHeader(),
          const SizedBox(height: 20),

          // Game Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  // Background
                  _buildForestBackground(),

                  // Trees - Positioned relative to the background container
                  if (_gameStarted && !_gameOver) ..._buildTreeItems(),

                  // Game Over Overlay
                  if (_gameOver) _buildGameOverlay(),

                  // Start Game Overlay
                  if (!_gameStarted && !_gameOver) _buildStartOverlay(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('SCORE', '$_score', Icons.eco, const Color(0xFF4CAF50)),
          _buildStatItem('TIME', '${_timeLeft}s', Icons.timer, const Color(0xFF2196F3)),
          _buildStatItem('TREES SAVED', '${_score ~/ 10}', Icons.park, const Color(0xFF8BC34A)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildForestBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // Sky blue
            Color(0xFF98FB98), // Pale green
            Color(0xFF90EE90), // Light green
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: _ForestBackgroundPainter(),
        ),
      ),
    );
  }

  List<Widget> _buildTreeItems() {
    return _trees.map((tree) {
      // Get the actual size of the game area
      final gameAreaWidth = MediaQuery.of(context).size.width - 32; // 16px margin on both sides
      final gameAreaHeight = MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top +
              kToolbarHeight + // AppBar height
              20 + // SizedBox between header and game
              32 + // 16px margin top and bottom
              100); // Header height approximation

      return Positioned(
        left: tree.x * gameAreaWidth,
        bottom: 80, // Fixed height from bottom (adjusted for better visibility)
        child: GestureDetector(
          onTap: () => _plantTree(tree.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                // Tree
                Container(
                  width: 60,
                  height: tree.isChopped ? 20 : 80,
                  decoration: BoxDecoration(
                    color: tree.isChopped ? const Color(0xFF8B4513) : const Color(0xFF228B22),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: tree.isChopped
                      ? const Icon(Icons.forest, color: Colors.brown, size: 16)
                      : const Icon(Icons.park, color: Colors.green, size: 40),
                ),

                // Click instruction
                if (tree.isChopped)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'PLANT!',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStartOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.park_rounded,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Forest Guardian',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap chopped trees to plant new ones!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              if (_highScore > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Personal Best: $_highScore',
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Start Protecting',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Game Over!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You saved ${_score ~/ 10} trees!',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Final Score: $_score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              if (_isNewHighScore) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'NEW HIGH SCORE!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: const BorderSide(color: Colors.green),
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        onPressed: _restartGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Play Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Tree {
  final int id;
  final double x;
  final bool isChopped;

  Tree({
    required this.id,
    required this.x,
    required this.isChopped,
  });
}

class _ForestBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF556B2F)
      ..style = PaintingStyle.fill;

    // Draw ground
    final groundPath = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.65, size.width * 0.5, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.75, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(groundPath, paint);

    // Draw some background hills
    final hillPaint = Paint()
      ..color = const Color(0xFF6B8E23).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final hillPath1 = Path()
      ..moveTo(-100, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.4, size.width + 100, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(-100, size.height)
      ..close();

    canvas.drawPath(hillPath1, hillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}