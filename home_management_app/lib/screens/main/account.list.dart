import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/services/account.service.dart';
import 'package:injector/injector.dart';

class AccountListScreen extends StatefulWidget {
  @override
  _AccountListScreenState createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {

  AccountService accountService = Injector.appInstance.getDependency<AccountService>();
  List<AccountModel> accounts = List<AccountModel>();

  @override
  void initState() {
    super.initState();
    loadAccounts().whenComplete(() => null);
  }
  
  Future loadAccounts() async {
    var ac = await accountService.getAccounts();
    setState(() {
      this.accounts.clear();
      this.accounts.addAll(ac);
      print(this.accounts.first.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final item = accounts[index];

          return Dismissible(
            key: Key(item.name),
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
                style: TextStyle(
                  color: Colors.white
                  )
                )
              ),
          );
        },
      ),
    );
  }
}
