import 'package:flutter/material.dart';
import '../../services/infra/logging_file.dart';
import 'settings-widgets/buid-info.wdiget.dart';
import 'settings-widgets/daily-backup.widget.dart';
import 'settings-widgets/preferred-currency-widget.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LoggingFile _loggingFile = LoggingFile();
  int _timesTapped = 0;
  bool _isDeveloper = false;
  String logFileContent = '';

  @override
  void initState() {
    super.initState();
    _loggingFile.readLogFile().then((value) => logFileContent = value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: DailyBackupWdiget(),
          ),
          /*Padding(
            padding: EdgeInsets.all(10),
            child: TwoFactorAuthenticationWidget(),
          ),*/
          Padding(
            padding: EdgeInsets.all(10),
            child: const PreferredCurreny(),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {
                _timesTapped++;

                if(_timesTapped > 5){
                  setState(() {
                    _isDeveloper = true;
                  });
                }
              },
                child: BuildInfoWidget()),
          ),
          Padding(
              padding: EdgeInsets.all(10),
              child: _isDeveloper
                ? Text(logFileContent)
                : Container())
        ],
      ),
    );
  }
}
