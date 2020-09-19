import 'package:flutter/material.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/services/transaction.service.dart';

class TransactionRepository extends ChangeNotifier {
  
  TransactionService transactionService;
  final List<TransactionModel> transactions = List<TransactionModel>();

  TransactionRepository({@required this.transactionService});

  Future add(TransactionModel transaction) async {
    await this.transactionService.add(transaction);
    this.transactions.insert(0, transaction);
    notifyListeners();
  }

  Future remove(TransactionModel transactionModel) async {
    await this.transactionService.delete(transactionModel.id);
    this.transactions.remove(transactionModel);
    notifyListeners();
  }

  Future update(TransactionModel transactionModel) async {
    await this.transactionService.update(transactionModel);
    notifyListeners();
  }

  void internalAdd(List<TransactionModel> result){    
    for (var transaction in result) {
      if(transactions.any((element) => element.id == transaction.id)){
        transactions.removeWhere((element) => element.id == transaction.id);
      }
      this.transactions.add(transaction);
    }       
  }

  void clear(int accountId){
    this.transactions.removeWhere((element) => element.accountId == accountId);
  }
}