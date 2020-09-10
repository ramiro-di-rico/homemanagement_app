import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';

class AccountDetailWidget extends StatelessWidget {
  final AccountModel accountModel;

  AccountDetailWidget({@required this.accountModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Chip(
              label: Text('Balance ${accountModel.balance.toStringAsFixed(0)}'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Chip(label: Text(accountModel.accountTypeToString())),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Chip(
              label: Text('USD'),
            ),
          )
        ],
      ),
    );
  }
}
