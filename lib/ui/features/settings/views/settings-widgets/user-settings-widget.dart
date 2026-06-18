import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

import 'package:home_management_app/ui/core/custom/components/dropdown.component.dart';
import 'package:home_management_app/data/repositories/currency.repository.dart';
import 'package:home_management_app/domain/models/user-settings.dart';
import 'package:home_management_app/data/services/user-settings-service.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';
import 'package:home_management_app/ui/core/mixins/notifier_mixin.dart';

class UserSettingsWidget extends StatefulWidget {
  const UserSettingsWidget({super.key});

  @override
  State<UserSettingsWidget> createState() => _UserSettingsWidgetState();
}

class _UserSettingsWidgetState extends State<UserSettingsWidget> with NotifierMixin {

  final UserSettingsService _userSettingsService = GetIt.I<UserSettingsService>();
  final CurrencyRepository _currencyRepository = GetIt.I<CurrencyRepository>();
  final IdentityUserRepository _identityUserRepository = GetIt.I<IdentityUserRepository>();
  late UserSettings userSettings;
  bool _settingsLoaded = false;
  String selectedDelimiter = '';
  String selectedCurrency = '';
  String selectedBackupFrequency = '';
  final List<String> currencies = [];

  @override
  void initState() {
    super.initState();
    _currencyRepository.addListener(_onCurrenciesChanged);
    _onCurrenciesChanged();
    load();
  }

  @override
  void dispose() {
    _currencyRepository.removeListener(_onCurrenciesChanged);
    super.dispose();
  }

  void _onCurrenciesChanged() {
    setState(() {
      currencies.clear();
      currencies.addAll(_currencyRepository.currencies.map((c) => c.name));

      if (_settingsLoaded && selectedCurrency.isEmpty && currencies.isNotEmpty) {
        selectedCurrency = currencies.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 320,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                l10n.userSettings,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    l10n.themeMode,
                  ),
                  Spacer(),
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: DropdownComponent(
                      items: [l10n.system, l10n.light, l10n.dark],
                      onChanged: (value) {
                        if (value == l10n.system) {
                          _identityUserRepository.setThemeMode(ThemeMode.system);
                        } else if (value == l10n.light) {
                          _identityUserRepository.setThemeMode(ThemeMode.light);
                        } else if (value == l10n.dark) {
                          _identityUserRepository.setThemeMode(ThemeMode.dark);
                        }
                      },
                      currentValue: _getThemeModeString(l10n),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Text(
                    l10n.csvDelimiter,
                  ),
                  Spacer(),
                  selectedDelimiter.isEmpty
                  ? CircularProgressIndicator()
                  : SizedBox(
                    height: 50,
                    width: 70,
                    child: DropdownComponent(
                        items: [';', ',', '|'],
                        onChanged: onDelimiterChanged,
                        currentValue: selectedDelimiter,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(l10n.preferredCurrency),
                  Spacer(),
                  selectedCurrency.isEmpty || currencies.isEmpty
                      ? CircularProgressIndicator()
                      : SizedBox(
                          height: 50,
                          width: 150,
                          child: DropdownComponent(
                            items: currencies,
                            onChanged: onCurrencyChanged,
                            currentValue: selectedCurrency,
                          ),
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    l10n.backupFrequency,
                  ),
                  Spacer(),
                  selectedBackupFrequency.isEmpty
                  ? CircularProgressIndicator()
                  : SizedBox(
                    height: 50,
                    width: 150,
                    child: DropdownComponent(
                        items: [l10n.weekly, l10n.monthly],
                        onChanged: onBackupFrequencyChanged,
                        currentValue: selectedBackupFrequency,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> load() async {
    var result = await _userSettingsService.fetchUserSettings();
    var l10n = AppLocalizations.of(context)!;

    setState(() {
      userSettings = result;
      _settingsLoaded = true;
      selectedDelimiter = userSettings.csvDelimiter;
      selectedCurrency = userSettings.currency;
      selectedBackupFrequency = userSettings.backupFrequency == BackupFrequency.monthly
          ? l10n.monthly
          : l10n.weekly;

      if (selectedCurrency.isEmpty && currencies.isNotEmpty) {
        selectedCurrency = currencies.first;
      }
    });
  }

  void onDelimiterChanged(String csvDelimiterChangedValue) {
    userSettings.csvDelimiter = csvDelimiterChangedValue;
    _userSettingsService.update(userSettings);
  }

  void onCurrencyChanged(String currencyChangedValue) {
    userSettings.currency = currencyChangedValue;
    _userSettingsService.updateCurrency(userSettings);
  }

  void onBackupFrequencyChanged(String backupFrequencyChangedValue) {
    if (!mounted) return;
    var l10n = AppLocalizations.of(context)!;
    userSettings.backupFrequency = backupFrequencyChangedValue == l10n.monthly
        ? BackupFrequency.monthly
        : BackupFrequency.weekly;
    _userSettingsService.updateBackupFrequency(userSettings);
  }

  String _getThemeModeString(AppLocalizations l10n) {
    switch (_identityUserRepository.themeMode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.system;
    }
  }
}
