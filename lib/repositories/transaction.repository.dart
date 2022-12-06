import 'package:flutter/material.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:home_management_app/services/transaction.service.dart';

class TransactionRepository extends ChangeNotifier {
  TransactionService transactionService;
  AccountRepository accountRepository;
  final List<TransactionModel> transactions = [];

  TransactionRepository(
      {@required this.transactionService, @required this.accountRepository});

  Future add(TransactionModel transaction) async {
    await this.transactionService.add(transaction);
    this.transactions.insert(0, transaction);
    this.accountRepository.updateBalance(
        transaction.accountId, transaction.price, transaction.transactionType);
    notifyListeners();
  }

  Future remove(TransactionModel transactionModel) async {
    await this.transactionService.delete(transactionModel.id);
    this.transactions.remove(transactionModel);
    this.accountRepository.updateBalance(transactionModel.accountId,
        -transactionModel.price, transactionModel.transactionType);
    notifyListeners();
  }

  Future update(TransactionModel transactionModel) async {
    await this.transactionService.update(transactionModel);
    notifyListeners();
  }

  void internalAdd(List<TransactionModel> result) {
    for (var transaction in result) {
      if (transactions.any((element) => element.id == transaction.id)) {
        transactions.removeWhere((element) => element.id == transaction.id);
      }
      this.transactions.add(transaction);
    }
  }

  void clear(int accountId) {
    this.transactions.removeWhere((element) => element.accountId == accountId);
  }
}
