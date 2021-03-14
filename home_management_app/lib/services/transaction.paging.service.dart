import 'package:flutter/material.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/models/transaction.page.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'package:home_management_app/services/transaction.service.dart';

class TransactionPagingService extends ChangeNotifier {
  TransactionService transactionService;
  TransactionRepository transactionRepository;
  final List<TransactionModel> transactions = [];
  final int pageSize = 20;
  int currentAccountId = 0;
  TransactionPageModel page;
  String nameFiltering = '';

  TransactionPagingService(
      {@required this.transactionService,
      @required this.transactionRepository})
  {
    this.transactionRepository.addListener(refresh);
  }  

  Future refresh() async {
    this.transactions.clear();
    this.transactionRepository.clear(this.currentAccountId);
    await this.loadFirstPage(this.currentAccountId);
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
    var query = transactionRepository.transactions
        .where((element) => element.accountId == page.accountId);

    if(nameFiltering.length > 1){
      query = query.where((element) => element.name.toLowerCase().contains(nameFiltering.toLowerCase()));
    }

    List<TransactionModel> result = query
        .take(this.pageSize)
        .skip((this.page.currentPage - 1) * this.pageSize)
        .toList();

    if (result.length < this.pageSize) {
      if(nameFiltering.length > 1){
        result = await this.transactionService.pageNameFiltering(page, nameFiltering);
        this.transactionRepository.internalAdd(result);
      }else{
        result = await this.transactionService.page(page);
        this.transactionRepository.internalAdd(result);
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
    await this.loadFirstPage(this.currentAccountId);
  }
}
