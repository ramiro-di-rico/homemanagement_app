import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:home_management_app/screens/transactions/add.transaction.dart';
import 'package:home_management_app/screens/transactions/transactions.list.dart';

import 'widgets/account.info.dart';

class AccountDetailScren extends StatefulWidget {
  static const String id = 'account_detail_screen';

  @override
  _AccountDetailScrenState createState() => _AccountDetailScrenState();
}

class _AccountDetailScrenState extends State<AccountDetailScren> {
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  bool edit = false;
  AccountModel account;
  TextEditingController accountNameController;

  bool visibility = true;

  @override
  Widget build(BuildContext context) {
    account = ModalRoute.of(context).settings.arguments as AccountModel;

    accountNameController = TextEditingController(text: this.account.name);

    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
        child: Container(
          child: Center(
            child: Column(
              children: [
                AccountDetailWidget(accountModel: account),
                TransactionListWidget(account.id)
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AddTransactionScreen.id),
        child: Icon(Icons.add),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(account.name.length > 15
                ? account.name.substring(0, 15) + '...'
                : account.name),
            FlatButton(
              onPressed: null,
              child: Icon(Icons.filter_list),
            )
          ],
        ),
      ),
    );
  }
}
