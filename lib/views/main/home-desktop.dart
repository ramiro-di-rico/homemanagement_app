import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import '../../services/repositories/account.repository.dart';
import '../../services/repositories/budget_repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/currency.repository.dart';
import '../../services/repositories/identity_user_repository.dart';
import '../../services/repositories/tag.repository.dart';
import '../../services/endpoints/user-settings-service.dart';
import '../../services/security/authentication.service.dart';
import '../authentication/login.dart';
import '../invites/invite_management_screen.dart';
import 'account-list-desktop.dart';
import 'main-account-list-desktop.dart';
import 'budget_desktop_view.dart';
import 'dashboard_desktop.dart';
import 'settings.dart';
import 'statistics_view.dart';
import 'transactions_search_desktop_view.dart';
import '../../views/screens/bulk_transactions_screen.dart';
import 'widgets/account-sheet-dektop.dart';
import 'widgets/recurring_transaction_form_widget.dart';
import 'widgets/recurring_transactions_widget.dart';

class HomeDesktop extends StatefulWidget {
  const HomeDesktop({super.key});

  @override
  State<HomeDesktop> createState() => _HomeDesktopState();
}

class _HomeDesktopState extends State<HomeDesktop> {
  bool useMainAccounts = false;
  IdentityUserRepository _identityUserRepository = GetIt.I<IdentityUserRepository>();

  @override
  void initState() {
    super.initState();
    AccountRepository accountRepository = GetIt.instance<AccountRepository>();
    accountRepository.load();
    GetIt.I<CurrencyRepository>().load();
    GetIt.I<CategoryRepository>().load();
    GetIt.I<TagRepository>().load();
    GetIt.I<IdentityUserRepository>().getUser();
    GetIt.I<BudgetRepository>().load();
    _loadUseMainAccounts();
  }

  void _loadUseMainAccounts() {
    setState(() {
      useMainAccounts = _identityUserRepository.getUseMainAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.manage_search),
            onPressed: () {
              context.go(TransactionsSearchDesktopView.fullPath);
            },
            tooltip: l10n.searchTransactions,
          ),
          IconButton(
            icon: Icon(Icons.playlist_add),
            onPressed: () {
              context.go(BulkTransactionsScreen.fullPath);
            },
            tooltip: l10n.bulkTransactions,
          ),
          IconButton(
            icon: Icon(Icons.mail_outline),
            onPressed: () {
              context.go(InviteManagementScreen.fullPath);
            },
            tooltip: l10n.invitations,
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              context.go(StatisticsView.fullPath);
            },
            tooltip: l10n.statistics,
          ),
          IconButton(
              onPressed: () {
                context.go(BudgetDesktopView.fullPath);
              },
              icon: Icon(Icons.track_changes),
              tooltip: l10n.budget),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await context.push(SettingsScreen.fullPath);
              _loadUseMainAccounts();
            },
            tooltip: l10n.settings,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              GetIt.I<AuthenticationService>().logout();
              context.go(LoginView.fullPath);
            },
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          SizedBox(
                              height: 410,
                              child: useMainAccounts
                                  ? MainAccountListDesktopView()
                                  : AccountListDesktopView()),
                          SizedBox(height: 10),
                          SizedBox(
                              height: 410, child: RecurringTransactionList())
                        ],
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
