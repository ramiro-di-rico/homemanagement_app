import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/dropdown.component.dart';
import '../../../models/user-settings.dart';
import '../../../services/endpoints/user-settings-service.dart';
import '../../mixins/notifier_mixin.dart';

class UserSettingsWidget extends StatefulWidget {
  const UserSettingsWidget({super.key});

  @override
  State<UserSettingsWidget> createState() => _UserSettingsWidgetState();
}

class _UserSettingsWidgetState extends State<UserSettingsWidget> with NotifierMixin {

  UserSettingsService _userSettingsService = GetIt.I<UserSettingsService>();
  late UserSettings userSettings;
  String selectedDelimiter = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    width: 50,
                    child: DropdownComponent(
                        items: [';', ',', '|'],
                        onChanged: onDelimiterChanged,
                        currentValue: selectedDelimiter,
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
      selectedDelimiter = userSettings.csvDelimiter;
    });
  }

  onDelimiterChanged(String csvDelimiterChangedValue) {
    userSettings.csvDelimiter = csvDelimiterChangedValue;
    _userSettingsService.update(userSettings);
  }
}
