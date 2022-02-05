import 'package:flutter/material.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/models/transaction.page.dart';
import 'package:http/http.dart' as http;
import 'api.service.factory.dart';
import 'authentication.service.dart';
import 'dart:convert';

class TransactionService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;
  final String apiName = 'transactions';

  TransactionService({@required this.authenticationService}) {
    this.apiServiceFactory =
        ApiServiceFactory(authenticationService: this.authenticationService);
  }

  Future<List<TransactionModel>> page(TransactionPageModel page) async {
    var token = this.authenticationService.getUserToken();

    var uri = Uri.parse(
        'https://ramiro-di-rico.dev/homemanagementapi/api/transactions/v1/account/${page.accountId}/page?currentPage=${page.currentPage}&pageSize=${page.pageCount}');

    var response = await http.get(uri, headers: <String, String>{
      'Authorization': token,
    });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      var result = data.map((e) => TransactionModel.fromJson(e)).toList();
      return result;
    } else {
      throw Exception('Failed to fetch Transactions.');
    }
  }

  Future<List<TransactionModel>> pageNameFiltering(
      TransactionPageModel page, String name) async {
    var token = this.authenticationService.getUserToken();

    var uri = Uri.parse(
        'https://ramiro-di-rico.dev/homemanagementapi/api/transactions/v1/filter?accountId=${page.accountId}&name=$name&currentPage=${page.currentPage}&pageSize=${page.pageCount}');
    var response = await http.get(uri, headers: <String, String>{
      'Authorization': token,
    });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      var result = data.map((e) => TransactionModel.fromJson(e)).toList();
      return result;
    } else {
      throw Exception('Failed to fetch Transactions.');
    }
  }

  Future add(TransactionModel transactionModel) async {
    var body = json.encode(transactionModel.toJson());
    await apiServiceFactory.apiPost(apiName, body);
  }

  Future delete(int id) async {
    await apiServiceFactory.apiDelete(apiName, id.toString());
  }

  Future update(TransactionModel transactionModel) async {
    var body = json.encode(transactionModel.toJson());
    await apiServiceFactory.apiPut(apiName, body);
  }
}
