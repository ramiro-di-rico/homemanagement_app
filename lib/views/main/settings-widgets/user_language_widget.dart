import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/dropdown.component.dart';
import '../../../models/preference.dart';
import '../../../services/repositories/identity_user_repository.dart';
import '../../../services/repositories/preferences.repository.dart';
import '../../mixins/notifier_mixin.dart';

class UserLanguageWidget extends StatefulWidget {
  const UserLanguageWidget({super.key});

  @override
  State<UserLanguageWidget> createState() => _UserLanguageWidgetState();
}

class _UserLanguageWidgetState extends State<UserLanguageWidget> with NotifierMixin {
  IdentityUserRepository identityUserRepository = GetIt.I<IdentityUserRepository>();
  PreferencesRepository preferencesRepository = GetIt.I<PreferencesRepository>();
  String selectedLanguageCode = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    Map<String, String> languages = {
      l10n.english: 'en',
      l10n.spanish: 'es',
    };

    String selectedLanguageLabel = languages.keys.firstWhere(
      (key) => languages[key] == selectedLanguageCode,
      orElse: () => l10n.english,
    );

    return SizedBox(
      height: 100,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Text(
                    l10n.appLanguage,
                  ),
                  Spacer(),
                  DropdownComponent(
                    items: [l10n.english, l10n.spanish],
                    onChanged: (val) => onLanguageChanged(val, languages),
                    currentValue: selectedLanguageLabel,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  onLanguageChanged(String languageLabel, Map<String, String> languages) async {
    var languageCode = languages[languageLabel] ?? 'en';
    await preferencesRepository.update(PreferenceModel(PreferencesRepository.language, languageCode));
    setState(() {
      selectedLanguageCode = languageCode;
    });
  }

  Future load() async {
    var language = preferencesRepository.getCurrentLanguage();
    if (language.isEmpty) {
      var model = await identityUserRepository.getUser();
      language = model?.language ?? 'en';
    }

    setState(() {
      selectedLanguageCode = language;
    });
  }
}
