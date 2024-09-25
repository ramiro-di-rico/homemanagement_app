import 'package:flutter/cupertino.dart';
import 'package:home_management_app/models/account.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../views/main/widgets/transaction_search_filtering_options.dart';
import 'endpoints/transaction.service.dart';
import 'repositories/account.repository.dart';

class TransactionPagingService extends ChangeNotifier  {

  TransactionService _transactionService;
  TransactionPagingService(this._transactionService);

  bool filtering = false;
  bool loading = false;
  int currentPage = 1;
  int pageSize = 10;
  int selectedFilters = 0;
  List<TransactionModel> transactions = List.empty(growable: true);
  List<AccountModel> selectedAccounts = List.empty(growable: true);
  List<CategoryModel> selectedCategories = List.empty(growable: true);

  String? name = null;
  DateTime? startDate = null;
  DateTime? endDate = null;
  TransactionType? transactionType = null;


  Future performSearch() async {
    filtering = true;
    loading = true;
    _calculateAmountOfFilters();
    notifyListeners();

    var results = await _transactionService.filter(
        currentPage, pageSize, null, name, startDate, endDate, transactionType, selectedAccounts, selectedCategories);

    if (results.isNotEmpty) {
      // Todo STILL shows duplicates
      transactions.addAll(results.where((element) => !transactions.any((transaction) => transaction.id == element.id)));
    }

    loading = false;
    notifyListeners();
  }

  void dispatchRefresh() {
    notifyListeners();
  }

  void clearFilters() {
    name = null;
    startDate = null;
    endDate = null;
    selectedAccounts.clear();
    selectedCategories.clear();
    transactionType = null;
    filtering = false;
    loading = false;
    currentPage = 1;
    notifyListeners();
  }

  void _calculateAmountOfFilters() {
    selectedFilters = 0;
    if (name?.isNotEmpty == true) {
      selectedFilters++;
    }
    if (startDate != null) {
      selectedFilters++;
    }
    if (endDate != null) {
      selectedFilters++;
    }
    if (transactionType != null) {
      selectedFilters++;
    }
    if (selectedAccounts.isNotEmpty) {
      selectedFilters++;
    }
    if (selectedCategories.isNotEmpty) {
      selectedFilters++;
    }
  }

  String generateCsvContent() {
    // Define the headers
    List<String> headers = [
      'Id',
      'Transaction Name',
      'Price',
      'Transaction Type',
      'Date',
      'Category Id',
      'Category Name',
      'Account Id'
    ];

    // Convert headers to CSV format
    String csvContent = headers.join(',') + '\n';

    // Iterate over transactions and convert each to a CSV row
    for (var transaction in transactions) {
      List<String> row = [
        transaction.id.toString(),
        transaction.name,
        transaction.price.toString(),
        transaction.parseTransactionByType(),
        DateFormat('yyyy-MM-dd').format(transaction.date),
        transaction.categoryId.toString(),
        transaction.categoryName,
        transaction.accountId.toString()
      ];
      csvContent += row.join(',') + '\n';
    }

    return csvContent;
  }
}