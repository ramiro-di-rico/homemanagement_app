import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/repositories/preferences.repository.dart';

class DailyBackupWdiget extends StatefulWidget {
  @override
  _DailyBackupWdigetState createState() => _DailyBackupWdigetState();
}

class _DailyBackupWdigetState extends State<DailyBackupWdiget> {
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
    return MainCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: dailyBackupEnabled,
            onChanged: onEnableChanged,
          ),
          Expanded(
            child: Text('Sync Options'),
          ),
          Expanded(
              child: TextButton(
                  child: Icon(
                    Icons.cloud_download,
                    color: Colors.pinkAccent,
                  ),
                  onPressed: () {}))
        ],
      ),
    );
  }
}
