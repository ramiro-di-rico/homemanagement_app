import 'package:home_management_app/domain/models/currency.dart';

import 'api.service.factory.dart';
import 'package:home_management_app/data/services/authentication.service.dart';

class CurrencyService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;

  CurrencyService(
      {required this.authenticationService, required this.apiServiceFactory});

  Future<List<CurrencyModel>> fetchCurrencies() async {
    var data = await this.apiServiceFactory.fetchList('currency');
    var result = data.map((e) => CurrencyModel.fromJson(e)).toList();
    return result;
  }
}
