import 'package:flutter/material.dart';

import 'logging_view.dart';
import 'settings-widgets/categories_list_widget.dart';
import 'settings-widgets/daily-backup.widget.dart';
import 'settings-widgets/preferred-currency-widget.dart';

class SettingsDesktopView extends StatefulWidget {
  const SettingsDesktopView({super.key});

  @override
  State<SettingsDesktopView> createState() => _SettingsDesktopViewState();
}

class _SettingsDesktopViewState extends State<SettingsDesktopView> {
  bool _isDeveloper = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: 1000,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text('Daily Backup'),
                            Text('Preferred Currencies')
                            //Flexible(child: DailyBackupWdiget()),
                            /*Padding(
                              padding: EdgeInsets.all(10),
                              child: TwoFactorAuthenticationWidget(),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: const PreferredCurreny(),
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
                                      child: Text('Developer Mode'),
                                    )
                                  : Container(),
                            ),*/
                          ],
                        ),
                      ),
                      Expanded(
                        child: CategoriesListWidget(),
                        flex: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
