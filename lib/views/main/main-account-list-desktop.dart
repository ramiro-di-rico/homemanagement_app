import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../models/account.dart';
import '../../models/main_account.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/repositories/main_account.repository.dart';
import '../../services/infra/platform/platform_context.dart';
import '../../services/infra/platform/platform_type.dart';
import '../accounts/account.detail.dart';
import 'widgets/main_account_expansion_tile.dart';
import 'widgets/main_account.sheet.dart';
import 'widgets/account.sheet.dart';

class MainAccountListDesktopView extends StatefulWidget {
  @override
  _MainAccountListDesktopViewState createState() => _MainAccountListDesktopViewState();
}

class _MainAccountListDesktopViewState extends State<MainAccountListDesktopView> {
  List<MainAccountModel> mainAccounts = [];
  List<AccountModel> accounts = [];
  MainAccountRepository mainAccountsRepo = GetIt.instance<MainAccountRepository>();
  AccountRepository accountsRepo = GetIt.instance<AccountRepository>();
  bool showHidden = false;

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

  Future refresh() async {
    await mainAccountsRepo.refresh();
    await accountsRepo.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  tooltip: showHidden
                      ? 'Show all main accounts'
                      : 'Hide main accounts',
                  icon: Icon(
                      showHidden ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      mainAccountsRepo.displayHidden(!showHidden);
                      showHidden = !showHidden;
                    });
                  },
                ),
                Text(
                  'Accounts',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(width: 12),
                Spacer(),
                IconButton(
                  tooltip: 'Add account',
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  onPressed: () {
                    showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        constraints: BoxConstraints(
                          maxHeight: 500,
                          maxWidth: 1200,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0))),
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
                IconButton(
                  tooltip: 'Add main account',
                  icon: Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        constraints: BoxConstraints(
                          maxHeight: 500,
                          maxWidth: 1200,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0))),
                        builder: (context) {
                          return SizedBox(
                            height: 250,
                            child: AnimatedPadding(
                                padding: MediaQuery.of(context).viewInsets,
                                duration: Duration(seconds: 1),
                                child: MainAccountSheet()),
                          );
                        });
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: mainAccountsRepo.isLoading && mainAccounts.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildListView(),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    // Identify accounts that are not in any mainAccount
    Set<int> childAccountIds = {};
    for (var mainAccount in mainAccounts) {
      for (var childAccount in mainAccount.childAccounts) {
        childAccountIds.add(childAccount.id);
      }
    }

    List<AccountModel> ungroupedAccounts =
        accounts.where((a) => !childAccountIds.contains(a.id) && !a.isHidden && !a.archive).toList();

    return ListView.builder(
      itemCount: mainAccounts.length + (ungroupedAccounts.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < mainAccounts.length) {
          final item = mainAccounts[index];
          return MainAccountExpansionTile(
            key: ValueKey(item.id),
            mainAccount: item,
          );
        } else {
          // Display ungrouped accounts
          return ExpansionTile(
            key: ValueKey('ungrouped-accounts'),
            title: Text('Ungrouped Accounts'),
            shape: Border.all(color: Colors.transparent),
            collapsedShape: Border.all(color: Colors.transparent),
            leading: Icon(Icons.account_balance_wallet_outlined),
            children: ungroupedAccounts
                .map((account) => _buildUngroupedAccountItem(account))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildUngroupedAccountItem(AccountModel account) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          var platformType = GetIt.I<PlatformContext>().getPlatformType();
          var isDesktop = platformType == PlatformType.Desktop ||
              platformType == PlatformType.Web;

          isDesktop
              ? context.push(AccountDetailScreen.fullPath, extra: account)
              : context.go(AccountDetailScreen.fullPath, extra: account);
        },
        child: ListTile(
          dense: true,
          title: Text(account.name,
              style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            account.balance % 1 == 0
                ? account.balance.toStringAsFixed(0)
                : account.balance.toStringAsFixed(2),
            style: TextStyle(
                color:
                    account.balance >= 0 ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
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
