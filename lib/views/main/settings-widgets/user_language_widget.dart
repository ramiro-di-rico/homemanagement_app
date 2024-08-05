import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/dropdown.component.dart';
import '../../../services/repositories/preferences.repository.dart';

class UserLanguageWidget extends StatefulWidget {
  const UserLanguageWidget({super.key});

  @override
  State<UserLanguageWidget> createState() => _UserLanguageWidgetState();
}

class _UserLanguageWidgetState extends State<UserLanguageWidget> {
  PreferencesRepository preferencesRepository =
  GetIt.I<PreferencesRepository>();
  String selectedLanguage = '';

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
    // add logic to change language
  }
}
