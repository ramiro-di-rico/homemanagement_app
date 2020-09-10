import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:home_management_app/repositories/currency.repository.dart';
import 'package:home_management_app/screens/accounts/add.acount.dart';
import 'package:home_management_app/screens/authentication/login.dart';
import 'package:home_management_app/screens/main/settings.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'account.list.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthenticationService authenticationService = GetIt.I<AuthenticationService>();
  List<Widget> children = [
    Dashboard(),
    AccountListScreen(),
    SettingsScreen(),
  ];
  List<Widget> floatingButtons = [];
  List<Color> selectedItemsColor = [Colors.greenAccent, Colors.pinkAccent, Colors.blueAccent];
  int bottomBarNavigationIndex = 0; 

  @override
  void initState() {
    super.initState();
    AccountRepository accountRepository = GetIt.instance<AccountRepository>();
    accountRepository.load();
    GetIt.I<CurrencyRepository>().load();
  }

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
        selectedItemColor: this.selectedItemsColor[bottomBarNavigationIndex],
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
      createLogoutButton(),
      FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, AddAccountScreen.id);
        },
      ),
      createLogoutButton(),
    ]);
  }

  Widget createLogoutButton() {
    return FloatingActionButton(
      child: Icon(Icons.exit_to_app),
      onPressed: () {
        authenticationService.logout();
        Navigator.popAndPushNamed(this.context, LoginScreen.id);
      },
    );
  }
}
