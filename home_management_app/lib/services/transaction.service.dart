import 'package:flutter/material.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/models/transaction.page.dart';
import 'package:http/http.dart' as http;
import 'api.service.factory.dart';
import 'authentication.service.dart';
import 'dart:convert';

class TransactionService{
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;

  TransactionService({@required this.authenticationService}){
    this.apiServiceFactory = ApiServiceFactory(authenticationService: this.authenticationService);
  }

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

  Future add(TransactionModel transactionModel) async {
    /*
    var body = jsonEncode(transactionModel);
    var value = JsonEncoder().convert(transactionModel);

    await apiServiceFactory.apiPost('transactions', value);
    */

    var token = this.authenticationService.getUserToken();

    var bod = JsonEncoder().convert(jsonEncode(transactionModel));
    Map data = {
      'id': transactionModel.id,
      'accountId': transactionModel.accountId,
      'categoryId': transactionModel.categoryId,
      'name': transactionModel.name,
      'price': transactionModel.price,
      'date': transactionModel.date.toIso8601String(),
      'transactionType': transactionModel.transactionType == TransactionType.Income ? 0 : 1,
    };
    var body = json.encode(data);
    var response = await http.post('http://206.189.239.38:5100/api/transactions',
        headers: <String, String>{
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: body,
        encoding: Encoding.getByName('utf-8')
    );

    if(response.statusCode != 200){
      throw Exception('Failed to post to transactions');
    }
  }
}