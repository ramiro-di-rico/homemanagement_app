import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/repositories/preferences.repository.dart';
import 'logging_view.dart';
import 'settings-widgets/categories_list_widget.dart';
import 'settings-widgets/daily-backup.widget.dart';
import 'settings-widgets/preferred-currency-widget.dart';
import 'settings-widgets/two-factor-authentication.widget.dart';
import 'settings-widgets/user_info_widget.dart';
import 'settings-widgets/user_language_widget.dart';

class SettingsDesktopView extends StatefulWidget {
  const SettingsDesktopView({super.key});

  @override
  State<SettingsDesktopView> createState() => _SettingsDesktopViewState();
}

class _SettingsDesktopViewState extends State<SettingsDesktopView> {
  bool _isDeveloper = false;
  bool _preferencesLoaded = false;
  PreferencesRepository preferencesRepository =
      GetIt.I<PreferencesRepository>();

  @override
  void initState() {
    super.initState();
    preferencesRepository.addListener(_onPreferencesLoaded);
    preferencesRepository.load();
  }

  @override
  void dispose() {
    preferencesRepository.removeListener(_onPreferencesLoaded);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: !_preferencesLoaded
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                height: 1000,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                UserInfoWidget(),
                                PreferredCurrency(),
                                UserLanguageWidget(),
                                TwoFactorAuthenticationWidget(),
                                DailyBackupWidget(),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: _isDeveloper
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LoggingView(),
                                              ),
                                            );
                                          },
                                          child: Text('Developer Mode'),
                                        )
                                      : Container(),
                                ),
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
    );
  }

  void _onPreferencesLoaded() {
    setState(() {
      _preferencesLoaded = true;
    });
  }
}
