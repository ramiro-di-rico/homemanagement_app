import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/main_account.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/main_account.repository.dart';
import 'package:home_management_app/ui/features/accounts/views/account.detail.dart';
import 'package:home_management_app/ui/features/home/views/shared/main_account_expansion_tile.dart';
import 'package:home_management_app/ui/features/home/views/shared/account.sheet.dart';
import 'package:home_management_app/ui/features/home/views/shared/main_account.sheet.dart';

class MainAccountListScreen extends StatefulWidget {
  @override
  _MainAccountListScreenState createState() => _MainAccountListScreenState();
}

class _MainAccountListScreenState extends State<MainAccountListScreen> {
  List<MainAccountModel> mainAccounts = [];
  List<AccountModel> accounts = [];
  MainAccountRepository mainAccountsRepo = GetIt.instance<MainAccountRepository>();
  AccountRepository accountsRepo = GetIt.instance<AccountRepository>();

  @override
  void initState() {
    super.initState();
    load();
    mainAccountsRepo.addListener(load);
    accountsRepo.addListener(load);
    mainAccountsRepo.load();
    accountsRepo.load();
  }

  @override
  void dispose() {
    mainAccountsRepo.removeListener(load);
    accountsRepo.removeListener(load);
    super.dispose();
  }

  load() {
    if (mounted) {
      setState(() {
        this.mainAccounts = mainAccountsRepo.mainAccounts;
        this.accounts = accountsRepo.accounts;
      });
    }
  }

  Future refreshMainAccounts() async {
    await mainAccountsRepo.refresh();
    await accountsRepo.refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (mainAccountsRepo.isLoading && this.mainAccounts.isEmpty && this.accounts.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshMainAccounts,
      child: _buildListView(),
    );
  }

  Widget _buildListView() {
    final childAccountIds = <int>{};
    for (var mainAccount in mainAccounts) {
      for (var childAccount in mainAccount.childAccounts) {
        childAccountIds.add(childAccount.id);
      }
    }

    final ungroupedAccounts = accounts
        .where((a) => !childAccountIds.contains(a.id) && !a.isHidden && !a.archive)
        .toList();

    return ListView.builder(
      itemCount: 1 + mainAccounts.length + (ungroupedAccounts.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildActionsCard();
        }

        final mainIndex = index - 1;
        if (mainIndex < mainAccounts.length) {
          return MainAccountExpansionTile(mainAccount: mainAccounts[mainIndex]);
        }

        return ExpansionTile(
          title: Text('Ungrouped Accounts'),
          shape: Border.all(color: Colors.transparent),
          collapsedShape: Border.all(color: Colors.transparent),
          leading: Icon(Icons.account_balance_wallet_outlined),
          children: ungroupedAccounts.map(_buildUngroupedAccountItem).toList(),
        );
      },
    );
  }

  Widget _buildActionsCard() {
    return Card(
      margin: EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text('Accounts', style: TextStyle(fontSize: 18)),
            Spacer(),
            IconButton(
              tooltip: 'Add account',
              icon: Icon(Icons.account_balance_wallet_outlined),
              onPressed: _openAddAccountSheet,
            ),
            IconButton(
              tooltip: 'Add main account',
              icon: Icon(Icons.add),
              onPressed: _openAddMainAccountSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUngroupedAccountItem(AccountModel account) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => context.go(AccountDetailScreen.fullPath, extra: account),
        child: ListTile(
          dense: true,
          title: Text(account.name, style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            account.balance % 1 == 0
                ? account.balance.toStringAsFixed(0)
                : account.balance.toStringAsFixed(2),
            style: TextStyle(
              color: account.balance >= 0 ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _openAddAccountSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return SizedBox(
          height: 250,
          child: AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: Duration(seconds: 1),
            child: AccountSheet(),
          ),
        );
      },
    );
  }

  void _openAddMainAccountSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return SizedBox(
          height: 250,
          child: AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: Duration(seconds: 1),
            child: MainAccountSheet(),
          ),
        );
      },
    );
  }

  Future remove(MainAccountModel item) async {
    try {
      await this.mainAccountsRepo.delete(item);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(item.name + ' removed')));
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Failed to remove ${item.name}',
            style: TextStyle(color: Colors.redAccent),
          )));
    }
  }
}
