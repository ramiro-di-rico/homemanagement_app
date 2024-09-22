import 'package:flutter/cupertino.dart';
import 'package:home_management_app/models/account.dart';

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

  String? name = null;
  DateTime? startDate = null;
  DateTime? endDate = null;
  TransactionType? transactionType = null;

  Future performSearch() async {
    filtering = true;
    loading = true;
    _calculateAmountOfFilters();
    notifyListeners();

    transactions = await _transactionService.filter(
        1, 10, null, name, startDate, endDate, transactionType);

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
    transactionType = null;
    filtering = false;
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
  }
}