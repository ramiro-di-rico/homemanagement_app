import 'package:flutter/material.dart';
import 'package:home_management_app/screens/authentication/login.dart';
import 'package:home_management_app/screens/main/settings.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:injector/injector.dart';
import 'account.list.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> children = [
    Dashboard(),
    AccountListScreen(),
    SettingsScreen(),
  ];
  List<Widget> floatingButtons = [];
  int bottomBarNavigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    this.addFloatingActions();

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: children[bottomBarNavigationIndex],
      floatingActionButton: floatingButtons[bottomBarNavigationIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomBarNavigationIndex,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        selectedItemColor: Colors.pinkAccent,
        onTap: (index) {
          setState(() {
            this.bottomBarNavigationIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            title: Text('Dashboard'),
            icon: Icon(Icons.dashboard),
          ),
          BottomNavigationBarItem(
            title: Text('Accounts'),
            icon: Icon(Icons.account_balance_wallet),
          ),
          BottomNavigationBarItem(
              title: Text('Settings'), icon: Icon(Icons.settings))
        ],
      ),
    );
  }

  void addFloatingActions() {
    this.floatingButtons.addAll([
      null,
      FloatingActionButton(
        child: Icon(Icons.plus_one),
        onPressed: () {},
      ),
      FloatingActionButton(
        child: Icon(Icons.exit_to_app),
        onPressed: () {
          var authenticationService =
              Injector.appInstance.getDependency<AuthenticationService>();
          authenticationService.logout();
          Navigator.popAndPushNamed(this.context, LoginScreen.id);
        },
      )
    ]);
  }
}
