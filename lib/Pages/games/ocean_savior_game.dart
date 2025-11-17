import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/game_progress_service.dart';
import '../../models/achievement.dart';

class OceanSaviorGame extends StatefulWidget {
  const OceanSaviorGame({super.key});

  @override
  State<OceanSaviorGame> createState() => _OceanSaviorGameState();
}

class _OceanSaviorGameState extends State<OceanSaviorGame> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  bool _isSavingProgress = false;
  List<Achievement> _newAchievements = [];
  int _highScore = 0;
  bool _isNewHighScore = false;
  List<bool?> _userAnswers = List.filled(5, null); // Track answers for each question
  List<QuizQuestion> _selectedQuestions = []; // Will hold the 5 random questions

  final List<QuizQuestion> _allQuestions = [
    QuizQuestion(
      question: "What is the main cause of ocean plastic pollution?",
      options: [
        "Natural ocean currents",
        "Human litter and improper waste disposal",
        "Marine animal activities",
        "Underwater volcanic eruptions"
      ],
      correctAnswerIndex: 1,
      explanation: "Over 80% of ocean plastic comes from land-based sources due to improper waste management and littering.",
    ),
    QuizQuestion(
      question: "How long does it take for a plastic bottle to decompose in the ocean?",
      options: [
        "5 years",
        "50 years",
        "450 years",
        "1,000 years"
      ],
      correctAnswerIndex: 2,
      explanation: "Plastic bottles can take up to 450 years to decompose, posing long-term threats to marine life.",
    ),
    QuizQuestion(
      question: "Which marine animal is most affected by plastic straws?",
      options: [
        "Sharks",
        "Sea turtles",
        "Dolphins",
        "Whales"
      ],
      correctAnswerIndex: 1,
      explanation: "Sea turtles often mistake plastic straws for food, causing internal injuries and death.",
    ),
    QuizQuestion(
      question: "What percentage of ocean plastic ends up on the seafloor?",
      options: [
        "10%",
        "30%",
        "50%",
        "70%"
      ],
      correctAnswerIndex: 3,
      explanation: "Approximately 70% of marine plastic sinks to the seafloor, affecting deep-sea ecosystems.",
    ),
    QuizQuestion(
      question: "Which action is most effective in reducing ocean plastic?",
      options: [
        "Beach cleanups",
        "Using reusable containers",
        "Recycling plastic",
        "All of the above"
      ],
      correctAnswerIndex: 3,
      explanation: "A combination of prevention (reusables), cleanup efforts, and proper recycling is most effective.",
    ),
    QuizQuestion(
      question: "What is the Great Pacific Garbage Patch primarily composed of?",
      options: [
        "Large plastic items like bottles and containers",
        "Microplastics and broken-down plastic particles",
        "Natural seaweed and ocean plants",
        "Abandoned fishing gear only"
      ],
      correctAnswerIndex: 1,
      explanation: "The Great Pacific Garbage Patch is mostly microplastics - tiny plastic particles less than 5mm in size that are difficult to clean up.",
    ),
    QuizQuestion(
      question: "How many marine animals die each year due to plastic pollution?",
      options: [
        "10,000",
        "100,000",
        "1 million",
        "Over 100 million"
      ],
      correctAnswerIndex: 3,
      explanation: "Scientists estimate over 100 million marine animals die each year from plastic entanglement or ingestion.",
    ),
    QuizQuestion(
      question: "Which country is the largest contributor to ocean plastic pollution?",
      options: [
        "United States",
        "India",
        "China",
        "Indonesia"
      ],
      correctAnswerIndex: 2,
      explanation: "China contributes the most plastic waste to our oceans, followed by Indonesia and the Philippines.",
    ),
    QuizQuestion(
      question: "What are 'ghost nets' in the context of ocean pollution?",
      options: [
        "Plastic bags that look like jellyfish",
        "Abandoned or lost fishing nets",
        "Microplastic particles in the water",
        "Plastic bottles floating at night"
      ],
      correctAnswerIndex: 1,
      explanation: "Ghost nets are abandoned fishing nets that continue to trap and kill marine life for years.",
    ),
    QuizQuestion(
      question: "How does plastic affect coral reefs?",
      options: [
        "Plastic has no effect on coral reefs",
        "It makes corals more colorful",
        "It increases disease risk in corals by 20 times",
        "It helps corals grow faster"
      ],
      correctAnswerIndex: 2,
      explanation: "Plastic debris can increase the risk of disease in corals from 4% to 89% - a 20-fold increase.",
    ),
    QuizQuestion(
      question: "What percentage of seabirds have plastic in their stomachs?",
      options: [
        "25%",
        "50%",
        "75%",
        "90%"
      ],
      correctAnswerIndex: 3,
      explanation: "Studies show 90% of seabirds have plastic in their stomachs, and this could reach 99% by 2050.",
    ),
    QuizQuestion(
      question: "Which innovative solution uses river barriers to stop plastic from reaching oceans?",
      options: [
        "Ocean Cleanup Array",
        "The Bubble Barrier",
        "Plastic-eating bacteria",
        "Seabin Project"
      ],
      correctAnswerIndex: 1,
      explanation: "The Bubble Barrier creates a curtain of bubbles that pushes plastic to the surface for collection in rivers.",
    ),
    QuizQuestion(
      question: "What is the main source of microplastics in oceans?",
      options: [
        "Cosmetics and personal care products",
        "Car tire wear",
        "Synthetic clothing fibers",
        "All of the above"
      ],
      correctAnswerIndex: 3,
      explanation: "Microplastics come from various sources including cosmetics, tire dust, and synthetic fibers from laundry.",
    ),
    QuizQuestion(
      question: "How much plastic enters our oceans every year?",
      options: [
        "1 million tons",
        "5 million tons",
        "8 million tons",
        "15 million tons"
      ],
      correctAnswerIndex: 2,
      explanation: "Approximately 8 million tons of plastic enter our oceans annually - equivalent to a garbage truck every minute.",
    ),
    QuizQuestion(
      question: "Which organization leads the global effort for ocean conservation treaties?",
      options: [
        "World Wildlife Fund (WWF)",
        "United Nations Environment Programme (UNEP)",
        "Greenpeace",
        "Ocean Conservancy"
      ],
      correctAnswerIndex: 1,
      explanation: "UNEP leads international efforts including the Global Plastics Treaty to address ocean plastic pollution.",
    ),
    QuizQuestion(
      question: "What is 'plastic smog' in the ocean?",
      options: [
        "A type of pollution from burning plastic",
        "The haze created by plastic particles in water",
        "Tiny plastic particles suspended in ocean water",
        "Plastic bags floating on the surface"
      ],
      correctAnswerIndex: 2,
      explanation: "Plastic smog refers to the trillions of microplastic particles suspended in ocean water, creating a 'smog-like' effect.",
    ),
    QuizQuestion(
      question: "Which marine creature is known to eat plastic because it smells like food?",
      options: [
        "Sea turtles",
        "Anchovies",
        "Whales",
        "Sharks"
      ],
      correctAnswerIndex: 1,
      explanation: "Anchovies are attracted to plastic because algae grows on it, making it smell like their natural food.",
    ),
    QuizQuestion(
      question: "What percentage of plastic is actually recycled globally?",
      options: [
        "5%",
        "9%",
        "15%",
        "25%"
      ],
      correctAnswerIndex: 1,
      explanation: "Only about 9% of all plastic ever produced has been recycled, highlighting the need for better waste management.",
    ),
    QuizQuestion(
      question: "Which type of plastic is most commonly found in ocean cleanups?",
      options: [
        "PET bottles",
        "Plastic bags",
        "Food wrappers",
        "Fishing gear"
      ],
      correctAnswerIndex: 2,
      explanation: "Food wrappers and packaging are the most common items found during ocean and beach cleanups worldwide.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectRandomQuestions();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final gameProgressService = GameProgressService();
    final highScore = await gameProgressService.getHighScore('ocean_savior');
    if (mounted) {
      setState(() {
        _highScore = highScore;
      });
    }
  }

  void _selectRandomQuestions() {
    // Create a copy of all questions to avoid modifying the original list
    final availableQuestions = List<QuizQuestion>.from(_allQuestions);
    final random = math.Random();
    _selectedQuestions.clear();

    // Select 5 random questions
    for (int i = 0; i < 5; i++) {
      if (availableQuestions.isNotEmpty) {
        final randomIndex = random.nextInt(availableQuestions.length);
        _selectedQuestions.add(availableQuestions[randomIndex]);
        availableQuestions.removeAt(randomIndex); // Remove to avoid duplicates
      }
    }

    // Reset game state
    _userAnswers = List.filled(5, null);
    _currentQuestionIndex = 0;
    _score = 0;
    _quizCompleted = false;
  }

  void _answerQuestion(int selectedIndex) {
    if (_userAnswers[_currentQuestionIndex] != null) return; // Prevent multiple answers

    setState(() {
      _userAnswers[_currentQuestionIndex] = selectedIndex == _selectedQuestions[_currentQuestionIndex].correctAnswerIndex;

      if (selectedIndex == _selectedQuestions[_currentQuestionIndex].correctAnswerIndex) {
        _score += 20; // 20 points per correct answer
      }
    });

    // Move to next question after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentQuestionIndex < _selectedQuestions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        setState(() {
          _quizCompleted = true;
          _isSavingProgress = true;
        });

        // Save game progress and check for achievements
        _saveGameProgress();
      }
    });
  }

  void _saveGameProgress() async {
    final gameProgressService = GameProgressService();
    final result = await gameProgressService.recordGameCompletion(
      gameCategory: 'ocean_savior',
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

  void _restartQuiz() {
    setState(() {
      _selectRandomQuestions(); // Get new random questions
    });
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
              Icon(Icons.help_outline, color: Color(0xFF00BCD4)),
              SizedBox(width: 8),
              Text(
                'How to Play',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BCD4),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ocean Savior Quiz',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const _InstructionItem(
                icon: Icons.quiz,
                text: 'Answer 5 random questions about ocean conservation',
              ),
              const _InstructionItem(
                icon: Icons.autorenew,
                text: 'Questions change every time you play!',
              ),
              const _InstructionItem(
                icon: Icons.timer,
                text: 'Take your time - no time limit!',
              ),
              const _InstructionItem(
                icon: Icons.eco,
                text: 'Learn important facts about protecting our oceans',
              ),
              const _InstructionItem(
                icon: Icons.emoji_events,
                text: 'Score 20 points for each correct answer',
              ),
              const SizedBox(height: 8),
              Text(
                'Total questions in database: ${_allQuestions.length}',
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
                'Got it!',
                style: TextStyle(color: Color(0xFF00BCD4)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Don't build until questions are selected
    if (_selectedQuestions.isEmpty) {
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
            'Ocean Savior',
            style: TextStyle(
              color: Color(0xFF00BCD4),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00BCD4),
          ),
        ),
      );
    }

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
          'Ocean Savior',
          style: TextStyle(
            color: Color(0xFF00BCD4),
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
          // Game Header with Progress
          _buildGameHeader(),
          const SizedBox(height: 20),

          // Game Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: _quizCompleted ? _buildResultsScreen() : _buildQuizScreen(),
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
            color: const Color(0xFF00BCD4).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('SCORE', '$_score', Icons.eco, const Color(0xFF4CAF50)),
          _buildStatItem('QUESTION', '${_currentQuestionIndex + 1}/${_selectedQuestions.length}', Icons.quiz, const Color(0xFF00BCD4)),
          _buildStatItem('PROGRESS', '${((_currentQuestionIndex + 1) / _selectedQuestions.length * 100).toInt()}%', Icons.timeline, const Color(0xFFFF9800)),
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

  Widget _buildQuizScreen() {
    final currentQuestion = _selectedQuestions[_currentQuestionIndex];
    final userAnswer = _userAnswers[_currentQuestionIndex];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ocean-themed header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0097A7).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.waves,
                      color: Colors.white,
                      size: 40,
                    ),
                    if (_highScore > 0 && _currentQuestionIndex == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Best: $_highScore',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Question ${_currentQuestionIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Question and Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Text
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        return _buildOptionButton(
                          currentQuestion.options[index],
                          index,
                          userAnswer,
                          currentQuestion.correctAnswerIndex,
                        );
                      },
                    ),
                  ),

                  // Explanation (shown after answering)
                  if (userAnswer != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: userAnswer == true
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : const Color(0xFFF44336).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: userAnswer == true
                              ? const Color(0xFF4CAF50).withOpacity(0.3)
                              : const Color(0xFFF44336).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            userAnswer == true ? Icons.check_circle : Icons.info,
                            color: userAnswer == true ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentQuestion.explanation,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option, int index, bool? userAnswer, int correctIndex) {
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.grey.shade800;
    IconData? icon;

    if (userAnswer != null) {
      if (index == correctIndex) {
        backgroundColor = const Color(0xFF4CAF50).withOpacity(0.1);
        borderColor = const Color(0xFF4CAF50);
        textColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle;
      } else if (index != correctIndex && userAnswer == false && _userAnswers[_currentQuestionIndex] == false) {
        backgroundColor = const Color(0xFFF44336).withOpacity(0.1);
        borderColor = const Color(0xFFF44336);
        textColor = const Color(0xFFF44336);
        icon = Icons.cancel;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: userAnswer == null ? () => _answerQuestion(index) : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: const Color(0xFF00BCD4),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: textColor, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final correctAnswers = _userAnswers.where((answer) => answer == true).length;
    final totalQuestions = _selectedQuestions.length;
    final performance = _score == (totalQuestions * 20) ? 'Perfect! 🌊' :
    _score >= (totalQuestions * 20 * 0.8) ? 'Excellent! 🐬' :
    _score >= (totalQuestions * 20 * 0.6) ? 'Good Job! 🐢' :
    'Keep Learning! 🐠';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Results Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0097A7).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Quiz Complete!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  performance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'New questions next time!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Results Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Score Circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00BCD4).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
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
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'POINTS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  _buildResultStat('Correct Answers', '$correctAnswers/$totalQuestions', Icons.check_circle, const Color(0xFF4CAF50)),
                  _buildResultStat('Accuracy', '${(_score / (totalQuestions * 20) * 100).toInt()}%', Icons.analytics, const Color(0xFF00BCD4)),
                  _buildResultStat('Questions', '$totalQuestions', Icons.quiz, const Color(0xFFFF9800)),

                  if (_isNewHighScore) ...[
                    const SizedBox(height: 16),
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
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: const BorderSide(color: Color(0xFF00BCD4)),
                          ),
                          child: const Text(
                            'Exit',
                            style: TextStyle(color: Color(0xFF00BCD4)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00BCD4).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _restartQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
        ],
      ),
    );
  }

  Widget _buildResultStat(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
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
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
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
          Icon(icon, color: const Color(0xFF00BCD4), size: 16),
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