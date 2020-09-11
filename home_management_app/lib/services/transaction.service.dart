import 'package:flutter/material.dart';
import 'package:home_management_app/models/preference.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/models/transaction.page.dart';
import 'package:http/http.dart' as http;
import 'authentication.service.dart';
import 'dart:convert';

class TransactionService{
  AuthenticationService authenticationService;

  TransactionService({@required this.authenticationService});

  Future<List<TransactionModel>> page(TransactionPageModel page) async {
    var token = this.authenticationService.getUserToken();

    var response = await http.get(
      'http://206.189.239.38:5100/api/transactions/v1/account/${page.accountId}/page?currentPage=${page.currentPage}&pageSize=${page.pageCount}',
        headers: <String, String>{
          'Authorization': token,
        }
      );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      var result = data.map((e) => TransactionModel.fromJson(e)).toList();
      return result;
    } else {
      throw Exception('Failed to fetch Transactions.');
    }
  }
}