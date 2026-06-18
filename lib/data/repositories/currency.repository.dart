import 'package:flutter/material.dart';
import 'package:home_management_app/domain/models/currency.dart';
import 'package:home_management_app/data/services/currency.service.dart';

class CurrencyRepository extends ChangeNotifier {
  @protected
  CurrencyService currencyService;

  List<CurrencyModel> currencies = [];

  CurrencyRepository({required this.currencyService});

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
