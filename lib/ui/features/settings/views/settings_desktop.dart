import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import 'package:home_management_app/ui/features/home/views/logging_view.dart';
import 'settings-widgets/authentication_settings_widget.dart';
import 'settings-widgets/categories_list_widget.dart';
import 'settings-widgets/feature-toggles.widget.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/reminders/reminders_list_desktop.dart';
import 'settings-widgets/user-settings-widget.dart';

class SettingsDesktopView extends StatefulWidget {
  const SettingsDesktopView({super.key});

  @override
  State<SettingsDesktopView> createState() => _SettingsDesktopViewState();
}

class _SettingsDesktopViewState extends State<SettingsDesktopView> {
  bool _isDeveloper = false;
  bool _preferencesLoaded = true;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: !_preferencesLoaded
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: SizedBox(
                  height: 1200,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AuthenticationSettingsWidget(),
                                  //PreferredCurrency(),
                                  FeatureTogglesWidget(),
                                  UserSettingsWidget(),
                                  SizedBox(height: 20),
                                  ReminderListView(),
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
                            Expanded(flex: 1, child: CategoriesListWidget()),
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

  void _onPreferencesLoaded() {
    setState(() {
      _preferencesLoaded = true;
    });
  }
}
