import 'package:flutter/material.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/models/transaction.page.dart';
import 'package:home_management_app/services/transaction.service.dart';

class TransactionRepository extends ChangeNotifier {
  
  TransactionService transactionService;
  final List<TransactionModel> transactions = List<TransactionModel>();
  int currentPage = 1;
  final int pageSize = 10;
  int currentAccountId = 0;
  TransactionPageModel page;

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

  void clear(){
    this.transactions.clear();
    notifyListeners();
  }

  Future loadFirstPage(int accountId) async {
    this.currentAccountId = accountId;
    page = TransactionPageModel.newPage(accountId, 1, pageSize);
    await fetchPage();
  }

  Future nextPage() async {
    page.currentPage++;
    await fetchPage();
  }

  Future fetchPage() async {
    var result = await getPage();
    transactions.addAll(result);
    notifyListeners();
  }

  Future<List<TransactionModel>> getPage() async {
    List<TransactionModel> result = this.transactions
        .where((element) => element.accountId == page.accountId)
        .take(this.pageSize)
        .skip((this.page.currentPage - 1) * this.pageSize)
        .toList();

    if (result.length < this.pageSize) {
      result = await this.transactionService.page(page);
      internalAdd(result);
    }
    return result;
  }

    void internalAdd(List<TransactionModel> result){    
    for (var transaction in result) {
      if(transactions.any((element) => element.id == transaction.id)){
        transactions.removeWhere((element) => element.id == transaction.id);
      }
      this.transactions.add(transaction);
    }       
  }
}