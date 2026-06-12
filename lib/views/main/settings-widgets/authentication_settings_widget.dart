import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

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
  bool _isLoadingUserInfo = true;
  bool _isSavingLanguage = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    final Map<String, String> localizedLanguages = {
      l10n.english: 'en',
      l10n.spanish: 'es-AR',
      l10n.italian: 'it',
      l10n.portuguese: 'pt',
    };

    final resolvedLanguage = localizedLanguages.keys.firstWhere(
      (key) => localizedLanguages[key]?.toLowerCase() == _userInfo?.language?.toLowerCase(),
      orElse: () => l10n.english,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                l10n.authenticationSettings,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              title: Text(l10n.username),
              subtitle: Text(_userInfo?.username ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(l10n.appLanguage),
                  const Spacer(),
                  _isLoadingUserInfo || _isSavingLanguage
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : DropdownComponent(
                           items: [l10n.english, l10n.spanish, l10n.italian, l10n.portuguese],
                          onChanged: (val) => onLanguageChanged(val, localizedLanguages),
                          currentValue: resolvedLanguage,
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                title: Text(l10n.enableTwoFactorAuthentication),
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

      setState(() {
        _userInfo = userInfo;
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

  Future<void> onLanguageChanged(String languageLabel, Map<String, String> languages) async {
    final languageCode = languages[languageLabel];
    if (languageCode == null) return;

    setState(() {
      _isSavingLanguage = true;
    });

    try {
      final updatedUser = await identityUserRepository.updateLanguage(
        languageCode,
        _userInfo?.timeZone ?? 'UTC',
      );
      if (mounted) {
        setState(() {
          _userInfo = updatedUser;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingLanguage = false;
        });
      }
    }
  }
}
