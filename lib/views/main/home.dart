import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/notification.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/currency.repository.dart';
import '../../services/repositories/identity_user_repository.dart';
import '../../services/repositories/notification.repository.dart';
import '../../services/repositories/preferences.repository.dart';
import '../../services/security/authentication.service.dart';
import '../authentication/login.dart';
import 'account.list.dart';
import 'dashboard.dart';
import 'settings.dart';
import 'widgets/account.sheet.dart';

class HomeScreen extends StatefulWidget {
  static const String id = '/home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthenticationService authenticationService =
      GetIt.I<AuthenticationService>();
  NotificationRepository notificationRepository =
      GetIt.I<NotificationRepository>();
  AccountRepository _accountRepository = GetIt.I<AccountRepository>();
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
  bool showArchiveAccounts = false;

  @override
  void initState() {
    super.initState();
    AccountRepository accountRepository = GetIt.instance<AccountRepository>();
    accountRepository.load();
    GetIt.I<CurrencyRepository>().load();
    GetIt.I<PreferencesRepository>().load();
    notificationRepository.load();
    GetIt.I<CategoryRepository>().load();

    notificationRepository.addListener(() {
      /*
      setState(() {
        hasNotifications = this.notificationRepository.notifications.length > 0;
      });
      */
    });

  _identityUserRepository.getUser();
  }

  @override
  Widget build(BuildContext context) {
    this.addFloatingActions();

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
          label: 'Accounts',
          icon: Icon(Icons.account_balance_wallet),
        ),
        BottomNavigationBarItem(label: 'Settings', icon: Icon(Icons.settings))
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text('Home Management'),
      actions: this.bottomBarNavigationIndex == 1
          ? [
              TextButton(
                  onPressed: () {
                    setState(() {
                      showArchiveAccounts = !showArchiveAccounts;
                      _accountRepository.displayArchive(showArchiveAccounts);
                    });
                  },
                  child: Icon(showArchiveAccounts
                      ? Icons.visibility_off
                      : Icons.visibility))
              /*TextButton(
            onPressed: displayNotifications,
            child: Icon(
                hasNotifications
                    ? Icons.notifications
                    : Icons.notifications_none,
                color: Colors.white)),*/
            ]
          : [],
    );
  }

  displayNotifications() {
    showModalBottomSheet(
        isDismissible: true,
        context: this.context,
        builder: (BuildContext context) {
          return Center(
              child: Column(
                  children: this
                      .notificationRepository
                      .notifications
                      .map((e) => ListTile(
                            title: Text(
                              e.title,
                              style: TextStyle(
                                  decoration: e.dismissed
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none),
                            ),
                            trailing: TextButton(
                              onPressed: () => dismissNotification(e),
                              child: Icon(Icons.check),
                            ),
                          ))
                      .toList()));
        });
  }

  void dismissNotification(NotificationModel notificationModel) {
    setState(() {
      this.notificationRepository.dismiss(notificationModel);
    });
  }

  void addFloatingActions() {
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
                      child: AccountSheet()),
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
        Navigator.popAndPushNamed(this.context, LoginView.id);
      },
    );
  }
}
