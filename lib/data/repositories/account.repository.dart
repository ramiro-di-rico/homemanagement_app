import 'package:flutter/material.dart';

import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/metrics/account-metrics.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/local_read_failed_exception.dart';
import 'package:home_management_app/data/services/sources/local_write_failed_exception.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';

class AccountRepository extends ChangeNotifier {
  AccountDataSource accountService;
  NotifierService notifierService;
  String cacheKey = 'accountsKey';
  final List<AccountModel> _internalAccounts = [];
  final List<AccountModel> accounts = [];
  final List<AccountSeries> accountSeries = [];
  bool showHidden = false;

  AccountRepository({required this.accountService, required this.notifierService});

  Future refresh() async => await load();

  /// Forgets everything held in memory, for a change between local and online
  /// data. Nothing is reloaded here: the next screen loads what it needs, and
  /// online that can't happen before the user has signed in.
  void reset() {
    _internalAccounts.clear();
    accounts.clear();
    accountSeries.clear();
    notifyListeners();
  }

  displayHidden(bool show) {
    showHidden = show;
    _loadAccounts(_internalAccounts);
  }

  List<AccountModel> getAllAccounts(){
    return List.from(_internalAccounts);
  }

  AccountModel? getById(int id) =>
      _internalAccounts.where((account) => account.id == id).firstOrNull;

  Future load() async {
    // Fetched before anything is cleared, so a failed read keeps what is shown.
    final List<AccountModel> result;
    try {
      result = await this.accountService.fetchAccounts();
    } on LocalReadFailedException {
      notifierService.notifyReadFailed();
      return;
    }
    this._internalAccounts.clear();
    this._internalAccounts.addAll(result);
    _loadAccounts(result);
  }

  _loadAccounts(List<AccountModel> result) {
    this.accounts.clear();
    this.accounts.addAll(showHidden
        ? _internalAccounts
        : _internalAccounts.where((element) => !element.isHidden).toList());
    notifyListeners();
  }

  Future add(AccountModel accountModel) async {
    try {
      var created = await this.accountService.add(accountModel);
      this._internalAccounts.add(created);
      this.accounts.add(created);
      notifyListeners();
      notifierService.notify('Account ${accountModel.name} added successfully');
    } on LocalWriteFailedException catch (error) {
      notifierService.notifyWriteRejected(error);
    } catch (ex) {
      print(ex);
      notifierService.notify('Failed to add account ${accountModel.name}', isError: true);
    }
  }

  Future update(AccountModel accountModel) async {
    try {
      await accountService.update(accountModel);
      _loadAccounts(accounts);
      notifierService.notify('Account ${accountModel.name} updated successfully');
    } on LocalWriteFailedException catch (error) {
      notifierService.notifyWriteRejected(error);
      // The caller edited the model before saving, so take the stored values back.
      await _reloadQuietly();
    } catch (ex) {
      notifierService.notify('Failed to update account ${accountModel.name}', isError: true);
      print(ex);
    }
  }

  Future archive(AccountModel accountModel) async {
    var archiveLabel = accountModel.archive ? 'archived' : 'unarchived';
    try {
      accountModel.archive = !accountModel.archive;
      await accountService.update(accountModel);
      _loadAccounts(accounts);
      notifierService.notify('Account ${accountModel.name} $archiveLabel successfully');
    } on LocalWriteFailedException catch (error) {
      accountModel.archive = !accountModel.archive;
      notifierService.notifyWriteRejected(error);
    } catch (ex) {
      notifierService.notify('Failed to $archiveLabel account ${accountModel.name}', isError: true);
      print(ex);
    }
  }

  Future hide(AccountModel accountModel) async {
    var hideLabel = accountModel.isHidden ? 'shown' : 'hidden';
    try {
      accountModel.isHidden = !accountModel.isHidden;
      await accountService.update(accountModel);
      _loadAccounts(accounts);
      notifierService.notify('Account ${accountModel.name} $hideLabel successfully');
    } on LocalWriteFailedException catch (error) {
      accountModel.isHidden = !accountModel.isHidden;
      notifierService.notifyWriteRejected(error);
    } catch (ex) {
      notifierService.notify('Failed to $hideLabel account ${accountModel.name}', isError: true);
      print(ex);
    }
  }

  Future delete(AccountModel accountModel) async {
    try {
      await this.accountService.delete(accountModel);
      this.accounts.remove(accountModel);
      notifyListeners();
      notifierService.notify('Account ${accountModel.name} deleted successfully');
    } on AccountHasTransactionsException {
      // The caller explains it to the user, so there is no generic failure notice.
      rethrow;
    } on LocalWriteFailedException catch (error) {
      notifierService.notifyWriteRejected(error);
      // The caller must not present the delete as done.
      rethrow;
    } catch (ex) {
      print(ex);
      notifierService.notify('Failed to delete account ${accountModel.name}', isError: true);
    }
  }

  Future<void> _reloadQuietly() async {
    try {
      await load();
    } catch (_) {
      // Keep what is shown if the stored values can't be read either.
    }
  }

  updateBalance(int accountId, double value, TransactionType type) {
    var account = this._internalAccounts.firstWhere(
        (element) => element.id == accountId,
        orElse: () => AccountModel.empty(0));
    account.balance = type == TransactionType.Income
        ? account.balance + value
        : account.balance - value;
    _loadAccounts(_internalAccounts);
  }

  revertBalance(int accountId, double value, TransactionType type) {
    var account = this._internalAccounts.firstWhere(
        (element) => element.id == accountId,
        orElse: () => AccountModel.empty(0));
    account.balance = type == TransactionType.Income
        ? account.balance - value
        : account.balance + value;
    _loadAccounts(_internalAccounts);
  }

  setBalance(AccountModel targetAccount) {
    var account = this._internalAccounts.firstWhere(
        (element) => element.id == targetAccount.id,
        orElse: () => AccountModel.empty(0));
    account.balance = targetAccount.balance;
    _loadAccounts(_internalAccounts);
  }

  setBalances(List<AccountModel> targetAccounts) {
    for (var targetAccount in targetAccounts) {
      var account = this._internalAccounts.firstWhere(
          (element) => element.id == targetAccount.id,
          orElse: () => AccountModel.empty(0));
      account.balance = targetAccount.balance;
    }
    _loadAccounts(_internalAccounts);
  }
}
