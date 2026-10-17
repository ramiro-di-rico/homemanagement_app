import 'package:home_management_app/domain/models/currency.dart';

abstract interface class CurrencyDataSource {
  Future<List<CurrencyModel>> fetchCurrencies();
}
