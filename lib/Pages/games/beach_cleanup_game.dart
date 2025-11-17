import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/game_progress_service.dart';
import '../../models/achievement.dart';

class BeachCleanupGame extends StatefulWidget {
  const BeachCleanupGame({super.key});

  @override
  State<BeachCleanupGame> createState() => _BeachCleanupGameState();
}

class _BeachCleanupGameState extends State<BeachCleanupGame>
    with TickerProviderStateMixin {
  // Game variables
  int _score = 0;
  int _timeLeft = 15;
  int _trashCollected = 0;
  int _trashOnScreen = 8;
  bool _isGameActive = false;
  bool _isGameOver = false;
  int _highScore = 0;
  bool _isSavingProgress = false;
  bool _isNewHighScore = false;
  List<Achievement> _newAchievements = [];

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _pulseController;

  // Trash items with positions and types
  List<TrashItem> _trashItems = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _initializeGame();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final gameProgressService = GameProgressService();
    final highScore = await gameProgressService.getHighScore('beach_cleanup');
    if (mounted) {
      setState(() {
        _highScore = highScore;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    _generateTrashItems();
  }

  void _generateTrashItems() {
    setState(() {
      _trashItems = List.generate(_trashOnScreen, (index) {
        return TrashItem(
          id: index,
          type: TrashType.values[math.Random().nextInt(TrashType.values.length)],
          position: _getRandomPosition(),
          isCollected: false,
        );
      });
    });
  }

  Offset _getRandomPosition() {
    return Offset(
      math.Random().nextDouble() * 0.8 + 0.1, // 10% to 90% of width
      math.Random().nextDouble() * 0.6 + 0.2, // 20% to 80% of height
    );
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _isGameOver = false;
      _score = 0;
      _timeLeft = 15;
      _trashCollected = 0;
      _trashOnScreen = 8;
    });
    _generateTrashItems();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isGameActive && _timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
        _startTimer();
      } else if (_timeLeft <= 0) {
        _endGame();
      }
    });
  }

  void _collectTrash(TrashItem trash) {
    if (!_isGameActive || trash.isCollected) return;

    setState(() {
      // Mark trash as collected
      final index = _trashItems.indexWhere((item) => item.id == trash.id);
      _trashItems[index] = _trashItems[index].copyWith(isCollected: true);

      // Update game stats
      _trashCollected++;
      _score += trash.type.points;

      // Add new trash when collected
      if (_trashItems.where((item) => !item.isCollected).length <= 2) {
        _trashOnScreen += 3;
        _generateTrashItems();
      }
    });

    // Animate collection
    _animationController.forward(from: 0.0);
  }

  void _endGame() async {
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
      _isSavingProgress = true;
      if (_score > _highScore) {
        _highScore = _score;
      }
    });

    // Save game progress and check for achievements
    final gameProgressService = GameProgressService();
    final result = await gameProgressService.recordGameCompletion(
      gameCategory: 'beach_cleanup',
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
              Icon(Icons.help_outline, color: Color(0xFF2196F3)),
              SizedBox(width: 8),
              Text(
                'How to Play',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Beach Cleanup Game',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              _InstructionItem(
                icon: Icons.touch_app,
                text: 'Tap on trash items to clean them up',
              ),
              _InstructionItem(
                icon: Icons.timer,
                text: 'You have 15 seconds to collect as much trash as possible',
              ),
              _InstructionItem(
                icon: Icons.eco,
                text: 'Different trash types give different points',
              ),
              _InstructionItem(
                icon: Icons.clean_hands,
                text: 'Help keep our beaches clean and protect marine life!',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Got it!',
                style: TextStyle(color: Color(0xFF2196F3)),
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
          'Beach Cleanup',
          style: TextStyle(
            color: Color(0xFF2196F3),
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
                  _buildBeachBackground(),

                  // Trash Items - Positioned relative to the background container
                  if (_isGameActive && !_isGameOver) ..._buildTrashItems(),

                  // Game Over Overlay
                  if (_isGameOver) _buildGameOverlay(),

                  // Start Game Overlay
                  if (!_isGameActive && !_isGameOver) _buildStartOverlay(),
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
            color: Colors.blue.withOpacity(0.1),
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
          _buildStatItem('TRASH', '$_trashCollected', Icons.clean_hands, const Color(0xFFFF9800)),
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

  Widget _buildBeachBackground() {
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
            Color(0xFF64B5F6), // Light blue
            Color(0xFFB3E5FC), // Very light blue
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: _BeachBackgroundPainter(),
        ),
      ),
    );
  }

  List<Widget> _buildTrashItems() {
    return _trashItems.map((trash) {
      if (trash.isCollected) return const SizedBox.shrink();

      // Get the actual size of the game area
      final gameAreaWidth = MediaQuery.of(context).size.width - 32; // 16px margin on both sides
      final gameAreaHeight = MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top +
              kToolbarHeight + // AppBar height
              20 + // SizedBox between header and game
              32 + // 16px margin top and bottom
              100); // Header height approximation

      return Positioned(
        left: trash.position.dx * gameAreaWidth,
        top: trash.position.dy * gameAreaHeight,
        child: GestureDetector(
          onTap: () => _collectTrash(trash),
          child: _buildTrashWidget(trash.type),
        ),
      );
    }).toList();
  }

  Widget _buildTrashWidget(TrashType type) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.rotationZ(_pulseController.value * 0.1),
          child: Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: type.color.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: type.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    type.icon,
                    color: type.color,
                    size: 28,
                  ),
                ),
                // Points badge
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: type.color,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '+${type.points}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.clean_hands_rounded,
                color: Color(0xFF2196F3),
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Beach Cleanup',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap trash to clean the beach!',
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
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
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
                        'Start Cleaning',
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
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.clean_hands_rounded,
                color: Color(0xFF2196F3),
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Game Over!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You collected $_trashCollected pieces of trash!',
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
                        side: const BorderSide(color: Color(0xFF2196F3)),
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(color: Color(0xFF2196F3)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
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

class _BeachBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF8E1)
      ..style = PaintingStyle.fill;

    // Draw beach/sand area (larger area for trash placement)
    final beachPath = Path()
      ..moveTo(0, size.height * 0.6) // Higher beach area
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.55, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.65, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(beachPath, paint);

    // Draw ocean waves
    final wavePaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final wavePath1 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.58, size.width * 0.6, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.62, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.63, size.width * 0.6, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.67, 0, size.height * 0.65)
      ..close();

    canvas.drawPath(wavePath1, wavePaint);
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
          Icon(icon, color: const Color(0xFF2196F3), size: 16),
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

// Trash types with different points and icons
enum TrashType {
  plastic(10, Icons.backpack_rounded, Colors.red),
  bottle(15, Icons.local_drink, Colors.green),
  can(12, Icons.liquor, Colors.orange),
  wrapper(8, Icons.receipt, Colors.purple),
  straw(5, Icons.airline_seat_legroom_reduced, Colors.blue);

  final int points;
  final IconData icon;
  final Color color;

  const TrashType(this.points, this.icon, this.color);
}

// Trash item model
class TrashItem {
  final int id;
  final TrashType type;
  final Offset position;
  final bool isCollected;

  const TrashItem({
    required this.id,
    required this.type,
    required this.position,
    required this.isCollected,
  });

  TrashItem copyWith({
    bool? isCollected,
  }) {
    return TrashItem(
      id: id,
      type: type,
      position: position,
      isCollected: isCollected ?? this.isCollected,
    );
  }
}