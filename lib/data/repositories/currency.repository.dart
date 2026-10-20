import 'package:flutter/material.dart';
import 'package:home_management_app/domain/models/currency.dart';
import 'package:home_management_app/data/services/sources/currency_data_source.dart';

class CurrencyRepository extends ChangeNotifier {
  @protected
  CurrencyDataSource currencyService;

  List<CurrencyModel> currencies = [];

  CurrencyRepository({required this.currencyService});

  /// Forgets everything held in memory, for a change between local and online data.
  void reset() {
    currencies.clear();
    notifyListeners();
  }

  Future load() async {
    var result = await this.currencyService.fetchCurrencies();
    currencies.clear();
    currencies.addAll(result);
    notifyListeners();
  }

  Future update() async {
    notifyListeners();
  }
}
