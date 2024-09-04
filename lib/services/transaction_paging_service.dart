import 'package:flutter/cupertino.dart';

import '../models/transaction.dart';
import '../views/main/transactions_search_desktop_view.dart';
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

  Future performSearch(TransactionSearchOptions searchOptions) async {
    filtering = true;
    _calculateAmountOfFilters(searchOptions);

    transactions = await _transactionService.filter(
        1, 10, null, searchOptions.name, searchOptions.startDate, searchOptions.endDate);

    notifyListeners();
  }


  void _calculateAmountOfFilters(TransactionSearchOptions searchOptions) {
    selectedFilters = 0;
    if (searchOptions.name?.isNotEmpty == true) {
      selectedFilters++;
    }
    if (searchOptions.startDate != null) {
      selectedFilters++;
    }
    if (searchOptions.endDate != null) {
      selectedFilters++;
    }
  }
}

class TransactionSearchOptions{
  String? name;
  DateTime? startDate;
  DateTime? endDate;
  List<DropdownAccountSelection> accountsSelection;

  TransactionSearchOptions(this.name, this.startDate, this.endDate, this.accountsSelection);
}