import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_management_app/views/accounts/account.detail.dart';
import 'package:home_management_app/views/authentication/login-desktop.dart';
import 'package:home_management_app/views/authentication/registration.dart';
import 'package:home_management_app/views/main/logging_view.dart';

import 'views/accounts/account-metrics.dart';
import 'views/authentication/login.dart';
import 'views/main/home.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var isDesktop = Platform.isIOS || Platform.isLinux || Platform.isWindows;

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
        LoginView.id: (context) => isDesktop ? LoginView() : DesktopLoginView(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        AccountDetailScreen.id: (context) => AccountDetailScreen(),
        AccountMetrics.id: (context) => AccountMetrics(),
        LoggingView.id: (context) => LoggingView(),
      },
      initialRoute: LoginView.id,
    );
  }
}
