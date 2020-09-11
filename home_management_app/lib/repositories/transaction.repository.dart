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

  void add(List<TransactionModel> result){    
    for (var transaction in result) {
      if(transactions.any((element) => element.id == transaction.id)){
        transactions.removeWhere((element) => element.id == transaction.id);
      }
      this.transactions.add(transaction);
    }       
  }
}