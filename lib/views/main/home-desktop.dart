import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/repositories/account.repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/currency.repository.dart';
import '../../services/security/authentication.service.dart';
import '../authentication/login.dart';
import 'account-list-desktop.dart';
import 'dashboard.dart';
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
              Navigator.pushNamed(context, TransactionsSearchDesktopView.id);
            },
            tooltip: 'Search transactions',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.id);
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              GetIt.I<AuthenticationService>().logout();
              Navigator.pushNamed(context, LoginView.id);
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
                    Flexible(flex: 1, child: Dashboard()),
                    Flexible(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Card(
                              child: ListTile(
                                title: Text(
                                  'Accounts',
                                  style: TextStyle(fontSize: 20),
                                ),
                                trailing: TextButton(
                                  onPressed: () {
                                    showModalBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        constraints: BoxConstraints(
                                          maxHeight: 500,
                                          maxWidth: 1200,
                                        ),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.vertical(top: Radius.circular(25.0))),
                                        builder: (context) {
                                          return SizedBox(
                                            height: 100,
                                            child: AnimatedPadding(
                                                padding: MediaQuery.of(context).viewInsets,
                                                duration: Duration(seconds: 1),
                                                child: AccountSheetDesktop()),
                                          );
                                        });
                                  },
                                  child: Icon(Icons.add),
                                ),
                              ),
                            ),
                            SizedBox(height: 380, child: AccountListDesktopView()),
                            SizedBox(height: 20),
                            Card(
                              child: ListTile(
                                title: Text(
                                  'Recurring Transactions',
                                  style: TextStyle(fontSize: 20),
                                ),
                                trailing: TextButton(
                                  onPressed: () {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: true,
                                      constraints: BoxConstraints(
                                        maxHeight: 500,
                                        maxWidth: 1200,
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.vertical(top: Radius.circular(25.0))),
                                      builder: (context) {
                                        return SizedBox(
                                            height: 100,
                                            width: 900,
                                            child: AnimatedPadding(
                                                padding: MediaQuery.of(context).viewInsets,
                                                duration: Duration(seconds: 1),
                                                child: RecurringTransactionForm()));
                                      },
                                    );
                                  },
                                  child: Icon(Icons.add),
                                ),
                              ),
                            ),
                            SizedBox(height: 400, child: RecurringTransactionList())
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
