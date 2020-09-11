import 'package:flutter/material.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/models/transaction.page.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'package:home_management_app/services/transaction.service.dart';

class TransactionPagingService extends ChangeNotifier {
  TransactionService transactionService;
  TransactionRepository transactionRepository;
  final List<TransactionModel> transactions = List<TransactionModel>();
  final int pageSize = 20;
  int currentAccountId = 0;
  TransactionPageModel page;

  TransactionPagingService(
      {@required this.transactionService,
      @required this.transactionRepository});

  Future loadFirstPage(int accountId) async {
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
    List<TransactionModel> result = transactionRepository.transactions
        .where((element) => element.accountId == page.accountId)
        .take(this.pageSize)
        .skip((this.page.currentPage - 1) * this.pageSize)
        .toList();

    if (result.length < this.pageSize) {
      result = await this.transactionService.page(page);
      this.transactionRepository.add(result);
    }
    return result;
  }
}
