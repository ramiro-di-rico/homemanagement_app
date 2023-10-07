import 'package:flutter/material.dart';
import 'package:home_management_app/screens/main/logging_view.dart';
import 'settings-widgets/buid-info.wdiget.dart';
import 'settings-widgets/daily-backup.widget.dart';
import 'settings-widgets/preferred-currency-widget.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _timesTapped = 0;
  bool _isDeveloper = false;

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
                ? ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoggingView(),
                      ),
                    );
                  },
                  child: Text('View Logs'))
                : Container())
        ],
      ),
    );
  }
}
