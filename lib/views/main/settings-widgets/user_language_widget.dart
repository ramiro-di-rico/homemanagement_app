import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/dropdown.component.dart';
import '../../../services/endpoints/identity_user_service.dart';
import '../../mixins/notifier_mixin.dart';

class UserLanguageWidget extends StatefulWidget {
  const UserLanguageWidget({super.key});

  @override
  State<UserLanguageWidget> createState() => _UserLanguageWidgetState();
}

class _UserLanguageWidgetState extends State<UserLanguageWidget> with NotifierMixin {
  IdentityUserService identityUserService = GetIt.I<IdentityUserService>();
  String selectedLanguage = '';

  Map<String, String> languages = {
    'English': 'en',
    'Spanish': 'es-ar',
  };

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    // dropdown not being refresh to reflect current language
    print(selectedLanguage);
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
  }

  Future load() async {
    var model = await identityUserService.getUser();
    setState(() {
      selectedLanguage = languages.keys.firstWhere((key) => languages[key] == model.language);
    });
    print('Language loaded: $selectedLanguage');
  }
}
