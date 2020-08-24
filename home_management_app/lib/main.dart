import 'package:flutter/material.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:injector/injector.dart';
import 'screens/main/home.dart';
import 'screens/authentication/login.dart';
import 'services/cryptography.service.dart';
import 'services/metrics.service.dart';

void main() {
  Injector injector = Injector.appInstance;
  injector.registerSingleton((injector) => AuthenticationService());
  injector.registerDependency((injector) => CryptographyService());

  injector.registerDependency((injector) {
    var authenticationService = injector.getDependency<AuthenticationService>();
    return MetricService(authenticationService: authenticationService);
  });
  
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: LoginScreen(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen()
      },
    );
  }
}