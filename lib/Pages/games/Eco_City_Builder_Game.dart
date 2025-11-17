import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/game_progress_service.dart';
import '../../models/achievement.dart';

class EcoCityBuilderGame extends StatefulWidget {
  const EcoCityBuilderGame({super.key});

  @override
  State<EcoCityBuilderGame> createState() => _EcoCityBuilderGameState();
}

class _EcoCityBuilderGameState extends State<EcoCityBuilderGame>
    with TickerProviderStateMixin {
  // Game state
  int _energy = 100;
  int _population = 0;
  int _ecoScore = 0;
  int _money = 500;
  int _carbonFootprint = 100;
  bool _isGameActive = false;
  bool _isGameOver = false;
  bool _isSavingProgress = false;
  List<Achievement> _newAchievements = [];
  int _highScore = 0;
  bool _isNewHighScore = false;

  // Buildings
  List<CityBuilding> _buildings = [];
  List<BuildingType> _availableBuildings = [];

  // Animation
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _initializeBuildings();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final gameProgressService = GameProgressService();
    final highScore = await gameProgressService.getHighScore('eco_city_builder');
    if (mounted) {
      setState(() {
        _highScore = highScore;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeBuildings() {
    _availableBuildings = [
      BuildingType(
        name: 'Solar Farm',
        cost: 200,
        energyProduction: 50,
        population: 0,
        ecoImpact: 30,
        icon: Icons.solar_power,
        color: Colors.amber,
        description: 'Clean renewable energy',
      ),
      BuildingType(
        name: 'Wind Turbine',
        cost: 150,
        energyProduction: 30,
        population: 0,
        ecoImpact: 25,
        icon: Icons.air,
        color: Colors.blue,
        description: 'Wind-powered electricity',
      ),
      BuildingType(
        name: 'Green Housing',
        cost: 300,
        energyProduction: -20,
        population: 100,
        ecoImpact: 40,
        icon: Icons.house,
        color: Colors.green,
        description: 'Sustainable living spaces',
      ),
      BuildingType(
        name: 'Recycling Center',
        cost: 180,
        energyProduction: -10,
        population: 0,
        ecoImpact: 35,
        icon: Icons.recycling,
        color: Colors.lightGreen,
        description: 'Waste management system',
      ),
      BuildingType(
        name: 'Urban Farm',
        cost: 220,
        energyProduction: -5,
        population: 50,
        ecoImpact: 45,
        icon: Icons.spa,
        color: Colors.lightGreen,
        description: 'Local food production',
      ),
      BuildingType(
        name: 'Public Transport',
        cost: 250,
        energyProduction: -15,
        population: 80,
        ecoImpact: 50,
        icon: Icons.directions_bus,
        color: Colors.deepPurple,
        description: 'Eco-friendly mobility',
      ),
    ];
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _isGameOver = false;
      _energy = 100;
      _population = 0;
      _ecoScore = 0;
      _money = 500;
      _carbonFootprint = 100;
      _buildings = [];
    });
    _startGameLoop();
  }

  void _startGameLoop() {
    Future.delayed(const Duration(seconds: 2), () {
      if (_isGameActive && !_isGameOver) {
        setState(() {
          // Update game state
          _updateGameState();
          _checkWinCondition();
        });
        _startGameLoop();
      }
    });
  }

  void _updateGameState() {
    // Calculate total energy production/consumption
    int totalEnergy = 0;
    int totalPopulation = 0;
    int totalEcoImpact = 0;

    for (final building in _buildings) {
      totalEnergy += building.type.energyProduction;
      totalPopulation += building.type.population;
      totalEcoImpact += building.type.ecoImpact;
    }

    _energy = (_energy + totalEnergy).clamp(0, 500);
    _population += totalPopulation;
    _ecoScore += totalEcoImpact;
    _carbonFootprint = (100 - (_ecoScore ~/ 10)).clamp(0, 100);

    // Generate income based on population and eco score
    _money += (_population ~/ 10) + (_ecoScore ~/ 20);

    // Check for game over
    if (_energy <= 0 || _carbonFootprint >= 95) {
      _endGame(false);
    }
  }

  void _checkWinCondition() {
    if (_carbonFootprint <= 10 && _population >= 1000 && _ecoScore >= 500) {
      _endGame(true);
    }
  }

  void _endGame(bool isWin) async {
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
      _isSavingProgress = true;
    });

    // Save game progress and check for achievements
    final gameProgressService = GameProgressService();
    final result = await gameProgressService.recordGameCompletion(
      gameCategory: 'eco_city_builder',
      score: _ecoScore,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      achievement.name,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _buildStructure(BuildingType buildingType) {
    if (_money >= buildingType.cost) {
      setState(() {
        _money -= buildingType.cost;
        _buildings.add(CityBuilding(
          id: _buildings.length,
          type: buildingType,
          position: _getRandomPosition(),
        ));
      });
    }
  }

  Offset _getRandomPosition() {
    return Offset(
      math.Random().nextDouble() * 0.7 + 0.15,
      math.Random().nextDouble() * 0.5 + 0.25,
    );
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
              Icon(Icons.help_outline, color: Color(0xFF8BC34A)),
              SizedBox(width: 8),
              Text(
                'Eco City Builder',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8BC34A),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Build a Sustainable City',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const _InstructionItem(
                icon: Icons.architecture,
                text: 'Build eco-friendly structures to grow your city',
              ),
              const _InstructionItem(
                icon: Icons.eco,
                text: 'Balance energy production with population needs',
              ),
              const _InstructionItem(
                icon: Icons.warning,
                text: 'Keep carbon footprint below 10% to win',
              ),
              const _InstructionItem(
                icon: Icons.people,
                text: 'Reach 1000 population with high eco score',
              ),
              const SizedBox(height: 8),
              Text(
                'Available Buildings: ${_availableBuildings.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Start Building!',
                style: TextStyle(color: Color(0xFF8BC34A)),
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
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Eco City Builder',
          style: TextStyle(
            color: Color(0xFF8BC34A),
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
          // Game Stats Header
          _buildStatsHeader(),
          const SizedBox(height: 16),

          // Game Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: [
                  // City Background
                  _buildCityBackground(),

                  // Buildings
                  ..._buildBuildings(),

                  // Game Over Overlay
                  if (_isGameOver) _buildGameOverlay(),

                  // Start Game Overlay
                  if (!_isGameActive && !_isGameOver) _buildStartOverlay(),
                ],
              ),
            ),
          ),

          // Building Menu
          if (_isGameActive && !_isGameOver) _buildBuildingMenu(),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
          _buildStatItem('ENERGY', '$_energy', Icons.bolt, _getEnergyColor()),
          _buildStatItem('POPULATION', '$_population', Icons.people, const Color(0xFF2196F3)),
          _buildStatItem('MONEY', '\$$_money', Icons.attach_money, const Color(0xFF4CAF50)),
          _buildStatItem('CARBON', '${_carbonFootprint}%', Icons.cloud, _getCarbonColor()),
        ],
      ),
    );
  }

  Color _getEnergyColor() {
    if (_energy > 300) return Colors.green;
    if (_energy > 100) return Colors.orange;
    return Colors.red;
  }

  Color _getCarbonColor() {
    if (_carbonFootprint < 20) return Colors.green;
    if (_carbonFootprint < 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
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
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCityBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB),
            Color(0xFF98FB98),
            Color(0xFF90EE90),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: _CityBackgroundPainter(),
        ),
      ),
    );
  }

  List<Widget> _buildBuildings() {
    return _buildings.map((building) {
      final gameAreaWidth = MediaQuery.of(context).size.width - 32;
      final gameAreaHeight = MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top +
              kToolbarHeight +
              200);

      return Positioned(
        left: building.position.dx * gameAreaWidth,
        top: building.position.dy * gameAreaHeight,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _pulseController.value * 2),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: building.type.color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: building.type.color.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  building.type.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildBuildingMenu() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _availableBuildings.map((building) {
          return _buildBuildingCard(building);
        }).toList(),
      ),
    );
  }

  Widget _buildBuildingCard(BuildingType building) {
    final canAfford = _money >= building.cost;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: canAfford ? building.color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canAfford ? building.color : Colors.grey,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canAfford ? () => _buildStructure(building) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(building.icon, color: canAfford ? building.color : Colors.grey, size: 24),
                const SizedBox(height: 8),
                Text(
                  building.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? building.color : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${building.cost}',
                  style: TextStyle(
                    fontSize: 11,
                    color: canAfford ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                Icons.architecture_rounded,
                color: Color(0xFF8BC34A),
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Eco City Builder',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8BC34A),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Build a sustainable city with renewable energy and green infrastructure!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
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
                    colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
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
                        'Start Building',
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
    final isWin = _carbonFootprint <= 10 && _population >= 1000;

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
                color: (isWin ? Colors.green : Colors.red).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWin ? Icons.emoji_events_rounded : Icons.warning_rounded,
                color: isWin ? const Color(0xFF8BC34A) : Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                isWin ? 'City Sustainable!' : 'City Failed',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isWin ? const Color(0xFF8BC34A) : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isWin
                    ? 'You built an eco-friendly city for $_population people!'
                    : 'Carbon footprint too high at ${_carbonFootprint}%',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Final Score: $_ecoScore',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
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
              if (_isSavingProgress) ...[
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Saving progress...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
              if (_newAchievements.isNotEmpty && !_isSavingProgress) ...[
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
                        '${_newAchievements.length} New Achievement${_newAchievements.length > 1 ? 's' : ''}!',
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
                        side: BorderSide(
                          color: isWin ? const Color(0xFF8BC34A) : Colors.red,
                        ),
                      ),
                      child: Text(
                        'Exit',
                        style: TextStyle(
                          color: isWin ? const Color(0xFF8BC34A) : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isWin
                              ? [const Color(0xFF8BC34A), const Color(0xFF689F38)]
                              : [Colors.red, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        onPressed: _startGame,
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

class _CityBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA5D6A7)
      ..style = PaintingStyle.fill;

    // Draw ground
    final groundPath = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(groundPath, paint);

    // Draw some decorative elements
    final treePaint = Paint()..color = const Color(0xFF2E7D32);
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);

    // Draw trees
    for (double x = 0.1; x < 0.9; x += 0.2) {
      final treeX = size.width * x;
      final treeY = size.height * 0.65;

      // Tree trunk
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(treeX, treeY + 15),
          width: 8,
          height: 30,
        ),
        trunkPaint,
      );

      // Tree top
      canvas.drawCircle(Offset(treeX, treeY), 20, treePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BuildingType {
  final String name;
  final int cost;
  final int energyProduction;
  final int population;
  final int ecoImpact;
  final IconData icon;
  final Color color;
  final String description;

  const BuildingType({
    required this.name,
    required this.cost,
    required this.energyProduction,
    required this.population,
    required this.ecoImpact,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class CityBuilding {
  final int id;
  final BuildingType type;
  final Offset position;

  const CityBuilding({
    required this.id,
    required this.type,
    required this.position,
  });
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
          Icon(icon, color: const Color(0xFF8BC34A), size: 16),
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