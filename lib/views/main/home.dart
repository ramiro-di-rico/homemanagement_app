import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/currency.repository.dart';
import '../../services/repositories/identity_user_repository.dart';
import '../../services/repositories/main_account.repository.dart';
import '../../services/repositories/preferences.repository.dart';
import '../../services/security/authentication.service.dart';
import '../authentication/login.dart';
import '../../services/endpoints/user-settings-service.dart';
import 'account.list.dart';
import 'main_account.list.dart';
import 'dashboard.dart';
import 'widgets/main_account.sheet.dart';
import 'settings.dart';
import 'widgets/account.sheet.dart';

class HomeScreen extends StatefulWidget {
  static const String fullPath = '/home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthenticationService authenticationService =
      GetIt.I<AuthenticationService>();
  AccountRepository _accountRepository = GetIt.I<AccountRepository>();
  PreferencesRepository _preferencesRepository = GetIt.I<PreferencesRepository>();
  bool useMainAccounts = false;
  IdentityUserRepository _identityUserRepository =
      GetIt.I<IdentityUserRepository>();

  List<Widget> children = [
    Dashboard(),
    AccountListScreen(),
    SettingsScreen(),
  ];
  List<Widget> floatingButtons = [];
  List<Color> selectedItemsColor = [
    Colors.greenAccent,
    Colors.pinkAccent,
    Colors.blueAccent
  ];
  int bottomBarNavigationIndex = 0;
  bool hasNotifications = false;
  bool showHiddenAccounts = false;

  @override
  void initState() {
    super.initState();
    AccountRepository accountRepository = GetIt.instance<AccountRepository>();
    accountRepository.load();
    GetIt.I<CurrencyRepository>().load();
    GetIt.I<CategoryRepository>().load();

    _identityUserRepository.getUser();
    _loadUseMainAccounts();
  }

  void _loadUseMainAccounts() {
    setState(() {
      useMainAccounts = _preferencesRepository.getUseMainAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    this.addFloatingActions();

    List<Widget> children = [
      Dashboard(),
      useMainAccounts ? MainAccountListScreen() : AccountListScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
        appBar: buildAppBar(),
        body: children[bottomBarNavigationIndex],
        floatingActionButton: floatingButtons[bottomBarNavigationIndex],
        bottomNavigationBar: buildBottomNavigationBar(context),
        floatingActionButtonLocation: bottomBarNavigationIndex == 1
            ? FloatingActionButtonLocation.centerFloat
            : FloatingActionButtonLocation.miniStartFloat);
  }

  BottomNavigationBar buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: bottomBarNavigationIndex,
      backgroundColor: Theme.of(context).bottomAppBarTheme.color,
      selectedItemColor: this.selectedItemsColor[bottomBarNavigationIndex],
      onTap: (index) {
        setState(() {
          this.bottomBarNavigationIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          label: 'Dashboard',
          icon: Icon(Icons.dashboard),
        ),
        BottomNavigationBarItem(
          label: useMainAccounts ? 'Main Accounts' : 'Accounts',
          icon: Icon(useMainAccounts ? Icons.account_balance : Icons.account_balance_wallet),
        ),
        BottomNavigationBarItem(label: 'Settings', icon: Icon(Icons.settings))
      ],
    );
  }

  AppBar buildAppBar() {
    MainAccountRepository _mainAccountRepository = GetIt.I<MainAccountRepository>();
    return AppBar(
      title: Text('Home Management'),
      actions: this.bottomBarNavigationIndex == 1
          ? [
              TextButton(
                  onPressed: () {
                    setState(() {
                      showHiddenAccounts = !showHiddenAccounts;
                      if (useMainAccounts) {
                        _mainAccountRepository.displayHidden(showHiddenAccounts);
                      } else {
                        _accountRepository.displayHidden(showHiddenAccounts);
                      }
                    });
                  },
                  child: Icon(showHiddenAccounts
                      ? Icons.visibility_off
                      : Icons.visibility))
            ]
          : this.bottomBarNavigationIndex == 2
              ? [
                  IconButton(
                      onPressed: () {
                        _loadUseMainAccounts();
                      },
                      icon: Icon(Icons.refresh))
                ]
              : [],
    );
  }

  void addFloatingActions() {
    this.floatingButtons.clear();
    this.floatingButtons.addAll([
      createLogoutButton(),
      FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25.0))),
              builder: (context) {
                return SizedBox(
                  height: 250,
                  child: AnimatedPadding(
                      padding: MediaQuery.of(context).viewInsets,
                      duration: Duration(seconds: 1),
                      child: useMainAccounts ? MainAccountSheet() : AccountSheet()),
                );
              });
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
        context.go(LoginView.fullPath);
      },
    );
  }
}
