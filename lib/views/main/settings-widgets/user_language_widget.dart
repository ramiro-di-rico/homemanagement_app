import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/dropdown.component.dart';
import '../../../models/preference.dart';
import '../../../services/repositories/preferences.repository.dart';
import '../../mixins/notifier_mixin.dart';

class UserLanguageWidget extends StatefulWidget {
  const UserLanguageWidget({super.key});

  @override
  State<UserLanguageWidget> createState() => _UserLanguageWidgetState();
}

class _UserLanguageWidgetState extends State<UserLanguageWidget> with NotifierMixin {
  PreferencesRepository preferencesRepository =
  GetIt.I<PreferencesRepository>();
  String selectedLanguage = '';

  Map<String, String> languages = {
    'English': 'en',
    'Spanish': 'es',
  };

  @override
  void initState() {
    super.initState();
    var lang = preferencesRepository.getCurrentLanguage();
    selectedLanguage = languages.keys.firstWhere((key) => languages[key] == lang);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Text(
                  'App Language',
                ),
                Spacer(),
                DropdownComponent(
                  items: ['English', 'Spanish'],
                  onChanged: onLanguageChanged,
                  currentValue: selectedLanguage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  onLanguageChanged(String languageChanged) {
    preferencesRepository.update(PreferenceModel(PreferencesRepository.language, languageChanged));
  }
}
