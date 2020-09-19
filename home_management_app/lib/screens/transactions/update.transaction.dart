import 'package:flutter/material.dart';
import 'package:home_management_app/models/transaction.dart';

class UpdateTransactionScreen extends StatefulWidget {
  final TransactionModel transactionModel;

  UpdateTransactionScreen(this.transactionModel);

  @override
  _UpdateTransactionScreenState createState() =>
      _UpdateTransactionScreenState();
}

class _UpdateTransactionScreenState extends State<UpdateTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('New Transaction'),
        ),
        body: SafeArea(
          child: Text('hola'),
        ));
  }
}
