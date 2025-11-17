import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Eco Guardians'**
  String get appTitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Eco Guardians!'**
  String get welcomeMessage;

  /// No description provided for @yourImpact.
  ///
  /// In en, this message translates to:
  /// **'Your Impact'**
  String get yourImpact;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get currentLevel;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievements Unlocked'**
  String get achievementsUnlocked;

  /// No description provided for @recentAchievements.
  ///
  /// In en, this message translates to:
  /// **'Recent Achievements'**
  String get recentAchievements;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @playGames.
  ///
  /// In en, this message translates to:
  /// **'Play Games'**
  String get playGames;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @checkLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Check Leaderboard'**
  String get checkLeaderboard;

  /// No description provided for @dailyRewards.
  ///
  /// In en, this message translates to:
  /// **'Daily Rewards'**
  String get dailyRewards;

  /// No description provided for @ecoTips.
  ///
  /// In en, this message translates to:
  /// **'Eco Tips'**
  String get ecoTips;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joinedDate;

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last Login'**
  String get lastLogin;

  /// No description provided for @gameStats.
  ///
  /// In en, this message translates to:
  /// **'Game Statistics'**
  String get gameStats;

  /// No description provided for @achievementProgress.
  ///
  /// In en, this message translates to:
  /// **'Achievement Progress'**
  String get achievementProgress;

  /// No description provided for @personalBest.
  ///
  /// In en, this message translates to:
  /// **'Personal Best'**
  String get personalBest;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @topPlayers.
  ///
  /// In en, this message translates to:
  /// **'Top Players'**
  String get topPlayers;

  /// No description provided for @yourRank.
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get yourRank;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @globalRanking.
  ///
  /// In en, this message translates to:
  /// **'Global Ranking'**
  String get globalRanking;

  /// No description provided for @weeklyTop.
  ///
  /// In en, this message translates to:
  /// **'Weekly Top'**
  String get weeklyTop;

  /// No description provided for @monthlyTop.
  ///
  /// In en, this message translates to:
  /// **'Monthly Top'**
  String get monthlyTop;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get reward;

  /// No description provided for @unlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocked on'**
  String get unlockedOn;

  /// No description provided for @achievementCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get achievementCategories;

  /// No description provided for @allAchievements.
  ///
  /// In en, this message translates to:
  /// **'All Achievements'**
  String get allAchievements;

  /// No description provided for @myAchievements.
  ///
  /// In en, this message translates to:
  /// **'My Achievements'**
  String get myAchievements;

  /// No description provided for @gamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Eco Games'**
  String get gamesTitle;

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get playNow;

  /// No description provided for @highScore.
  ///
  /// In en, this message translates to:
  /// **'High Score'**
  String get highScore;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get bestTime;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @youWon.
  ///
  /// In en, this message translates to:
  /// **'You Won!'**
  String get youWon;

  /// No description provided for @youLost.
  ///
  /// In en, this message translates to:
  /// **'You Lost!'**
  String get youLost;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get finalScore;

  /// No description provided for @newHighScore.
  ///
  /// In en, this message translates to:
  /// **'New High Score!'**
  String get newHighScore;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @beachCleanup.
  ///
  /// In en, this message translates to:
  /// **'Beach Cleanup'**
  String get beachCleanup;

  /// No description provided for @forestGuardian.
  ///
  /// In en, this message translates to:
  /// **'Forest Guardian'**
  String get forestGuardian;

  /// No description provided for @oceanSavior.
  ///
  /// In en, this message translates to:
  /// **'Ocean Savior'**
  String get oceanSavior;

  /// No description provided for @climateWarrior.
  ///
  /// In en, this message translates to:
  /// **'Climate Warrior'**
  String get climateWarrior;

  /// No description provided for @ecoCityBuilder.
  ///
  /// In en, this message translates to:
  /// **'Eco City Builder'**
  String get ecoCityBuilder;

  /// No description provided for @wildlifeRescue.
  ///
  /// In en, this message translates to:
  /// **'Wildlife Rescue'**
  String get wildlifeRescue;

  /// No description provided for @dailyRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Rewards'**
  String get dailyRewardsTitle;

  /// No description provided for @loginStreak.
  ///
  /// In en, this message translates to:
  /// **'Login Streak'**
  String get loginStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @claimReward.
  ///
  /// In en, this message translates to:
  /// **'Claim Reward'**
  String get claimReward;

  /// No description provided for @rewardClaimed.
  ///
  /// In en, this message translates to:
  /// **'Reward Claimed!'**
  String get rewardClaimed;

  /// No description provided for @comeBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for more rewards!'**
  String get comeBackTomorrow;

  /// No description provided for @streakBonus.
  ///
  /// In en, this message translates to:
  /// **'Streak Bonus'**
  String get streakBonus;

  /// No description provided for @consecutiveDays.
  ///
  /// In en, this message translates to:
  /// **'Consecutive Days'**
  String get consecutiveDays;

  /// No description provided for @loginHistory.
  ///
  /// In en, this message translates to:
  /// **'Login History'**
  String get loginHistory;

  /// No description provided for @chatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'Eco Assistant'**
  String get chatbotTitle;

  /// No description provided for @chatbotWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your Eco Guardian AI. I\'m here to help you learn about environmental protection!'**
  String get chatbotWelcome;

  /// No description provided for @chatbotPrompt.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about sustainability!'**
  String get chatbotPrompt;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @chatbotOffline.
  ///
  /// In en, this message translates to:
  /// **'Running in offline mode'**
  String get chatbotOffline;

  /// No description provided for @chatbotTyping.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get chatbotTyping;

  /// No description provided for @ecoTipsAction.
  ///
  /// In en, this message translates to:
  /// **'Eco Tips'**
  String get ecoTipsAction;

  /// No description provided for @gameHelpAction.
  ///
  /// In en, this message translates to:
  /// **'Game Help'**
  String get gameHelpAction;

  /// No description provided for @recyclingAction.
  ///
  /// In en, this message translates to:
  /// **'Recycling'**
  String get recyclingAction;

  /// No description provided for @faqAction.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqAction;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInput;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordTooShort;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccess;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @rewardEarned.
  ///
  /// In en, this message translates to:
  /// **'Reward earned!'**
  String get rewardEarned;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points earned!'**
  String get pointsEarned;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
