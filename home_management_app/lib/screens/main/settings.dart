import 'package:flutter/material.dart';
import 'settings-widgets/daily-backup.widget.dart';
import 'settings-widgets/sync-options.widget.dart';
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
            child: SyncOptionsWidget(),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: DailyBackupWdiget(),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TwoFactorAuthenticationWidget(),
          ),
        ],
      ),
    );
  }
}