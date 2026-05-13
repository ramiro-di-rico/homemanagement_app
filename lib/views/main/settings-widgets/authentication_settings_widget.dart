import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/dropdown.component.dart';
import '../../../models/view-models/my_user_view_model.dart';
import '../../../services/repositories/identity_user_repository.dart';

class AuthenticationSettingsWidget extends StatefulWidget {
  const AuthenticationSettingsWidget({super.key});

  @override
  State<AuthenticationSettingsWidget> createState() =>
      _AuthenticationSettingsWidgetState();
}

class _AuthenticationSettingsWidgetState
    extends State<AuthenticationSettingsWidget> {
  final IdentityUserRepository identityUserRepository =
      GetIt.I<IdentityUserRepository>();

  MyUserViewModel? _userInfo;
  bool twoFactorEnabled = false;
  String selectedLanguage = 'English';
  bool _isLoadingUserInfo = true;
  bool _isSavingLanguage = false;

  final Map<String, String> languages = {'English': 'en', 'Spanish': 'es-ar'};

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                'Authentication Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              title: const Text('Username'),
              subtitle: Text(_userInfo?.username ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Text('App Language'),
                  const Spacer(),
                  _isLoadingUserInfo || _isSavingLanguage
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : DropdownComponent(
                          items: const ['English', 'Spanish'],
                          onChanged: onLanguageChanged,
                          currentValue: selectedLanguage,
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                title: const Text('Enable Two Factor Authentication'),
                trailing: Switch(value: twoFactorEnabled, onChanged: onChecked),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> load() async {
    try {
      final userInfo = await identityUserRepository.getUser();
      final language = userInfo?.language ?? 'en';
      final resolvedLanguage = languages.keys.firstWhere(
        (key) => languages[key] == language,
        orElse: () => 'English',
      );

      setState(() {
        _userInfo = userInfo;
        selectedLanguage = resolvedLanguage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUserInfo = false;
        });
      }
    }
  }

  void onChecked(bool? value) {
    setState(() {
      twoFactorEnabled = value == true;
    });
  }

  Future<void> onLanguageChanged(String languageChanged) async {
    final previousLanguage = selectedLanguage;

    setState(() {
      selectedLanguage = languageChanged;
      _isSavingLanguage = true;
    });

    try {
      final languageCode = languages[languageChanged];
      print(languageCode);
      if (languageCode == null) {
        throw Exception('Unknown language');
      }

      await identityUserRepository.updateLanguage(
        languageCode,
        _userInfo?.timeZone ?? 'UTC',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        selectedLanguage = previousLanguage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSavingLanguage = false;
        });
      }
    }
  }
}
