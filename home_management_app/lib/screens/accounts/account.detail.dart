import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:home_management_app/screens/transactions/add.transaction.dart';
import 'package:home_management_app/screens/transactions/transactions.list.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'widgets/account.info.dart';

class AccountDetailScren extends StatefulWidget {
  static const String id = 'account_detail_screen';

  @override
  _AccountDetailScrenState createState() => _AccountDetailScrenState();
}

class _AccountDetailScrenState extends State<AccountDetailScren> {
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  AccountModel account;
  TransactionListController transactionListController = TransactionListController();

  @override
  Widget build(BuildContext context) {
    account = ModalRoute.of(context).settings.arguments as AccountModel;

    var transactionsListView = TransactionListWidget(accountId: account.id, controller: transactionListController);

    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              AccountDetailWidget(accountModel: account),
              transactionsListView
            ],
          ),
        ),
      ),
      floatingActionButton: buildSpeedDial(context),
    );
  }

  SpeedDial buildSpeedDial(BuildContext context) {
    return SpeedDial(
      overlayOpacity: 0.1,
      animatedIcon: AnimatedIcons.menu_close,
      children: [
          SpeedDialChild(
            child: Icon(OMIcons.barChart),
            backgroundColor: Colors.red,
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('FIRST CHILD')
          ),
          SpeedDialChild(
            child: Icon(Icons.filter_list),
            backgroundColor: Colors.blue,
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => transactionListController.showFilters()
          ),
          SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: Colors.green,
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.pushNamed(context, AddTransactionScreen.id, arguments: account),
          ),
        ],
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
          ],
        ),
      ),
    );
  }
}
