import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/core/custom/components/dropdown.component.dart';

/// Appearance and language, stored on this device only. Shown in local mode
/// instead of the server-backed settings widgets.
class LocalPreferencesWidget extends StatelessWidget {
  const LocalPreferencesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = GetIt.I<IdentityUserRepository>();
    final languages = {
      l10n.english: 'en',
      l10n.spanish: 'es-AR',
      l10n.italian: 'it',
      l10n.portuguese: 'pt',
    };
    final themes = {
      l10n.system: ThemeMode.system,
      l10n.light: ThemeMode.light,
      l10n.dark: ThemeMode.dark,
    };

    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final language = repository.getCurrentLanguage().toLowerCase();
        final currentLanguage = languages.keys.firstWhere(
          (key) => languages[key]!.toLowerCase() == language,
          orElse: () => l10n.english,
        );
        final currentTheme = themes.keys.firstWhere(
          (key) => themes[key] == repository.themeMode,
        );
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    l10n.userSettings,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(l10n.themeMode),
                    const Spacer(),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: DropdownComponent(
                        items: themes.keys.toList(),
                        onChanged: (value) =>
                            repository.setThemeMode(themes[value]!),
                        currentValue: currentTheme,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(l10n.appLanguage),
                    const Spacer(),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: DropdownComponent(
                        items: languages.keys.toList(),
                        onChanged: (value) =>
                            repository.setLocalLanguage(languages[value]!),
                        currentValue: currentLanguage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
