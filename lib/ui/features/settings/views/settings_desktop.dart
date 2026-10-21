import 'package:home_management_app/ui/features/local_mode/views/local_mode_banner.dart';
import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import 'package:home_management_app/ui/features/home/views/logging_view.dart';
import 'settings-widgets/authentication_settings_widget.dart';
import 'settings-widgets/categories_list_widget.dart';
import 'settings-widgets/feature-toggles.widget.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/reminders/notification_preferences_widget.dart';
import 'settings-widgets/local_preferences_widget.dart';
import 'settings-widgets/user-settings-widget.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';

class SettingsDesktopView extends StatefulWidget {
  const SettingsDesktopView({super.key});

  @override
  State<SettingsDesktopView> createState() => _SettingsDesktopViewState();
}

class _SettingsDesktopViewState extends State<SettingsDesktopView> {
  final bool _isDeveloper = false;
  final bool _preferencesLoaded = true;

  // Local mode has no signed-in user, so everything that talks to the
  // identity, user-settings, invite or reminder endpoints is left out.
  bool get _isLocal =>
      GetIt.I.isRegistered<AppModeService>() &&
      GetIt.I<AppModeService>().isLocal;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        bottom: const LocalModeBanner(),
      ),
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
                                  if (_isLocal)
                                    const LocalPreferencesWidget()
                                  else ...[
                                    AuthenticationSettingsWidget(),
                                    //PreferredCurrency(),
                                    FeatureTogglesWidget(),
                                    UserSettingsWidget(),
                                    const SizedBox(height: 20),
                                    const NotificationPreferencesWidget(),
                                  ],
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
}
