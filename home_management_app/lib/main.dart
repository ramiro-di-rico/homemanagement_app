import 'package:flutter/material.dart';
import 'package:home_management_app/screens/accounts/add.acount.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:injector/injector.dart';
import 'screens/main/home.dart';
import 'screens/authentication/login.dart';
import 'screens/transactions/transactions.list.dart';
import 'services/account.service.dart';
import 'services/caching.dart';
import 'services/cryptography.service.dart';
import 'services/metrics.service.dart';
import 'services/user.store.dart';

void main() {
  Injector injector = Injector.appInstance;
  injector.registerSingleton((injector) => Caching());
  injector.registerDependency((injector) => CryptographyService());
  injector.registerDependency((injector) => UserStore());
  injector.registerSingleton((injector) {
    var cryptographyService = injector.getDependency<CryptographyService>();
    var userStore = injector.getDependency<UserStore>();
    return AuthenticationService(
        cryptographyService: cryptographyService,
        userStore: userStore);
  });

  injector.registerDependency((injector) {
    var authenticationService = injector.getDependency<AuthenticationService>();
    var caching = injector.getDependency<Caching>();
    return MetricService(
      authenticationService: authenticationService,
      caching: caching);
  });

  injector.registerDependency((injector) {
    var authenticationService = injector.getDependency<AuthenticationService>();
    var caching = injector.getDependency<Caching>();
    return AccountService(
      authenticationService: authenticationService,
      caching: caching);
  });
  
  runApp(MyApp());
}


class MyApp extends StatelessWidget {  
  @override
  Widget build(BuildContext context) {
    var authenticationService = Injector.appInstance.getDependency<AuthenticationService>();
    var startingRoute = authenticationService.isAuthenticated() ?
    HomeScreen.id :
    LoginScreen.id;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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