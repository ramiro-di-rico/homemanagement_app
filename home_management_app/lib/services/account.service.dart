import 'package:flutter/cupertino.dart';
import 'package:home_management_app/models/account.dart';
import 'package:http/http.dart' as http;
import 'authentication.service.dart';
import 'caching.dart';
import 'dart:convert';

class AccountService extends ChangeNotifier {
  AuthenticationService authenticationService;
  Caching caching;
  String cacheKey = 'accountsKey';
  final List<AccountModel> accounts = List<AccountModel>();

  AccountService(
      {@required this.authenticationService, @required this.caching});

  Future loadAccounts() async {
    this.accounts.addAll(this.caching.exists(cacheKey) ? 
      this.caching.fetch(cacheKey) as List<AccountModel> : 
      await fetchAccounts());

    notifyListeners();
  }

  void add(AccountModel accountModel){
    var accounts = this.caching.fetch(cacheKey) as List<AccountModel>;
    accounts.add(accountModel);
    this.caching.add(cacheKey, accounts);
    notifyListeners();
  }

  Future<List<AccountModel>> fetchAccounts() async {
    var token = this.authenticationService.getUserToken();

    var response = await http.get('http://206.189.239.38:5100/api/account',
        headers: <String, String>{'Authorization': token});

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      var result = data.map((e) => AccountModel.fromJson(e)).toList();
      caching.add(cacheKey, result);
      return result;
    } else {
      throw Exception('Failed to fetch Accounts.');
    }
  }
}
