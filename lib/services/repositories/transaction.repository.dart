import 'package:flutter/material.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/services/repositories/account.repository.dart';
import 'package:home_management_app/services/endpoints/transaction.service.dart';

import '../../models/transaction.page.dart';
import 'account.container.dart';

class TransactionRepository extends ChangeNotifier {
  TransactionService transactionService;
  AccountRepository accountRepository;
  List<AccountContainer> accountsContainer = [];

  final List<TransactionModel> transactions = [];
  final int pageSize = 20;
  int currentAccountId = 0;
  TransactionPageModel page = TransactionPageModel.newPage(0, 1, 20);
  String nameFiltering = '';

  TransactionRepository(
      {required this.transactionService, required this.accountRepository});

  Future add(TransactionModel transaction) async {
    var transactionResult = await this.transactionService.add(transaction);
    if (accountsContainer.any((element) =>
        element.account.id == transactionResult.transactionModel.accountId)) {
      var container = accountsContainer.firstWhere((element) =>
          element.account.id == transactionResult.transactionModel.accountId);
      container.transactions.insert(0, transactionResult.transactionModel);
      mapContainerToTransctions();
    }

    this.accountRepository.setBalance(transactionResult.sourceAccount);
    if (transactionResult.isTargetAccountAvailable()) {
      this.accountRepository.setBalance(transactionResult.targetAccount!);
    }
    notifyListeners();
  }

  Future remove(TransactionModel transactionModel) async {
    await this.transactionService.delete(transactionModel.id);
    var container = accountsContainer.firstWhere(
        (element) => element.account.id == transactionModel.accountId);
    container.transactions
        .removeWhere((element) => element.id == transactionModel.id);
    mapContainerToTransctions();
    this.accountRepository.updateBalance(transactionModel.accountId,
        -transactionModel.price, transactionModel.transactionType);
    notifyListeners();
  }

  Future update(TransactionModel transactionModel) async {
    await this.transactionService.update(transactionModel);
    var currentContainer = _getCurrentContainer();
    var currentTransaction = currentContainer.transactions
        .firstWhere((x) => x.id == transactionModel.id);
    this.accountRepository.revertBalance(currentTransaction.accountId,
        currentTransaction.price, currentTransaction.transactionType);
    this.accountRepository.updateBalance(transactionModel.accountId,
        transactionModel.price, transactionModel.transactionType);

    var index = currentContainer.transactions
        .indexWhere((element) => element.id == transactionModel.id);
    currentContainer.transactions[index] = transactionModel;
    mapContainerToTransctions();
    notifyListeners();
  }

  void clear(int accountId) {
    var container = accountsContainer
        .firstWhere((element) => element.account.id == accountId);
    container.transactions
        .removeWhere((element) => element.accountId == accountId);
  }

  Future refresh() async {
    this.transactions.clear();
    this.clearFilters();
    await this.loadFirstPage(this.currentAccountId);
  }

  Future loadFirstPage(int accountId) async {
    this.currentAccountId = accountId;
    transactions.clear();
    page = TransactionPageModel.newPage(accountId, 1, pageSize);
    if (!accountsContainer.any((element) => element.account.id == accountId)) {
      var containers =
          accountRepository.accounts.map((e) => AccountContainer(e)).toList();
      accountsContainer.addAll(containers);
    }
    await fetchPage();
  }

  Future nextPage() async {
    page.currentPage++;
    await fetchPage();
  }

  Future fetchPage() async {
    var result = await getPage();
    populateInternalLists(result);
    notifyListeners();
  }

  Future<List<TransactionModel>> getPage() async {
    var container = accountsContainer
        .firstWhere((element) => element.account.id == page.accountId);
    var query = container.transactions
        .where((element) => element.accountId == page.accountId);

    if (nameFiltering.length > 1) {
      query = query.where((element) =>
          element.name.toLowerCase().contains(nameFiltering.toLowerCase()));
    }

    List<TransactionModel> result = query
        .take(this.pageSize)
        .skip((this.page.currentPage - 1) * this.pageSize)
        .toList();

    if (result.length < this.pageSize) {
      if (nameFiltering.length > 1) {
        result = await this
            .transactionService
            .pageNameFiltering(page, nameFiltering);
      } else {
        result = await this.transactionService.page(page);
      }
    }
    return result;
  }

  Future applyFilterByName(String nameFiltering) async {
    this.page.currentPage = 1;
    this.nameFiltering = nameFiltering;
    transactions.clear();
    await fetchPage();
  }

  Future clearFilters() async {
    this.page.currentPage = 1;
    this.nameFiltering = '';
  }

  void populateInternalLists(List<TransactionModel> result) {
    var container = _getCurrentContainer();

    for (var transaction in result) {
      if (!container.transactions
          .any((element) => element.id == transaction.id)) {
        container.transactions.add(transaction);
      }
    }
    mapContainerToTransctions();
  }

  void mapContainerToTransctions() {
    transactions.clear();
    var container = _getCurrentContainer();
    for (var t in container.transactions) {
      transactions.add(t.clone());
    }
  }

  AccountContainer _getCurrentContainer() => accountsContainer
      .firstWhere((element) => element.account.id == page.accountId);
}
