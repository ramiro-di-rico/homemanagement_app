import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../services/repositories/preferences.repository.dart';

class DailyBackupWidget extends StatefulWidget {
  @override
  _DailyBackupWidgetState createState() => _DailyBackupWidgetState();
}

class _DailyBackupWidgetState extends State<DailyBackupWidget> {
  PreferencesRepository preferencesRepository =
      GetIt.I<PreferencesRepository>();
  bool dailyBackupEnabled = false;

  onEnableChanged(bool? value) {
    setState(() {
      this.dailyBackupEnabled = value == true;
    });
  }

  @override
  void initState() {
    super.initState();
    this.dailyBackupEnabled = this.preferencesRepository.getDailyBackupValue();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListTile(
          title: Text('Daily Backup'),
          subtitle: Text('A Backup of your data will be send via email on a daily basis'),
          trailing: Switch(
            value: dailyBackupEnabled,
            onChanged: onEnableChanged,
          ),
        ),
      ),
    );
  }
}
