import 'package:flutter/material.dart';
import 'package:home_management_app/views/accounts/account.detail.dart';
import 'package:home_management_app/views/authentication/login-desktop.dart';
import 'package:home_management_app/views/authentication/registration-desktop.dart';
import 'package:home_management_app/views/authentication/registration.dart';
import 'package:home_management_app/views/main/home-desktop.dart';
import 'package:home_management_app/views/main/logging_view.dart';
import 'package:home_management_app/views/main/settings.dart';

import 'services/infra/platform/platform_context.dart';
import 'services/infra/platform/platform_type.dart';
import 'views/accounts/account-detail-desktop.dart';
import 'views/accounts/account-metrics.dart';
import 'views/authentication/2fa_view.dart';
import 'views/authentication/login.dart';
import 'views/main/home.dart';
import 'views/main/settings_desktop.dart';

class MyApp extends StatelessWidget {
  final PlatformContext _platformContext;

  MyApp(this._platformContext);

  @override
  Widget build(BuildContext context) {
    _platformContext.setContext(context);
    var platformType = _platformContext.getPlatformType();
    var isDesktop = platformType == PlatformType.Desktop || platformType == PlatformType.Web;

    return MaterialApp(
      title: 'Home Management',
      theme: ThemeData.light().copyWith(
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return null;
              }
              if (states.contains(WidgetState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return null;
              }
              if (states.contains(WidgetState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return null;
              }
              if (states.contains(WidgetState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return null;
              }
              if (states.contains(WidgetState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          )),
      darkTheme: ThemeData.dark().copyWith(
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return null;
              }
              if (states.contains(WidgetState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return null;
              }
              if (states.contains(WidgetState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
      ),
      themeMode: ThemeMode.system,
      routes: {
        LoginView.id: (context) => !isDesktop ? LoginView() : DesktopLoginView(),
        RegistrationScreen.id: (context) => !isDesktop ? RegistrationScreen() : RegistrationDesktop(),
        HomeScreen.id: (context) => !isDesktop ? HomeScreen() : HomeDesktop(),
        AccountDetailScreen.id: (context) => !isDesktop ? AccountDetailScreen() : AccountDetailDesktop(),
        AccountMetrics.id: (context) => AccountMetrics(),
        LoggingView.id: (context) => LoggingView(),
        TwoFactorAuthenticationView.id: (context) => TwoFactorAuthenticationView(),
        SettingsScreen.id: (context) => !isDesktop ? SettingsScreen() : SettingsDesktopView(),
      },
      initialRoute: LoginView.id,
    );
  }
}
