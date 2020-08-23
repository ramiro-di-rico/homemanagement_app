import 'package:flutter/material.dart';
import 'screens/main/home.dart';
import 'screens/authentication/login.dart';

void main() {
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