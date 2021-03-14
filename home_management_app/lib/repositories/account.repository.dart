import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/metrics/account-metrics.dart';
import 'package:home_management_app/services/account.service.dart';

class AccountRepository extends ChangeNotifier {
  AccountService accountService;
  String cacheKey = 'accountsKey';
  final List<AccountModel> accounts = [];
  final List<AccountSeries> accountSeries = [];

  AccountRepository({@required this.accountService});

  Future refresh() async {
    this.accounts.clear();
    await load();
  }

  Future load() async {
    var result = await this.accountService.fetchAccounts();
    this.accounts.addAll(result);
    notifyListeners();
  }

  Future add(AccountModel accountModel) async {
    try {
      await this.accountService.add(accountModel);
      this.accounts.add(accountModel);
      notifyListeners();
    } catch (ex) {
      print(ex);
    }
  }

  Future update(AccountModel accountModel) async {
    try {
      await accountService.update(accountModel);
      notifyListeners();
    } catch (ex) {
      print(ex);
    }
  }

  Future delete(AccountModel accountModel) async {
    try {
      await this.accountService.delete(accountModel);
      this.accounts.remove(accountModel);
      notifyListeners();
    } catch (ex) {
      print(ex);
      throw ex;
    }
  }

  Future<List<AccountSeries>> getSeries() async {
    if (accountSeries.length == 0) {
      var result = await accountService.getSeriesMetric();
      accountSeries.addAll(result);
    }
    return accountSeries;
  }
}
