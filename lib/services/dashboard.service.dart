import 'package:flutter/material.dart';
import '../models/account-historical.dart';
import 'api.service.factory.dart';
import 'authentication.service.dart';
import 'caching.dart';

class DashboardService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;
  Caching caching;

  DashboardService(
      {@required this.authenticationService,
      @required this.apiServiceFactory,
      @required this.caching});

  Future<List<AccountHistorical>> fetchAccountHistoricalChart() async {
    if (this.caching.exists('fetchAccountHistoricalChart')) {
      return this.caching.fetch('fetchAccountHistoricalChart')
          as List<AccountHistorical>;
    }

    var data =
        await this.apiServiceFactory.fetchList('Dashboard/accounts/historical');
    var result = data.map((e) => AccountHistorical.fromJson(e)).toList();
    this.caching.add('fetchAccountHistoricalChart', result);
    return result;
  }
}
