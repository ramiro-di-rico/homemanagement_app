import 'package:flutter/material.dart';

import '../models/account-historical.dart';
import 'api.service.factory.dart';
import 'authentication.service.dart';

class DashboardService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;

  DashboardService(
      {@required this.authenticationService, @required this.apiServiceFactory});

  Future<List<AccountHistorical>> fetchAccountHistoricalChart() async {
    var data =
        await this.apiServiceFactory.fetchList('Dashboard/accounts/historical');
    var result = data.map((e) => AccountHistorical.fromJson(e)).toList();
    return result;
  }
}
