import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/localization_service.dart';

/// A widget that displays a language switcher dialog
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.language),
      tooltip: AppLocalizations.of(context)!.selectLanguage,
      onPressed: () => _showLanguageDialog(context),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localizationService = LocalizationService();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: LocalizationService.supportedLocales.map((locale) {
              final languageCode = locale.languageCode;
              final isSelected = languageCode == localizationService.currentLanguageCode;

              return ListTile(
                leading: Text(
                  localizationService.getLanguageFlag(languageCode),
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  localizationService.getLanguageName(languageCode),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () async {
                  await localizationService.setLanguage(languageCode);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.languageChanged),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }
}

/// A compact language switcher button for app bars
class LanguageSwitcherButton extends StatelessWidget {
  const LanguageSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService();
    
    return ValueListenableBuilder<Locale>(
      valueListenable: localizationService.localeNotifier,
      builder: (context, locale, child) {
        final languageCode = locale.languageCode;
        final flag = localizationService.getLanguageFlag(languageCode);
        
        return PopupMenuButton<String>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
          tooltip: AppLocalizations.of(context)!.selectLanguage,
          onSelected: (String languageCode) async {
            await localizationService.setLanguage(languageCode);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.languageChanged),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          itemBuilder: (BuildContext context) {
            return LocalizationService.supportedLocales.map((locale) {
              final code = locale.languageCode;
              final isSelected = code == languageCode;
              
              return PopupMenuItem<String>(
                value: code,
                child: Row(
                  children: [
                    Text(
                      localizationService.getLanguageFlag(code),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      localizationService.getLanguageName(code),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isSelected) ...[
                      const Spacer(),
                      const Icon(Icons.check, color: Colors.green, size: 20),
                    ],
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}

