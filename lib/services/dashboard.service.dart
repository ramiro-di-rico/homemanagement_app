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

  Future<List<AccountHistorical>> fetchAccountsHistoricalChart() async {
    if (this.caching.exists('fetchAccountsHistoricalChart')) {
      return this.caching.fetch('fetchAccountsHistoricalChart')
          as List<AccountHistorical>;
    }

    var data =
        await this.apiServiceFactory.fetchList('Dashboard/accounts/historical');
    var result = data.map((e) => AccountHistorical.fromJson(e)).toList();
    this.caching.add('fetchAccountsHistoricalChart', result);
    return result;
  }

  Future<List<AccountHistorical>> fetchAccountHistoricalChart(
      int accountId) async {
    var key = "fetchAccountsHistoricalChart-$accountId";
    if (this.caching.exists(key)) {
      return this.caching.fetch(key) as List<AccountHistorical>;
    }
    var data = await this
        .apiServiceFactory
        .fetchList('Dashboard/account/$accountId/historical');
    var result = data.map((e) => AccountHistorical.fromJson(e)).toList();
    this.caching.add(key, result);
    return result;
  }
}
