import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:home_management_app/screens/accounts/account.detail.dart';
import 'package:home_management_app/screens/accounts/edit.account.dart';

class AccountListScreen extends StatefulWidget {
  @override
  _AccountListScreenState createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<AccountModel> accounts = [];
  AccountRepository accountsRepo = GetIt.instance<AccountRepository>();
  bool showArchive = false;

  @override
  void initState() {
    super.initState();
    load();
    accountsRepo.addListener(load);
  }

  @override
  void dispose() {
    accountsRepo.removeListener(load);
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
        itemCount: this.accounts.length,
        itemBuilder: (context, index) {
          if (this.accounts.isEmpty) return Container();

          final item = this.accounts[index];

          return Slidable(
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: ((context) => {}),
                  icon: Icons.edit,
                  backgroundColor: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                SlidableAction(
                  onPressed: (context) async => await remove(item, index),
                  icon: Icons.delete,
                  backgroundColor: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                )
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountDetailScren(
                        account: item,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAccountScreen(
                        account: item,
                      ),
                    ),
                  );
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove ${item.name}')));
    }
  }
}
