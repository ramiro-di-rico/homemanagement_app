import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/services/account.service.dart';

class AccountRepository extends ChangeNotifier {
  AccountService accountService;
  String cacheKey = 'accountsKey';
  final List<AccountModel> accounts = List<AccountModel>();

  AccountRepository({@required this.accountService});

  Future load() async {
    var result = await this.accountService.fetchAccounts();
    this.accounts.addAll(result);
    notifyListeners();
  }

  Future add(AccountModel accountModel) async {
    try{
      await this.accountService.add(accountModel);
      this.accounts.add(accountModel);
      notifyListeners();
    }
    catch(ex){
      print(ex);
    }
  }

  Future update(AccountModel accountModel) async {
    try{
      await accountService.update(accountModel);
      notifyListeners();
    }
    catch(ex){
      print(ex);
    }
  }

  Future delete(AccountModel accountModel) async {
    try{
      await this.accountService.delete(accountModel);
      this.accounts.remove(accountModel);
      notifyListeners();
    }
    catch(ex) {
      print(ex);
      throw ex;
    }
  }
}
