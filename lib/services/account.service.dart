import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/metrics/account-metrics.dart';
import 'api.service.factory.dart';
import 'authentication.service.dart';
import 'dart:convert';

class AccountService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;

  AccountService(
      {@required this.authenticationService, @required this.apiServiceFactory});

  Future<List<AccountModel>> fetchAccounts() async {
    var list = await this.apiServiceFactory.fetchList('account');
    var result = list.map((e) => AccountModel.fromJson(e)).toList();
    return result;
  }

  Future add(AccountModel accountModel) async {
    var body = jsonEncode(accountModel);
    await this.apiServiceFactory.apiPost('account', body);
  }

  Future update(AccountModel account) async {
    var msg = jsonEncode(account);
    await this.apiServiceFactory.apiPut('account', msg);
  }

  Future delete(AccountModel accountModel) async {
    await this.apiServiceFactory.apiDelete('account', accountModel.id.toString());
  }

  Future<List<AccountSeries>> getSeriesMetric() async {
    List<dynamic> list = await this.apiServiceFactory.apiGet('account/v1/avgseries');
    List<AccountSeries> result = list.map((e) => AccountSeries.fromJson(e)).toList();
    return result;
  }
}
