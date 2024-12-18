import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/services/repositories/account.repository.dart';
import 'package:home_management_app/services/repositories/transaction.repository.dart';
import 'package:home_management_app/views/accounts/account.detail.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../accounts/widgets/add.transaction.sheet.dart';
import '../mixins/notifier_mixin.dart';
import 'widgets/account.sheet.dart';

class AccountListScreen extends StatefulWidget {
  @override
  _AccountListScreenState createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> with NotifierMixin {
  List<AccountModel> accounts = [];
  AccountRepository accountsRepo = GetIt.instance<AccountRepository>();
  TransactionRepository transactionsRepo =
      GetIt.instance<TransactionRepository>();
  bool showArchive = false;

  @override
  void initState() {
    super.initState();
    load();
    accountsRepo.addListener(load);
    //transactionsRepo.addListener(refreshAccounts);
  }

  @override
  void dispose() {
    //accountsRepo.removeListener(load);
    super.dispose();
  }

  load() {
    setState(() {
      this.accounts = accountsRepo.accounts;
    });
  }

  Future refreshAccounts() async {
    await accountsRepo.refresh();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshAccounts,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: this.accounts.length,
        itemBuilder: (context, index) {
          if (this.accounts.isEmpty) return Container();

          final item = this.accounts[index];

          return Slidable(
            startActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                    icon: Icons.add,
                    backgroundColor: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(10),
                    onPressed: (context) {
                      showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0))),
                          builder: (context) {
                            return SizedBox(
                              height: 400,
                              child: AnimatedPadding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  duration: Duration(seconds: 1),
                                  child: AddTransactionSheet(item)),
                            );
                          });
                    }),
                SlidableAction(
                  onPressed: ((context) => {
                        showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25.0))),
                            builder: (context) {
                              return SizedBox(
                                height: 250,
                                child: AnimatedPadding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    duration: Duration(seconds: 1),
                                    child: AccountSheet(accountModel: item)),
                              );
                            })
                      }),
                  icon: Icons.edit,
                  backgroundColor: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                SlidableAction(
                  onPressed: (context) async {
                    item.archive = !item.archive;
                    await accountsRepo.update(item);
                  },
                  icon: item.archive ? Icons.unarchive : Icons.archive,
                  backgroundColor: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                SlidableAction(
                  onPressed: (context) async => await remove(item, index),
                  icon: Icons.delete,
                  backgroundColor: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(
                  item.name,
                ),
                trailing: Text(
                  item.balance % 1 == 0
                      ? item.balance.toStringAsFixed(0)
                      : item.balance.toStringAsFixed(2),
                  style: TextStyle(
                      color: item.balance >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent),
                ),
                onTap: () {
                  context.go(AccountDetailScreen.fullPath, extra: item);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future remove(item, index) async {
    try {
      await this.accountsRepo.delete(item);
      setState(() {
        accounts.remove(item);
      });
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
