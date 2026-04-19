import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../models/main_account.dart';
import '../endpoints/main_account.service.dart';
import '../infra/error_notifier_service.dart';

class MainAccountRepository extends ChangeNotifier {
  MainAccountService mainAccountService;
  NotifierService notifierService;
  final List<MainAccountModel> _internalMainAccounts = [];
  final List<MainAccountModel> mainAccounts = [];
  bool showHidden = false;

  MainAccountRepository({required this.mainAccountService, required this.notifierService});

  Future refresh() async => await load();

  displayHidden(bool show) {
    showHidden = show;
    _loadMainAccounts(_internalMainAccounts);
  }

  Future load() async {
    var result = await this.mainAccountService.fetchMainAccounts();
    this._internalMainAccounts.clear();
    this._internalMainAccounts.addAll(result);
    _loadMainAccounts(result);
  }

  _loadMainAccounts(List<MainAccountModel> result) {
    this.mainAccounts.clear();
    this.mainAccounts.addAll(showHidden
        ? _internalMainAccounts
        : _internalMainAccounts.where((element) => !element.isHidden).toList());
    notifyListeners();
  }

  Future add(MainAccountModel mainAccount) async {
    try {
      await this.mainAccountService.add(mainAccount);
      await load();
      notifierService.notify('Main Account ${mainAccount.name} added successfully');
    } catch (ex) {
      print(ex);
      notifierService.notify('Failed to add main account ${mainAccount.name}');
    }
  }

  Future update(MainAccountModel mainAccount) async {
    try {
      await mainAccountService.update(mainAccount);
      await load();
      notifierService.notify('Main Account ${mainAccount.name} updated successfully');
    } catch (ex) {
      notifierService.notify('Failed to update main account ${mainAccount.name}');
      print(ex);
    }
  }

  Future hide(MainAccountModel mainAccount) async {
    var hideLabel = mainAccount.isHidden ? 'shown' : 'hidden';
    try {
      mainAccount.isHidden = !mainAccount.isHidden;
      await mainAccountService.update(mainAccount);
      await load();
      notifierService.notify('Main Account ${mainAccount.name} ${hideLabel} successfully');
    } catch (ex) {
      notifierService.notify('Failed to ${hideLabel} main account ${mainAccount.name}');
      print(ex);
    }
  }

  Future delete(MainAccountModel mainAccount) async {
    try {
      await this.mainAccountService.delete(mainAccount);
      await load();
      notifierService.notify('Main Account ${mainAccount.name} deleted successfully');
    } catch (ex) {
      print(ex);
      notifierService.notify('Failed to delete main account ${mainAccount.name}');
    }
  }

  Future<List<AccountModel>> getAccounts(int mainAccountId) async {
    return await mainAccountService.fetchAccounts(mainAccountId);
  }

  Future addAccountToMain(int mainAccountId, int accountId) async {
    try {
      await mainAccountService.addAccount(mainAccountId, accountId);
      await load();
      notifierService.notify('Account added to main account successfully');
    } catch (ex) {
      notifierService.notify('Failed to add account to main account');
      print(ex);
    }
  }

  Future removeAccountFromMain(int mainAccountId, int accountId) async {
    try {
      await mainAccountService.removeAccount(mainAccountId, accountId);
      await load();
      notifierService.notify('Account removed from main account successfully');
    } catch (ex) {
      notifierService.notify('Failed to remove account from main account');
      print(ex);
    }
  }
}
