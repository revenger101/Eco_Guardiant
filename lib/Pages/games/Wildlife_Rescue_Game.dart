import 'dart:async' as dart;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import '../../services/game_progress_service.dart';
import '../../models/achievement.dart';

class WildlifeRescueGame2D extends StatefulWidget {
  const WildlifeRescueGame2D({super.key});

  @override
  State<WildlifeRescueGame2D> createState() => _WildlifeRescueGame2DState();
}

class _WildlifeRescueGame2DState extends State<WildlifeRescueGame2D> with SingleTickerProviderStateMixin {
  late WildlifeRescueFlameGame _game;
  int _score = 0;
  int _timeLeft = 60;
  int _animalsCollected = 0;
  int _combo = 0;
  bool _gameStarted = false;
  bool _gameOver = false;
  List<Achievement> _newAchievements = [];
  int _highScore = 0;
  bool _isNewHighScore = false;
  dart.Timer? _gameTimer;
  dart.Timer? _comboTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _game = WildlifeRescueFlameGame(
      onAnimalCollected: _onAnimalCollected,
      onAnimalMissed: _onAnimalMissed,
      onGameOver: _onGameOver,
      onComboUpdate: _onComboUpdate,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final gameProgressService = GameProgressService();
    final highScore = await gameProgressService.getHighScore('wildlife_rescue_2d');
    if (mounted) {
      setState(() {
        _highScore = highScore;
      });
    }
  }

  void _onAnimalCollected(AnimalType type, int comboBonus) {
    if (!_gameStarted || _gameOver) return;

    setState(() {
      _score += type.points + comboBonus;
      _animalsCollected++;
      _combo++;

      // Visual feedback for collection
      _pulseController.forward(from: 0.0);

      // Bonus time for quick collections
      if (_score % 200 == 0) {
        _timeLeft += 5;
      }
    });
  }

  void _onAnimalMissed() {
    if (!_gameStarted || _gameOver) return;

    setState(() {
      _score = math.max(0, _score - 10);
      _combo = 0;
    });
  }

  void _onComboUpdate(int combo) {
    setState(() {
      _combo = combo;
    });
  }

  void _onGameOver() {
    _endGame();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 60;
      _animalsCollected = 0;
      _combo = 0;
      _gameStarted = true;
      _gameOver = false;
      _newAchievements = [];
      _isNewHighScore = false;
    });

    _game.startGame();
    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = dart.Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          timer.cancel();
          _endGame();
        }
      });
    });
  }

  void _endGame() async {
    _gameTimer?.cancel();
    _game.endGame();

    setState(() {
      _gameOver = true;
      _gameStarted = false;
    });

    // Save game progress and check for achievements
    final gameProgressService = GameProgressService();
    final result = await gameProgressService.recordGameCompletion(
      gameCategory: 'wildlife_rescue_2d',
      score: _score,
    );

    if (mounted) {
      setState(() {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Achievement Unlocked!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      achievement.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.all(16),
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.help_outline, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Wildlife Rescue 2D',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Rescue Endangered Animals! 🐢',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionItem('👆', 'Tap and drag animals to the rescue truck'),
                  _buildInstructionItem('⚡', 'Build combos for bonus points'),
                  _buildInstructionItem('🎯', 'Different animals give different points'),
                  _buildInstructionItem('⏰', '60 seconds to rescue as many as possible'),
                  _buildInstructionItem('🌟', 'Unlock achievements and beat your high score!'),
                  const SizedBox(height: 20),
                  _buildAnimalPointsPreview(),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFA000).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Start Rescue Mission!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalPointsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animal Points:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AnimalType.values.map((type) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(type.icon, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '+${type.points}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildModernHeader(),
            const SizedBox(height: 8),

            // Game Stats with Animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: _buildGameStats(),
                );
              },
            ),
            const SizedBox(height: 8),

            // Game Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: _gameOver ? _buildGameOverScreen() :
                _gameStarted ? _buildGameScreen() : _buildStartScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Wildlife Rescue 2D',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline, color: Colors.white, size: 18),
            ),
            onPressed: _showGameInstructions,
          ),
        ],
      ),
    );
  }

  Widget _buildGameStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🎯', '$_score', 'SCORE', const Color(0xFF667eea)),
          _buildStatItem('⏰', '${_timeLeft}s', 'TIME', _timeLeft <= 10 ? Colors.red : const Color(0xFF4CAF50)),
          _buildStatItem('🐾', '$_animalsCollected', 'SAVED', const Color(0xFF2196F3)),
          if (_combo > 1) _buildStatItem('⚡', 'x$_combo', 'COMBO', const Color(0xFFFF9800)),
          _buildStatItem('🏆', '$_highScore', 'BEST', const Color(0xFFFFD700)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String title, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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

  Widget _buildStartScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: _BackgroundPatternPainter(),
              ),
            ),
          ),

          Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(
                        Icons.forest_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Wildlife Rescue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Emergency Animal Rescue Mission',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Game Preview
                      Container(
                        width: 200,
                        height: 120,
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
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Ready to Save Wildlife?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Drag endangered animals to safety before time runs out! Build combos for bonus points and unlock achievements.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_highScore > 0) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Personal Best: $_highScore',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Start Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Start Rescue Mission',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: GameWidget(
          game: _game,
          overlayBuilderMap: {
            'timeWarning': (context, game) {
              if (_timeLeft <= 10) {
                return Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        '⏰ HURRY! TIME RUNNING OUT! ⏰',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          },
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final performance = _score >= 1000 ? 'Wildlife Legend! 🦸‍♀️🌟' :
    _score >= 800 ? 'Master Rescuer! 🐬✨' :
    _score >= 500 ? 'Amazing Hero! 🐢🎯' :
    _score >= 300 ? 'Great Job! 🐠🔥' :
    _score >= 100 ? 'Good Effort! 🌱👍' :
    'Keep Practicing! 🌱💪';

    final performanceColor = _score >= 500 ? const Color(0xFFFFD700) :
    _score >= 300 ? const Color(0xFF4CAF50) :
    _score >= 100 ? const Color(0xFF2196F3) :
    Colors.grey;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Results Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mission Complete!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  performance,
                  style: TextStyle(
                    color: performanceColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Results Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
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
                children: [
                  // Score Circle with Animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'POINTS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Stats
                  _buildResultStat('🐾', 'Animals Saved', '$_animalsCollected', const Color(0xFF4CAF50)),
                  _buildResultStat('🎯', 'Final Score', '$_score', const Color(0xFF667eea)),
                  _buildResultStat('⏰', 'Time Used', '${60 - _timeLeft}s', const Color(0xFFFF9800)),

                  // New High Score Badge
                  if (_isNewHighScore) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFA000).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'NEW HIGH SCORE!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: const BorderSide(color: Color(0xFF667eea), width: 2),
                          ),
                          child: const Text(
                            'Exit',
                            style: TextStyle(
                              color: Color(0xFF667eea),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _restartGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Rescue Again',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
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
        ],
      ),
    );
  }

  Widget _buildResultStat(String emoji, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// Background Pattern Painter
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (double i = 0; i < size.width; i += 40) {
      for (double j = 0; j < size.height; j += 40) {
        canvas.drawCircle(Offset(i, j), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Updated Flame Game with Modern Features - FIXED for Flame 1.33.0
class WildlifeRescueFlameGame extends FlameGame {
  final Function(AnimalType, int) onAnimalCollected;
  final Function() onAnimalMissed;
  final Function() onGameOver;
  final Function(int) onComboUpdate;

  late TimerComponent _spawnTimer;
  late TimerComponent _gameTimer;
  late RescueTruck _rescueTruck;
  late Component _background;

  bool _gameActive = false;
  int _animalsOnScreen = 0;
  final int _maxAnimals = 8;
  int _combo = 0;
  dart.Timer? _comboTimer;

  WildlifeRescueFlameGame({
    required this.onAnimalCollected,
    required this.onAnimalMissed,
    required this.onGameOver,
    required this.onComboUpdate,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add modern background
    _background = _ModernBackground();
    add(_background);

    // Add rescue truck at bottom
    _rescueTruck = RescueTruck();
    add(_rescueTruck);

    // Setup spawn timer
    _spawnTimer = TimerComponent(
      period: 1.5,
      repeat: true,
      onTick: _spawnAnimal,
    );
    add(_spawnTimer);

    // Game duration timer
    _gameTimer = TimerComponent(
      period: 60,
      onTick: endGame,
    );
    add(_gameTimer);
  }

  void startGame() {
    _gameActive = true;
    _combo = 0;
    _spawnTimer.timer.start();
    _gameTimer.timer.start();
    onComboUpdate(_combo);
  }

  void endGame() {
    _gameActive = false;
    _spawnTimer.timer.stop();
    _gameTimer.timer.stop();
    _comboTimer?.cancel();

    // Remove all animals
    children.whereType<Animal>().toList().forEach((animal) {
      animal.removeFromParent();
    });

    onGameOver();
  }

  void _spawnAnimal() {
    if (!_gameActive || _animalsOnScreen >= _maxAnimals) return;

    final random = math.Random();
    final animalTypes = AnimalType.values;
    final animalType = animalTypes[random.nextInt(animalTypes.length)];

    final animal = Animal(
      type: animalType,
      onCollected: () {
        final comboBonus = _combo > 1 ? (_combo * 5) : 0;
        onAnimalCollected(animalType, comboBonus);
        _animalsOnScreen--;

        // Handle combo system
        _combo++;
        onComboUpdate(_combo);
        _comboTimer?.cancel();
        _comboTimer = dart.Timer.periodic(const Duration(seconds: 3), (timer) {
          _combo = 0;
          onComboUpdate(_combo);
          timer.cancel();
        });
      },
      onMissed: () {
        onAnimalMissed();
        _animalsOnScreen--;
        _combo = 0;
        onComboUpdate(_combo);
        _comboTimer?.cancel();
      },
    );

    add(animal);
    _animalsOnScreen++;
  }

  // Handle pan/tap events for animal interaction
  Animal? _getAnimalAtPosition(Vector2 position) {
    for (final animal in children.whereType<Animal>()) {
      if (animal.containsPoint(position)) {
        return animal;
      }
    }
    return null;
  }

  Animal? _draggedAnimal;

  bool onDragStart(DragStartEvent event) {
    final animal = _getAnimalAtPosition(event.localPosition);
    if (animal != null) {
      _draggedAnimal = animal;
      animal.handleDragStart(event.localPosition);
      return true;
    }
    return false;
  }

  bool onDragUpdate(DragUpdateEvent event) {
    if (_draggedAnimal != null) {
      _draggedAnimal!.handleDragUpdate(event.localDelta);
      return true;
    }
    return false;
  }

  bool onDragEnd(DragEndEvent event) {
    if (_draggedAnimal != null) {
      _draggedAnimal!.handleDragEnd();
      _draggedAnimal = null;
      return true;
    }
    return false;
  }

  bool onTapUp(TapUpEvent event) {
    final animal = _getAnimalAtPosition(event.localPosition);
    if (animal != null) {
      animal.handleTap();
      return true;
    }
    return false;
  }
}

// Modern Background Component
class _ModernBackground extends Component with HasGameReference<WildlifeRescueFlameGame> {
  @override
  void render(Canvas canvas) {
    final size = game.size;
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE8F5E8), Color(0xFFF0F8FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

    // Draw some background elements
    final elementPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.1);

    for (double i = 0; i < size.x; i += 80) {
      for (double j = 0; j < size.y; j += 80) {
        canvas.drawCircle(Offset(i, j), 3, elementPaint);
      }
    }
  }
}

// Updated Animal Types with more variety
enum AnimalType {
  turtle(Icons.cruelty_free, 50, Colors.green, 'Sea Turtle'),
  dolphin(Icons.waves, 75, Colors.blue, 'Dolphin'),
  penguin(Icons.ac_unit, 60, Colors.black, 'Penguin'),
  seal(Icons.pets, 40, Colors.grey, 'Seal'),
  whale(Icons.water, 100, Colors.deepPurple, 'Whale'),
  bird(Icons.flight, 30, Colors.orange, 'Seabird'),
  otter(Icons.dew_point, 55, Colors.brown, 'Otter'),
  fish(Icons.water_drop, 25, Colors.cyan, 'Tropical Fish');

  final IconData icon;
  final int points;
  final Color color;
  final String name;

  const AnimalType(this.icon, this.points, this.color, this.name);
}

// Modern Rescue Truck Component
class RescueTruck extends PositionComponent {
  RescueTruck() {
    position = Vector2(100, 500);
    size = Vector2(140, 90);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    // Draw truck body with rounded corners
    final truckRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(15),
    );
    canvas.drawRRect(truckRect, paint);

    // Draw truck cabin
    final cabinPaint = Paint()..color = Colors.white.withOpacity(0.9);
    final cabinRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * 0.1, size.y * 0.2, size.x * 0.4, size.y * 0.6),
      const Radius.circular(8),
    );
    canvas.drawRRect(cabinRect, cabinPaint);

    // Draw rescue text with modern style
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'RESCUE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.x * 0.55, size.y / 2 - 7));

    // Draw wheels
    final wheelPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.x * 0.25, size.y), 12, wheelPaint);
    canvas.drawCircle(Offset(size.x * 0.75, size.y), 12, wheelPaint);
  }
}

// Modern Animal Component - FIXED for Flame 1.33.0
class Animal extends PositionComponent with HasGameReference<WildlifeRescueFlameGame> {
  final AnimalType type;
  final VoidCallback onCollected;
  final VoidCallback onMissed;

  late TimerComponent _lifeTimer;
  bool _isCollected = false;
  bool _isDragging = false;
  double _bounceValue = 0;

  Animal({
    required this.type,
    required this.onCollected,
    required this.onMissed,
  }) {
    final random = math.Random();
    position = Vector2(
      random.nextDouble() * 300 + 50,
      -80,
    );
    size = Vector2(70, 70);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _lifeTimer = TimerComponent(
      period: 7,
      onTick: () {
        if (!_isCollected && !_isDragging) {
          onMissed();
          removeFromParent();
        }
      },
    );
    add(_lifeTimer);
    _lifeTimer.timer.start();

    // Add floating animation
    add(
      MoveEffect.by(
        Vector2(0, 450),
        EffectController(
          duration: 5 + math.Random().nextDouble() * 2,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // Add continuous bounce animation
    add(
      SequenceEffect(
        [
          ScaleEffect.by(
            Vector2.all(0.1),
            EffectController(duration: 0.3, curve: Curves.easeOut),
          ),
          ScaleEffect.by(
            Vector2.all(-0.1),
            EffectController(duration: 0.3, curve: Curves.easeIn),
          ),
        ],
        infinite: true,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bounceValue = (_bounceValue + dt * 8) % (2 * math.pi);
  }

  @override
  void render(Canvas canvas) {
    final bounceOffset = math.sin(_bounceValue) * 3;

    // Draw animal container with modern design
    final containerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          type.color,
          type.color.withOpacity(0.8),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.x / 2, size.y / 2),
        radius: size.x / 2,
      ));

    // Draw main circle with shadow effect
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2 + bounceOffset),
      size.x / 2 - 2,
      containerPaint,
    );

    // Draw animal icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(type.icon.codePoint),
        style: TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontFamily: type.icon.fontFamily,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        size.x / 2 - iconPainter.width / 2,
        size.y / 2 - iconPainter.height / 2 + bounceOffset,
      ),
    );

    // Draw modern points badge
    final pointsBackground = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.x - 18, 18), 16, pointsBackground);

    final pointsText = TextPainter(
      text: TextSpan(
        text: '${type.points}',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    pointsText.layout();
    pointsText.paint(canvas, Offset(size.x - 18 - pointsText.width / 2, 18 - pointsText.height / 2));
  }

  // Drag and tap handlers - handled by game level
  void handleDragStart(Vector2 position) {
    _isDragging = true;
    // Add scale effect when dragging
    add(ScaleEffect.by(Vector2.all(0.1), EffectController(duration: 0.2)));
  }

  void handleDragUpdate(Vector2 delta) {
    position.add(delta);
  }

  void handleDragEnd() {
    _isDragging = false;
    add(ScaleEffect.by(Vector2.all(-0.1), EffectController(duration: 0.2)));
    _checkCollection();
  }

  void handleTap() {
    _checkCollection();
  }

  void _checkCollection() {
    final truck = parent!.children.whereType<RescueTruck>().first;
    final distance = position.distanceTo(truck.position);

    if (distance < 120) {
      _isCollected = true;
      onCollected();

      // Add collection particles
      add(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 15,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(0, 100),
              speed: Vector2(
                (math.Random().nextDouble() - 0.5) * 200,
                -math.Random().nextDouble() * 200,
              ),
              position: position.clone(),
              child: CircleParticle(
                radius: 2 + math.Random().nextDouble() * 3,
                paint: Paint()..color = type.color,
              ),
            ),
          ),
        ),
      );

      // Add collection animation
      add(
        SequenceEffect(
          [
            ScaleEffect.by(Vector2.all(0.3), EffectController(duration: 0.2)),
            OpacityEffect.to(0.0, EffectController(duration: 0.3)),
          ],
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (isMounted) {
          removeFromParent();
        }
      });
    }
  }
}