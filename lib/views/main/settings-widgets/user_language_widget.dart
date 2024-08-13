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

  @override
  void initState() {
    super.initState();
    preferencesRepository.addListener(loadLanguage);
  }

  @override
  void dispose() {
    preferencesRepository.removeListener(loadLanguage);
    super.dispose();
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
  
  void loadLanguage() {
    var language = preferencesRepository.preferences.firstWhere((element) => element.name == PreferencesRepository.language);
    setState(() {
      selectedLanguage = language.value;
    });
  }
}
