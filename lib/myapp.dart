import 'package:flutter/material.dart';
import 'package:home_management_app/screens/accounts/account.detail.dart';
import 'package:home_management_app/screens/authentication/registration.dart';

import 'screens/accounts/account-metrics.dart';
import 'screens/authentication/login.dart';
import 'screens/main/home.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Management',
      theme:
          ThemeData.light().copyWith(toggleableActiveColor: Colors.pinkAccent),
      darkTheme:
          ThemeData.dark().copyWith(toggleableActiveColor: Colors.pinkAccent),
      themeMode: ThemeMode.system,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        AccountDetailScren.id: (context) => AccountDetailScren(),
        AccountMetrics.id: (context) => AccountMetrics(),
      },
      initialRoute: LoginScreen.id,
    );
  }
}
