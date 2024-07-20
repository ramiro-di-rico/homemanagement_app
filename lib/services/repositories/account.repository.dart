import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../models/metrics/account-metrics.dart';
import '../../models/transaction.dart';
import '../endpoints/account.service.dart';
import '../infra/error_notifier_service.dart';

class AccountRepository extends ChangeNotifier {
  AccountService accountService;
  NotifierService notifierService;
  String cacheKey = 'accountsKey';
  final List<AccountModel> _internalAccounts = [];
  final List<AccountModel> accounts = [];
  final List<AccountSeries> accountSeries = [];
  bool showArchive = false;

  AccountRepository({required this.accountService, required this.notifierService});

  Future refresh() async => await load();

  displayArchive(bool show) {
    showArchive = show;
    _loadAccounts(_internalAccounts);
  }

  Future load() async {
    var result = await this.accountService.fetchAccounts();
    this._internalAccounts.clear();
    this._internalAccounts.addAll(result);
    _loadAccounts(result);
  }

  _loadAccounts(List<AccountModel> result) {
    this.accounts.clear();
    this.accounts.addAll(showArchive
        ? _internalAccounts
        : _internalAccounts.where((element) => !element.archive).toList());
    notifyListeners();
  }

  Future add(AccountModel accountModel) async {
    try {
      await this.accountService.add(accountModel);
      this.accounts.add(accountModel);
      notifyListeners();
      notifierService.notify('Account $accountModel.name added successfully');
    } catch (ex) {
      print(ex);
      notifierService.notify('Failed to add account ${accountModel.name}');
    }
  }

  Future update(AccountModel accountModel) async {
    try {
      await accountService.update(accountModel);
      _loadAccounts(accounts);
      notifierService.notify('Account $accountModel.name updated successfully');
    } catch (ex) {
      notifierService.notify('Failed to update account ${accountModel.name}');
      print(ex);
    }
  }

  Future archive(AccountModel accountModel) async {
    var archiveLabel = accountModel.archive ? 'archived' : 'unarchived';
    try {
      accountModel.archive = !accountModel.archive;
      await accountService.update(accountModel);
      _loadAccounts(accounts);
      notifierService.notify('Account ${accountModel.name} ${archiveLabel} successfully');
    } catch (ex) {
      notifierService.notify('Failed to ${archiveLabel} account ${accountModel.name}');
      print(ex);
    }
  }

  Future delete(AccountModel accountModel) async {
    try {
      await this.accountService.delete(accountModel);
      this.accounts.remove(accountModel);
      notifyListeners();
      notifierService.notify('Account $accountModel.name deleted successfully');
    } catch (ex) {
      print(ex);
      notifierService.notify('Failed to delete account ${accountModel.name}');
    }
  }

  updateBalance(int accountId, double value, TransactionType type) {
    var account =
        this._internalAccounts.firstWhere((element) => element.id == accountId);
    account.balance = type == TransactionType.Income
        ? account.balance + value
        : account.balance - value;
    _loadAccounts(_internalAccounts);
  }

  revertBalance(int accountId, double value, TransactionType type) {
    var account =
        this._internalAccounts.firstWhere((element) => element.id == accountId);
    account.balance = type == TransactionType.Income
        ? account.balance - value
        : account.balance + value;
    _loadAccounts(_internalAccounts);
  }

  setBalance(AccountModel targetAccount) {
    var account = this
        ._internalAccounts
        .firstWhere((element) => element.id == targetAccount.id);
    account.balance = targetAccount.balance;
    _loadAccounts(_internalAccounts);
  }
}
