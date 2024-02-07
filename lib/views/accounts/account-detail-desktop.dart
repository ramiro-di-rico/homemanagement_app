import 'package:flutter/material.dart';

import '../../models/account.dart';
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
      appBar: AppBar(
        title: Text('Account: ${account.name}')
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AccountDetailWidget(accountModel: account),
            Text(
              'Account Detail',
            ),
          ],
        ),
      ),
    );
  }
}
