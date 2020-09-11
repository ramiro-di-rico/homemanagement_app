import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:home_management_app/screens/accounts/account.detail.dart';
import 'package:home_management_app/screens/accounts/add.acount.dart';
import 'package:home_management_app/screens/accounts/edit.account.dart';

class AccountListScreen extends StatefulWidget {
  @override
  _AccountListScreenState createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<AccountModel> accounts = List<AccountModel>();
  AccountRepository accountsRepo = GetIt.instance<AccountRepository>();

  @override
  void initState() {
    super.initState();
    refreshAccounts();
    accountsRepo.addListener(refreshAccounts);
  }

  @override
  void dispose() {
    accountsRepo.removeListener(refreshAccounts);
    super.dispose();
  }

  refreshAccounts() {
    setState(() {
      this.accounts = accountsRepo.accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.accounts.length,
      itemBuilder: (context, index) {
        final item = this.accounts[index];

        return Dismissible(
          key: Key(item.name),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.blueAccent,
          ),
          secondaryBackground: Container(
            color: Colors.redAccent,
          ),
          onDismissed: (direction) {
            setState(() {
              accounts.removeAt(index);
            });
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text(item.name + ' removed')));
          },
          child: ListTile(
            title: Text(
              item.name,
            ),
            onTap: () {
              Navigator.pushNamed(context, AccountDetailScren.id,
                  arguments: item);
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
        );
      },
    );
  }
}
