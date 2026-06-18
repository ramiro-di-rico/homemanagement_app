import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/currency.repository.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';
import 'package:home_management_app/data/repositories/main_account.repository.dart';
import 'package:home_management_app/data/repositories/tag.repository.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/ui/features/authentication/views/login.dart';
import 'package:home_management_app/ui/features/invites/views/invite_management_screen.dart' as invite_screen;
import 'package:home_management_app/data/services/user-settings-service.dart';
import 'package:home_management_app/ui/features/accounts/views/account.list.dart';
import 'package:home_management_app/ui/features/accounts/views/main_account.list.dart';
import 'package:home_management_app/ui/features/dashboard/views/dashboard.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/reminders/reminders_list_content.dart';
import 'package:home_management_app/ui/features/transactions/views/transactions_search_desktop_view.dart';
import 'package:home_management_app/ui/features/home/views/shared/main_account.sheet.dart';
import 'package:home_management_app/ui/features/settings/views/settings.dart';
import 'package:home_management_app/ui/features/statistics/views/statistics_view.dart';
import 'package:home_management_app/ui/core/screens/bulk_transactions_screen.dart';
import 'package:home_management_app/ui/features/home/views/shared/account.sheet.dart';

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
