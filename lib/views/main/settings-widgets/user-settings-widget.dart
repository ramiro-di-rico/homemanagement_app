import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/dropdown.component.dart';
import '../../../services/repositories/currency.repository.dart';
import '../../../models/user-settings.dart';
import '../../../services/endpoints/user-settings-service.dart';
import '../../mixins/notifier_mixin.dart';

class UserSettingsWidget extends StatefulWidget {
  const UserSettingsWidget({super.key});

  @override
  State<UserSettingsWidget> createState() => _UserSettingsWidgetState();
}

class _UserSettingsWidgetState extends State<UserSettingsWidget> with NotifierMixin {

  final UserSettingsService _userSettingsService = GetIt.I<UserSettingsService>();
  final CurrencyRepository _currencyRepository = GetIt.I<CurrencyRepository>();
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
    return SizedBox(
      height: 260,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'User Settings',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'CSV Delimiter',
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
                  Text('Preferred Currency'),
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
                    'Backup Frequency',
                  ),
                  Spacer(),
                  selectedBackupFrequency.isEmpty
                  ? CircularProgressIndicator()
                  : SizedBox(
                    height: 50,
                    width: 150,
                    child: DropdownComponent(
                        items: ['Weekly', 'Monthly'],
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

    setState(() {
      userSettings = result;
      _settingsLoaded = true;
      selectedDelimiter = userSettings.csvDelimiter;
      selectedCurrency = userSettings.currency;
      selectedBackupFrequency = userSettings.backupFrequency.label;

      if (selectedCurrency.isEmpty && currencies.isNotEmpty) {
        selectedCurrency = currencies.first;
      }
    });
  }

  onDelimiterChanged(String csvDelimiterChangedValue) {
    userSettings.csvDelimiter = csvDelimiterChangedValue;
    _userSettingsService.update(userSettings);
  }

  onCurrencyChanged(String currencyChangedValue) {
    userSettings.currency = currencyChangedValue;
    _userSettingsService.updateCurrency(userSettings);
  }

  onBackupFrequencyChanged(String backupFrequencyChangedValue) {
    userSettings.backupFrequency = backupFrequencyChangedValue == 'Monthly'
        ? BackupFrequency.monthly
        : BackupFrequency.weekly;
    _userSettingsService.updateBackupFrequency(userSettings);
  }
}
