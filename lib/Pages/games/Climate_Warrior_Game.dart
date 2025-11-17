import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/game_progress_service.dart';
import '../../models/achievement.dart';

class ClimateWarriorGame extends StatefulWidget {
  const ClimateWarriorGame({super.key});

  @override
  State<ClimateWarriorGame> createState() => _ClimateWarriorGameState();
}

class _ClimateWarriorGameState extends State<ClimateWarriorGame>
    with TickerProviderStateMixin {
  // Game state
  int _score = 0;
  int _timeLeft = 150;
  int _lives = 3;
  int _carbonReduced = 0;
  bool _isGameActive = false;
  bool _isGameOver = false;
  int _level = 1;
  bool _isSavingProgress = false;
  List<Achievement> _newAchievements = [];
  int _highScore = 0;
  bool _isNewHighScore = false;

  // Player position
  double _playerX = 0.5;
  double _playerY = 0.8;

  // Game objects
  List<ClimateChallenge> _challenges = [];
  List<PowerUp> _powerUps = [];

  // Animation controllers
  late AnimationController _gameLoopController;
  late AnimationController _playerAnimationController;

  // Input handling
  bool _movingLeft = false;
  bool _movingRight = false;

  @override
  void initState() {
    super.initState();
    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60 FPS
    );
    _playerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _initializeGame();
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    _playerAnimationController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    // Initialize empty game state
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _isGameOver = false;
      _score = 0;
      _timeLeft = 150;
      _lives = 3;
      _carbonReduced = 0;
      _level = 1;
      _playerX = 0.5;
      _playerY = 0.8;
      _challenges = [];
      _powerUps = [];
    });

    _gameLoopController.addListener(_gameLoop);
    _gameLoopController.forward();
    _startSpawners();
    _startTimer();
  }

  void _gameLoop() {
    if (!_isGameActive) return;

    setState(() {
      // Handle player movement
      if (_movingLeft && _playerX > 0.1) _playerX -= 0.02;
      if (_movingRight && _playerX < 0.9) _playerX += 0.02;

      // Update challenges
      _updateChallenges();

      // Update power-ups
      _updatePowerUps();

      // Check collisions
      _checkCollisions();
    });
  }

  void _updateChallenges() {
    // Move challenges down
    for (int i = _challenges.length - 1; i >= 0; i--) {
      final challenge = _challenges[i];
      final newY = challenge.position.dy + 0.01;

      if (newY > 1.2) {
        _challenges.removeAt(i);
        if (challenge.type == ChallengeType.ecoFriendly) {
          _loseLife();
        }
      } else {
        _challenges[i] = challenge.copyWith(
          position: Offset(challenge.position.dx, newY),
        );
      }
    }
  }

  void _updatePowerUps() {
    // Move power-ups down
    for (int i = _powerUps.length - 1; i >= 0; i--) {
      final powerUp = _powerUps[i];
      final newY = powerUp.position.dy + 0.008;

      if (newY > 1.2) {
        _powerUps.removeAt(i);
      } else {
        _powerUps[i] = powerUp.copyWith(
          position: Offset(powerUp.position.dx, newY),
        );
      }
    }
  }

  void _checkCollisions() {
    final playerRect = Rect.fromCenter(
      center: Offset(_playerX, _playerY),
      width: 0.1,
      height: 0.1,
    );

    // Check challenge collisions
    for (int i = _challenges.length - 1; i >= 0; i--) {
      final challenge = _challenges[i];
      final challengeRect = Rect.fromCenter(
        center: challenge.position,
        width: 0.08,
        height: 0.08,
      );

      if (playerRect.overlaps(challengeRect)) {
        _challenges.removeAt(i);
        _handleChallengeCollision(challenge);
      }
    }

    // Check power-up collisions
    for (int i = _powerUps.length - 1; i >= 0; i--) {
      final powerUp = _powerUps[i];
      final powerUpRect = Rect.fromCenter(
        center: powerUp.position,
        width: 0.06,
        height: 0.06,
      );

      if (playerRect.overlaps(powerUpRect)) {
        _powerUps.removeAt(i);
        _handlePowerUpCollision(powerUp);
      }
    }
  }

  void _handleChallengeCollision(ClimateChallenge challenge) {
    switch (challenge.type) {
      case ChallengeType.pollution:
        _score += 20;
        _carbonReduced += 10;
        break;
      case ChallengeType.deforestation:
        _score += 30;
        _carbonReduced += 15;
        break;
      case ChallengeType.fossilFuel:
        _score += 25;
        _carbonReduced += 12;
        break;
      case ChallengeType.ecoFriendly:
        _loseLife();
        break;
    }

    _checkLevelUp();
  }

  void _handlePowerUpCollision(PowerUp powerUp) {
    switch (powerUp.type) {
      case PowerUpType.time:
        _timeLeft += 15;
        break;
      case PowerUpType.life:
        _lives = (_lives + 1).clamp(0, 5);
        break;
      case PowerUpType.score:
        _score += 100;
        break;
      case PowerUpType.slow:
      // Slow down challenges for 5 seconds
        _activateSlowMode();
        break;
    }
  }

  void _activateSlowMode() {
    // Implementation for slow mode power-up
  }

  void _loseLife() {
    setState(() {
      _lives--;
      if (_lives <= 0) {
        _endGame();
      }
    });
  }

  void _checkLevelUp() {
    final newLevel = (_score ~/ 500) + 1;
    if (newLevel > _level) {
      setState(() {
        _level = newLevel;
      });
    }
  }

  void _startSpawners() {
    _spawnChallenge();
    _spawnPowerUp();
  }

  void _spawnChallenge() {
    if (!_isGameActive) return;

    final random = math.Random();
    final types = ChallengeType.values;
    final challengeType = types[random.nextInt(types.length - 1)]; // Exclude eco-friendly

    setState(() {
      _challenges.add(ClimateChallenge(
        id: DateTime.now().microsecondsSinceEpoch,
        type: challengeType,
        position: Offset(random.nextDouble() * 0.8 + 0.1, -0.1),
      ));
    });

    // Spawn eco-friendly challenge occasionally
    if (random.nextDouble() < 0.1) {
      setState(() {
        _challenges.add(ClimateChallenge(
          id: DateTime.now().microsecondsSinceEpoch + 1,
          type: ChallengeType.ecoFriendly,
          position: Offset(random.nextDouble() * 0.8 + 0.1, -0.1),
        ));
      });
    }

    final spawnDelay = math.max(500, 2000 - (_level * 150)); // Faster spawning as level increases
    Future.delayed(Duration(milliseconds: spawnDelay.toInt()), _spawnChallenge);
  }

  void _spawnPowerUp() {
    if (!_isGameActive) return;

    final random = math.Random();
    if (random.nextDouble() < 0.3) { // 30% chance to spawn power-up
      final types = PowerUpType.values;
      final powerUpType = types[random.nextInt(types.length)];

      setState(() {
        _powerUps.add(PowerUp(
          id: DateTime.now().microsecondsSinceEpoch,
          type: powerUpType,
          position: Offset(random.nextDouble() * 0.8 + 0.1, -0.1),
        ));
      });
    }

    Future.delayed(const Duration(seconds: 5), _spawnPowerUp);
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

  void _endGame() async {
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
      _isSavingProgress = true;
    });
    _gameLoopController.removeListener(_gameLoop);

    // Save game progress and check for achievements
    final gameProgressService = GameProgressService();
    final result = await gameProgressService.recordGameCompletion(
      gameCategory: 'climate_warrior',
      score: _score,
    );

    if (mounted) {
      setState(() {
        _isSavingProgress = false;
        if (result['success']) {
          _newAchievements = result['newAchievements'] ?? [];

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
              Icon(Icons.help_outline, color: Color(0xFF9C27B0)),
              SizedBox(width: 8),
              Text(
                'Climate Warrior',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fight Climate Change',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const _InstructionItem(
                icon: Icons.touch_app,
                text: 'Tap left/right to move your climate warrior',
              ),
              const _InstructionItem(
                icon: Icons.warning,
                text: 'Collect environmental challenges to reduce carbon',
              ),
              const _InstructionItem(
                icon: Icons.block,
                text: 'Avoid greenwashing (fake eco-friendly items)',
              ),
              const _InstructionItem(
                icon: Icons.auto_awesome,
                text: 'Collect power-ups for extra time and lives',
              ),
              const _InstructionItem(
                icon: Icons.timer,
                text: 'Survive as long as possible and reduce maximum carbon!',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Start Fighting!',
                style: TextStyle(color: Color(0xFF9C27B0)),
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
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Climate Warrior',
          style: TextStyle(
            color: Color(0xFF9C27B0),
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
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 2) {
            _movingLeft = true;
          } else {
            _movingRight = true;
          }
        },
        onTapUp: (_) {
          _movingLeft = false;
          _movingRight = false;
        },
        onTapCancel: () {
          _movingLeft = false;
          _movingRight = false;
        },
        child: Column(
          children: [
            // Game Stats
            _buildGameStats(),
            const SizedBox(height: 16),

            // Game Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    // Background
                    _buildGameBackground(),

                    // Game Objects
                    ..._buildChallenges(),
                    ..._buildPowerUps(),

                    // Player
                    _buildPlayer(),

                    // Game Over Overlay
                    if (_isGameOver) _buildGameOverlay(),

                    // Start Game Overlay
                    if (!_isGameActive && !_isGameOver) _buildStartOverlay(),
                  ],
                ),
              ),
            ),

            // Control Hints
            if (_isGameActive) _buildControlHints(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
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
          _buildStatItem('LIVES', '$_lives', Icons.favorite, Colors.red),
          _buildStatItem('LEVEL', '$_level', Icons.star, const Color(0xFFFF9800)),
          _buildStatItem('CO₂', '-$_carbonReduced', Icons.cloud, const Color(0xFF9C27B0)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildGameBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE1BEE7),
            Color(0xFFCE93D8),
            Color(0xFFBA68C8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChallenges() {
    return _challenges.map((challenge) {
      final gameAreaWidth = MediaQuery.of(context).size.width - 32;
      final gameAreaHeight = MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top +
              kToolbarHeight +
              200);

      return Positioned(
        left: challenge.position.dx * gameAreaWidth,
        top: challenge.position.dy * gameAreaHeight,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: challenge.type.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: challenge.type.color.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            challenge.type.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildPowerUps() {
    return _powerUps.map((powerUp) {
      final gameAreaWidth = MediaQuery.of(context).size.width - 32;
      final gameAreaHeight = MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top +
              kToolbarHeight +
              200);

      return Positioned(
        left: powerUp.position.dx * gameAreaWidth,
        top: powerUp.position.dy * gameAreaHeight,
        child: AnimatedBuilder(
          animation: _playerAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + _playerAnimationController.value * 0.3,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: powerUp.type.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: powerUp.type.color.withOpacity(0.7),
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  powerUp.type.icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildPlayer() {
    final gameAreaWidth = MediaQuery.of(context).size.width - 32;
    final gameAreaHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top +
            kToolbarHeight +
            200);

    return Positioned(
      left: _playerX * gameAreaWidth - 25,
      top: _playerY * gameAreaHeight - 25,
      child: AnimatedBuilder(
        animation: _playerAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _playerAnimationController.value * 5),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlHints() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Tap Left',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text(
                  'Tap Right',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.psychology_rounded,
                color: Color(0xFF9C27B0),
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Climate Warrior',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fight climate change by collecting environmental challenges and avoiding greenwashing!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
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
                        'Start Mission',
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
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
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
                color: Color(0xFF9C27B0),
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Mission Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You reduced $_carbonReduced kg of CO₂!',
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
              const SizedBox(height: 8),
              Text(
                'Level Reached: $_level',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
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
                        side: const BorderSide(color: Color(0xFF9C27B0)),
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(color: Color(0xFF9C27B0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
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

enum ChallengeType {
  pollution(Icons.factory, Colors.red, 'Industrial Pollution'),
  deforestation(Icons.park, Colors.brown, 'Deforestation'),
  fossilFuel(Icons.local_gas_station, Colors.orange, 'Fossil Fuels'),
  ecoFriendly(Icons.eco, Colors.green, 'Greenwashing');

  final IconData icon;
  final Color color;
  final String description;

  const ChallengeType(this.icon, this.color, this.description);
}

enum PowerUpType {
  time(Icons.timer, Colors.blue, 'Extra Time'),
  life(Icons.favorite, Colors.red, 'Extra Life'),
  score(Icons.star, Colors.amber, 'Bonus Points'),
  slow(Icons.slow_motion_video, Colors.purple, 'Slow Motion');

  final IconData icon;
  final Color color;
  final String description;

  const PowerUpType(this.icon, this.color, this.description);
}

class ClimateChallenge {
  final int id;
  final ChallengeType type;
  final Offset position;

  const ClimateChallenge({
    required this.id,
    required this.type,
    required this.position,
  });

  ClimateChallenge copyWith({
    Offset? position,
  }) {
    return ClimateChallenge(
      id: id,
      type: type,
      position: position ?? this.position,
    );
  }
}

class PowerUp {
  final int id;
  final PowerUpType type;
  final Offset position;

  const PowerUp({
    required this.id,
    required this.type,
    required this.position,
  });

  PowerUp copyWith({
    Offset? position,
  }) {
    return PowerUp(
      id: id,
      type: type,
      position: position ?? this.position,
    );
  }
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
          Icon(icon, color: const Color(0xFF9C27B0), size: 16),
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