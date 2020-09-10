import 'package:flutter/material.dart';
import 'package:home_management_app/models/currency.dart';
import 'package:home_management_app/services/currency.service.dart';

class CurrencyRepository extends ChangeNotifier{
  @protected  
  CurrencyService currencyService;
  
  List<CurrencyModel> currencies = List<CurrencyModel>();
  
  CurrencyRepository({@required this.currencyService});

  Future load() async {
    var result = await this.currencyService.fetchCurrencies();
    currencies.addAll(result);
  }

  Future update() async {
    notifyListeners();
  }
}