import 'package:flutter/cupertino.dart';

import '../models/transaction.dart';
import '../views/main/widgets/transaction_search_filtering_options.dart';
import 'endpoints/transaction.service.dart';
import 'repositories/account.repository.dart';

class TransactionPagingService extends ChangeNotifier  {

  TransactionService _transactionService;
  AccountRepository _accountRepository;
  TransactionPagingService(this._accountRepository, this._transactionService);

  bool filtering = false;
  int currentPage = 1;
  int pageSize = 10;
  int selectedFilters = 0;
  List<TransactionModel> transactions = List.empty(growable: true);

  String? name = null;
  DateTime? startDate = null;
  DateTime? endDate = null;
  List<DropdownAccountSelection> accountsSelection = List.empty(growable: true);

  Future performSearch() async {
    filtering = true;
    _calculateAmountOfFilters();

    transactions = await _transactionService.filter(
        1, 10, null, name, startDate, endDate);

    notifyListeners();
  }

  void clearFilters() {
    name = null;
    startDate = null;
    endDate = null;
    accountsSelection.forEach((element) {
      element.isSelected = false;
    });
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
  }
}