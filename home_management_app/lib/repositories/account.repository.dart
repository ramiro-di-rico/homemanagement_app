import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/services/account.service.dart';
import 'package:home_management_app/services/caching.dart';

class AccountRepository extends ChangeNotifier {
  AccountService accountService;
  Caching caching;
  String cacheKey = 'accountsKey';
  final List<AccountModel> accounts = List<AccountModel>();

  AccountRepository({@required this.accountService, @required this.caching});

  Future load() async {
    var result = await this.accountService.fetchAccounts();
    this.accounts.addAll(result);
    notifyListeners();
  }

  void add(AccountModel accountModel){
    this.accounts.add(accountModel);
    notifyListeners();
  }
}
