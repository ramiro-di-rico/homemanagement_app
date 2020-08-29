import 'package:flutter/cupertino.dart';
import 'package:home_management_app/models/account.dart';
import 'package:http/http.dart' as http;
import 'authentication.service.dart';
import 'caching.dart';
import 'dart:convert';

class AccountService {
  AuthenticationService authenticationService;
  Caching caching;
  String cacheKey = 'accountsKey'; 
  List<AccountModel> accounts = List<AccountModel>();

  AccountService(
      {@required this.authenticationService, @required this.caching});

  Future<List<AccountModel>> getAccounts() async {
    if (this.caching.exists(cacheKey)) {
      return this.caching.fetch(cacheKey) as List<AccountModel>;
    }

    if (this.accounts.length == 0) {
      var token = this.authenticationService.getUserToken();

      var response = await http.get(
          'http://206.189.239.38:5100/api/account',
          headers: <String, String>{'Authorization': token});

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        this.accounts.addAll(data.map((e) => AccountModel.fromJson(e)));
        caching.add(cacheKey, this.accounts);
      } else {
        throw Exception('Failed to fetch Accounts.');
      }
    }

    return this.accounts;
  }
}
