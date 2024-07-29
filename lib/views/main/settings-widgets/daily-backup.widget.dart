import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/services/repositories/preferences.repository.dart';

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
      child: ListTile(
        title: Text('Daily Backup'),
        subtitle: Text('Backup your data daily'),
        trailing: Switch(
          value: dailyBackupEnabled,
          onChanged: onEnableChanged,
        ),
      ),
    );
  }
}
