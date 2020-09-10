import 'package:flutter/cupertino.dart';
import 'package:home_management_app/models/account.dart';
import 'package:http/http.dart' as http;
import 'authentication.service.dart';
import 'dart:convert';

class AccountService {
  AuthenticationService authenticationService;

  AccountService(
      {@required this.authenticationService});

  Future<List<AccountModel>> fetchAccounts() async {
    var token = this.authenticationService.getUserToken();

    var response = await http.get('http://206.189.239.38:5100/api/account',
        headers: <String, String>{'Authorization': token});

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      var result = data.map((e) => AccountModel.fromJson(e)).toList();
      return result;
    } else {
      throw Exception('Failed to fetch Accounts.');
    }
  }
}
