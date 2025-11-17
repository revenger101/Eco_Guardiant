# Phase 3: High Score Implementation Guide

## ✅ Completed: Beach Cleanup Game

The Beach Cleanup Game has been fully updated with high score tracking. Use it as a reference for the remaining 5 games.

## 📋 Pattern to Apply to Remaining Games

For each of the following games, apply this exact pattern:

### Games to Update:
1. ✅ **Beach Cleanup Game** (`beach_cleanup_game.dart`) - **COMPLETE**
2. ⏳ **Forest Guardian Game** (`forest_guardian_game.dart`) - category: `'forest_guardian'`
3. ⏳ **Ocean Savior Game** (`ocean_savior_game.dart`) - category: `'ocean_savior'`
4. ⏳ **Climate Warrior Game** (`climate_warrior_game.dart`) - category: `'climate_warrior'`
5. ⏳ **Eco City Builder Game** (`Eco_City_Builder_Game.dart`) - category: `'eco_city_builder'`
6. ⏳ **Wildlife Rescue Game** (`Wildlife_Rescue_Game.dart`) - category: `'wildlife_rescue'`

---

## 🔧 Step-by-Step Implementation

### Step 1: Add State Variables

Add these two state variables to the game state class (if not already present):

```dart
int _highScore = 0;
bool _isNewHighScore = false;
```

### Step 2: Load High Score in initState

Add the `_loadHighScore()` method call in `initState()` and create the method:

```dart
@override
void initState() {
  super.initState();
  // ... existing initialization code ...
  _loadHighScore();
}

Future<void> _loadHighScore() async {
  final gameProgressService = GameProgressService();
  final highScore = await gameProgressService.getHighScore('GAME_CATEGORY_HERE');
  if (mounted) {
    setState(() {
      _highScore = highScore;
    });
  }
}
```

**Replace `'GAME_CATEGORY_HERE'` with the appropriate category:**
- Forest Guardian: `'forest_guardian'`
- Ocean Savior: `'ocean_savior'`
- Climate Warrior: `'climate_warrior'`
- Eco City Builder: `'eco_city_builder'`
- Wildlife Rescue: `'wildlife_rescue'`

### Step 3: Capture isNewHighScore Flag

In the `_endGame()` method (or equivalent), after calling `recordGameCompletion()`, capture the flag:

```dart
// Save game progress and check for achievements
final gameProgressService = GameProgressService();
final result = await gameProgressService.recordGameCompletion(
  gameCategory: 'GAME_CATEGORY_HERE',
  score: _score, // or whatever variable holds the final score
);

if (mounted) {
  setState(() {
    _isSavingProgress = false;
    if (result['success']) {
      _newAchievements = result['newAchievements'] ?? [];
      _isNewHighScore = result['isNewHighScore'] ?? false;  // ADD THIS LINE

      // Show achievement notifications
      if (_newAchievements.isNotEmpty) {
        _showAchievementNotifications();
      }
    }
  });
}
```

### Step 4: Display Personal Best on Start Screen

Find the start overlay/screen widget (usually `_buildStartOverlay()` or similar) and add this code **before** the "Start Game" button:

```dart
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
```

### Step 5: Display New High Score Badge on Game Over Screen

Find the game over overlay/screen widget (usually `_buildGameOverlay()` or similar) and add this code **after** the final score display:

```dart
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
```

### Step 6: Run Flutter Analyze

After updating each game, run:

```bash
flutter analyze lib/Pages/games/GAME_FILE_NAME.dart
```

---

## 🎨 Design Consistency

All high score displays follow this design pattern:

### Personal Best Badge (Start Screen):
- Background: `Colors.amber.shade50`
- Border: `Colors.amber.shade200`
- Icon: `Icons.emoji_events` in `Colors.amber.shade700`
- Text: `Colors.amber.shade900`

### New High Score Badge (Game Over Screen):
- Background: Gold gradient (`Color(0xFFFFD700)` to `Color(0xFFFFA000)`)
- Icon: `Icons.emoji_events` in white
- Text: White, bold, 16px

---

## ✅ Verification Checklist

For each game, verify:

- [ ] High score loads from database on game start
- [ ] Personal best displays on start screen (if > 0)
- [ ] New high score badge shows on game over (if new record)
- [ ] Game category matches the one used in Phase 2 integration
- [ ] No errors when running `flutter analyze`

---

## 📝 Notes

- All games already have `GameProgressService` imported and `recordGameCompletion()` implemented from Phase 2
- The database schema (version 3) already includes the `high_scores` table
- The `GameProgressService.recordGameCompletion()` method already returns `isNewHighScore`, `highScore`, and `previousHighScore`
- Each game uses a unique category identifier that must match across all implementations

---

## 🚀 Quick Reference: Game Categories

| Game File | Category String |
|-----------|----------------|
| `beach_cleanup_game.dart` | `'beach_cleanup'` |
| `forest_guardian_game.dart` | `'forest_guardian'` |
| `ocean_savior_game.dart` | `'ocean_savior'` |
| `climate_warrior_game.dart` | `'climate_warrior'` |
| `Eco_City_Builder_Game.dart` | `'eco_city_builder'` |
| `Wildlife_Rescue_Game.dart` | `'wildlife_rescue'` |

---

## 📚 Reference Implementation

See `lib/Pages/games/beach_cleanup_game.dart` for the complete, working implementation.

Key sections to reference:
- Lines 22-25: State variables
- Lines 33-56: initState and _loadHighScore method
- Lines 156-169: Capturing isNewHighScore flag
- Lines 557-592: Personal best display on start screen
- Lines 691-727: New high score badge on game over screen

