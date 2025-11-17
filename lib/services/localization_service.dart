import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app localization and language switching
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
    Locale('fr'), // French
  ];

  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'ar': 'العربية',
    'fr': 'Français',
  };

  // Language flags/icons (emoji)
  static const Map<String, String> languageFlags = {
    'en': '🇬🇧',
    'ar': '🇸🇦',
    'fr': '🇫🇷',
  };

  // Current locale notifier
  final ValueNotifier<Locale> _localeNotifier = ValueNotifier(const Locale(_defaultLanguage));

  /// Get the current locale notifier
  ValueNotifier<Locale> get localeNotifier => _localeNotifier;

  /// Get the current locale
  Locale get currentLocale => _localeNotifier.value;

  /// Get the current language code
  String get currentLanguageCode => _localeNotifier.value.languageCode;

  /// Initialize the service and load saved language preference
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
    _localeNotifier.value = Locale(savedLanguage);
  }

  /// Set the app language
  Future<void> setLanguage(String languageCode) async {
    if (!languageNames.containsKey(languageCode)) {
      throw ArgumentError('Unsupported language code: $languageCode');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    _localeNotifier.value = Locale(languageCode);
  }

  /// Get saved language from preferences
  Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  /// Check if a language is RTL (Right-to-Left)
  bool isRTL(String languageCode) {
    return languageCode == 'ar'; // Arabic is RTL
  }

  /// Get text direction for a language
  TextDirection getTextDirection(String languageCode) {
    return isRTL(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get the display name for a language code
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  /// Get the flag emoji for a language code
  String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '🌐';
  }
}

