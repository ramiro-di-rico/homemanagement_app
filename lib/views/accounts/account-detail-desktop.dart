import 'package:flutter/material.dart';

import '../../models/account.dart';
import 'account-metrics.dart';
import 'widgets/account-most-expensive-categories.dart';
import 'widgets/account.info.dart';

class AccountDetailDesktop extends StatefulWidget {
  const AccountDetailDesktop({super.key});

  @override
  State<AccountDetailDesktop> createState() => _AccountDetailDesktopState();
}

class _AccountDetailDesktopState extends State<AccountDetailDesktop> {
  late AccountModel account;

  @override
  Widget build(BuildContext context) {
    account = ModalRoute.of(context)!.settings.arguments as AccountModel;

    return Scaffold(
      appBar: AppBar(title: Text('Account: ${account.name}')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: 1000,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AccountDetailWidget(accountModel: account),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AccountMostExpensiveCategories(account),
                          ),

                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Text(
                        'Account Detail',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
