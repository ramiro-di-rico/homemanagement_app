import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/currency.repository.dart';
import '../../services/repositories/identity_user_repository.dart';
import '../../services/repositories/main_account.repository.dart';
import '../../services/repositories/tag.repository.dart';
import '../../services/security/authentication.service.dart';
import '../authentication/login.dart';
import '../invites/invite_management_screen.dart' as invite_screen;
import '../../services/endpoints/user-settings-service.dart';
import 'account.list.dart';
import 'main_account.list.dart';
import 'dashboard.dart';
import 'settings-widgets/reminders/reminders_list_content.dart';
import 'transactions_search_desktop_view.dart';
import 'widgets/main_account.sheet.dart';
import 'settings.dart';
import 'statistics_view.dart';
import '../screens/bulk_transactions_screen.dart';
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
  IdentityUserRepository _identityUserRepository = GetIt.I<IdentityUserRepository>();
  bool useMainAccounts = false;

  List<Widget> children = [
    Dashboard(),
    AccountListScreen(),
    SettingsScreen(),
  ];
  List<Widget> floatingButtons = [];
  List<Color> selectedItemsColor = [
    Colors.greenAccent,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
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
    GetIt.I<TagRepository>().load();

    _identityUserRepository.getUser();
    _loadUseMainAccounts();
  }

  void _loadUseMainAccounts() {
    setState(() {
      useMainAccounts = _identityUserRepository.getUseMainAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    this.addFloatingActions();

    List<Widget> children = [
      Dashboard(),
      useMainAccounts ? MainAccountListScreen() : AccountListScreen(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: ReminderListContent(),
      ),
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
    var l10n = AppLocalizations.of(context)!;
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
          label: l10n.dashboard,
          icon: Icon(Icons.dashboard),
        ),
        BottomNavigationBarItem(
          label: useMainAccounts ? l10n.mainAccounts : l10n.accounts,
          icon: Icon(useMainAccounts ? Icons.account_balance : Icons.account_balance_wallet),
        ),
        BottomNavigationBarItem(label: l10n.reminders, icon: Icon(Icons.notifications)),
        BottomNavigationBarItem(label: l10n.settings, icon: Icon(Icons.settings)),
      ],
    );
  }

  AppBar buildAppBar() {
    MainAccountRepository _mainAccountRepository = GetIt.I<MainAccountRepository>();
    var l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.appTitle),
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
          : this.bottomBarNavigationIndex == 3
              ? [
                  IconButton(
                      onPressed: () {
                        _loadUseMainAccounts();
                      },
                      icon: Icon(Icons.refresh))
                ]
              : this.bottomBarNavigationIndex == 0
              ? [
                  IconButton(
                    onPressed: () {
                      context.go(TransactionsSearchDesktopView.fullPath);
                    },
                    icon: Icon(Icons.manage_search),
                    tooltip: l10n.searchTransactions,
                  ),
                  IconButton(
                      onPressed: () {
                        context.go(BulkTransactionsScreen.fullPath);
                      },
                      icon: Icon(Icons.playlist_add),
                      tooltip: l10n.bulkTransactions,
                    ),
                    IconButton(
                      onPressed: () {
                        context.go(invite_screen.InviteManagementScreen.fullPath);
                      },
                      icon: Icon(Icons.mail_outline),
                      tooltip: l10n.invitations,
                    ),
                    IconButton(
                      onPressed: () {
                        context.go(StatisticsView.fullPath);
                      },
                      icon: Icon(Icons.bar_chart),
                      tooltip: l10n.statistics,
                    )
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
      createLogoutButton(),
    ]);
  }

  Widget createLogoutButton() {
    var l10n = AppLocalizations.of(context)!;
    return FloatingActionButton(
      child: Icon(Icons.exit_to_app),
      tooltip: l10n.logout,
      onPressed: () {
        authenticationService.logout();
        context.go(LoginView.fullPath);
      },
    );
  }
}
