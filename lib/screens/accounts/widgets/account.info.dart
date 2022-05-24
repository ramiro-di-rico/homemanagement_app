import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/repositories/currency.repository.dart';

class AccountDetailWidget extends StatelessWidget {
  final AccountModel accountModel;

  AccountDetailWidget({@required this.accountModel});

  @override
  Widget build(BuildContext context) {
    var currency = GetIt.I<CurrencyRepository>()
        .currencies
        .firstWhere((element) => element.id == accountModel.currencyId);
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Column(children: [
        ListTile(
          leading: Icon(accountModel.accountType == AccountType.Cash
              ? Icons.attach_money
              : Icons.account_balance),
          title: Row(
            children: [
              Text('Balance'),
              SizedBox(width: 20),
              Text(accountModel.balance.toStringAsFixed(0)),
              SizedBox(width: 20),
              Text(currency.name),
              SizedBox(width: 20),
              buildTrendingIcon()
            ],
          ),
        ),
      ]),
    );
  }

  Icon buildTrendingIcon() {
    if (accountModel.balance == 0) return Icon(Icons.trending_flat);

    if (accountModel.balance > 0)
      return Icon(Icons.trending_up, color: Colors.greenAccent);

    if (accountModel.balance < 0)
      return Icon(Icons.trending_down, color: Colors.redAccent);

    return Icon(Icons.trending_flat);
  }
}
