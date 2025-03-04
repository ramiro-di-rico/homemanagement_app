import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../services/repositories/account.repository.dart';
import '../../services/repositories/budget_repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/currency.repository.dart';
import '../../services/repositories/identity_user_repository.dart';
import '../../services/repositories/preferences.repository.dart';
import '../../services/security/authentication.service.dart';
import '../authentication/login.dart';
import 'account-list-desktop.dart';
import 'budget_desktop_view.dart';
import 'dashboard_desktop.dart';
import 'settings.dart';
import 'transactions_search_desktop_view.dart';
import 'widgets/account-sheet-dektop.dart';
import 'widgets/recurring_transaction_form_widget.dart';
import 'widgets/recurring_transactions_widget.dart';

class HomeDesktop extends StatefulWidget {
  const HomeDesktop({super.key});

  @override
  State<HomeDesktop> createState() => _HomeDesktopState();
}

class _HomeDesktopState extends State<HomeDesktop> {
  @override
  void initState() {
    super.initState();
    AccountRepository accountRepository = GetIt.instance<AccountRepository>();
    accountRepository.load();
    GetIt.I<CurrencyRepository>().load();
    GetIt.I<CategoryRepository>().load();
    GetIt.I<PreferencesRepository>().load();
    GetIt.I<IdentityUserRepository>().getUser();
    GetIt.I<BudgetRepository>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.manage_search),
            onPressed: () {
              context.go(TransactionsSearchDesktopView.fullPath);
            },
            tooltip: 'Search transactions',
          ),
          IconButton(
              onPressed: (){
                context.go(BudgetDesktopView.fullPath);
              },
              icon: Icon(Icons.track_changes),
              tooltip: 'Budget'
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              context.go(SettingsScreen.fullPath);
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              GetIt.I<AuthenticationService>().logout();
              context.go(LoginView.fullPath);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: 1000,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(flex: 12, child: DashboardDesktop()),
                    Flexible(
                        flex: 7,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            SizedBox(height: 410, child: AccountListDesktopView()),
                            SizedBox(height: 10),
                            SizedBox(height: 410, child: RecurringTransactionList())
                          ],
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
