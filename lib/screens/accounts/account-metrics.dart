import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';

import 'widgets/account-app-bar.dart';
import 'widgets/account-most-expensive-categories.dart';

class AccountMetrics extends StatefulWidget {
  static const String id = 'account_metrics_screen';
  final AccountModel account;
  AccountMetrics({this.account});
  @override
  _AccountMetricsState createState() => _AccountMetricsState();
}

class _AccountMetricsState extends State<AccountMetrics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AccountAppBar(
        account: widget.account,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: AccountMostExpensiveCategories(this.widget.account)),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
