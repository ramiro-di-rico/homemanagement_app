import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';
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

  Future update(AccountModel account) async {
    var msg = jsonEncode(account);
    await this.apiServiceFactory.apiPut('account', msg);
  }
}
