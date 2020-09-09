import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'screens/accounts/add.acount.dart';
import 'screens/authentication/login.dart';
import 'screens/main/home.dart';
import 'screens/transactions/transactions.list.dart';
import 'services/authentication.service.dart';

class MyApp extends StatelessWidget {  
  @override
  Widget build(BuildContext context) {
    var authenticationService = GetIt.instance<AuthenticationService>();
    var startingRoute = authenticationService.isAuthenticated() ?
    HomeScreen.id :
    LoginScreen.id;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light().copyWith(
        toggleableActiveColor: Colors.pinkAccent
      ),
      darkTheme: ThemeData.dark().copyWith(
        toggleableActiveColor: Colors.pinkAccent
      ),
      themeMode: ThemeMode.system,
      home: LoginScreen(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        AddAccountScreen.id: (context) => AddAccountScreen(),
        TransactionsListScreen.id: (context) => TransactionsListScreen(),
      },
      initialRoute: startingRoute,
    );
  }
}