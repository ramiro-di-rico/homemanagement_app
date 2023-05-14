import 'package:flutter/material.dart';
import 'settings-widgets/buid-info.wdiget.dart';
import 'settings-widgets/daily-backup.widget.dart';
import 'settings-widgets/preferred-currency-widget.dart';
import 'settings-widgets/two-factor-authentication.widget.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
            child: BuildInfoWidget(),
          )
        ],
      ),
    );
  }
}
