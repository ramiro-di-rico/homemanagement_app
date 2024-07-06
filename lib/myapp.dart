import 'package:flutter/material.dart';
import 'package:home_management_app/views/accounts/account.detail.dart';
import 'package:home_management_app/views/authentication/login-desktop.dart';
import 'package:home_management_app/views/authentication/registration-desktop.dart';
import 'package:home_management_app/views/authentication/registration.dart';
import 'package:home_management_app/views/main/home-desktop.dart';
import 'package:home_management_app/views/main/logging_view.dart';

import 'views/accounts/account-detail-desktop.dart';
import 'views/accounts/account-metrics.dart';
import 'views/authentication/2fa_view.dart';
import 'views/authentication/login.dart';
import 'views/main/home.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.of(context).size;
    var isDesktop = screenSize.width > 720;

    return MaterialApp(
      title: 'Home Management',
      theme: ThemeData.light().copyWith(
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
          radioTheme: RadioThemeData(
            fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
            trackColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          )),
      darkTheme: ThemeData.dark().copyWith(
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
          radioTheme: RadioThemeData(
            fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
            trackColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          )),
      themeMode: ThemeMode.system,
      routes: {
        LoginView.id: (context) => !isDesktop ? LoginView() : DesktopLoginView(),
        RegistrationScreen.id: (context) => !isDesktop ? RegistrationScreen() : RegistrationDesktop(),
        HomeScreen.id: (context) => !isDesktop ? HomeScreen() : HomeDesktop(),
        AccountDetailScreen.id: (context) => !isDesktop ? AccountDetailScreen() : AccountDetailDesktop(),
        AccountMetrics.id: (context) => AccountMetrics(),
        LoggingView.id: (context) => LoggingView(),
        TwoFactorAuthenticationView.id: (context) => TwoFactorAuthenticationView(),
      },
      initialRoute: LoginView.id,
    );
  }
}
