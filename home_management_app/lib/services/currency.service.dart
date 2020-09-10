import 'package:flutter/material.dart';
import 'package:home_management_app/models/currency.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'authentication.service.dart';

class CurrencyService{

  AuthenticationService authenticationService;

  CurrencyService({@required this.authenticationService});

  Future<List<CurrencyModel>> fetchCurrencies() async {
    var token = this.authenticationService.getUserToken();

    var response = await http.get('http://206.189.239.38:5100/api/currency',
        headers: <String, String>{'Authorization': token});

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      var result = data.map((e) => CurrencyModel.fromJson(e)).toList();
      return result;
    } else {
      throw Exception('Failed to fetch Accounts.');
    }
  }
}