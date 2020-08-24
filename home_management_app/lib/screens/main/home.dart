import 'package:flutter/material.dart';
import 'package:home_management_app/screens/main/settings.dart';
import 'account.list.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String id = 'home_screen';

  List<Widget> children = [
    Dashboard(),
    AccountListScreen(),
    SettingsScreen(),
  ];
  int bottomBarNavigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home')
      ),
      body: children[bottomBarNavigationIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomBarNavigationIndex,
        backgroundColor: ThemeData.dark().bottomAppBarColor,
        selectedItemColor: Colors.pinkAccent,
        onTap: (index){
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
            title: Text('Settings'),
              icon: Icon(Icons.settings)
          )
        ],
      ),
    );
  }
}