import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';

class TransactionsListScreen extends StatefulWidget {
  static const String id = 'transactions_list_screen';

  @override
  _TransactionsListScreenState createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {

  @override
  Widget build(BuildContext context) {
    AccountModel account = ModalRoute.of(context).settings.arguments as AccountModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            child: Text('Transactions Page'),
          ),
        ),
      ),
    );
  }
}