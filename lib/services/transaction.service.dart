import 'package:flutter/material.dart';
import 'package:home_management_app/models/http-models/transaction-with-balance.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/models/transaction.page.dart';
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
    List<dynamic> data = await apiServiceFactory.apiGet(
        '$apiName/v1/filter?accountId=${page.accountId}&currentPage=${page.currentPage}&pageSize=${page.pageCount}');

    return data.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<List<TransactionModel>> pageNameFiltering(
      TransactionPageModel page, String name) async {
    List<dynamic> data = await apiServiceFactory.apiGet(
        '$apiName/v1/filter?accountId=${page.accountId}&name=$name&currentPage=${page.currentPage}&pageSize=${page.pageCount}');

    return data.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<TransactionModel> add(TransactionModel transactionModel) async {
    var body = json.encode(transactionModel.toJson());
    var result = await apiServiceFactory.postWithReturn(apiName, body);
    return TransactionModel.fromJson(result);
  }

  Future delete(int id) async {
    await apiServiceFactory.apiDelete(apiName, id.toString());
  }

  Future update(TransactionModel transactionModel) async {
    var body = json.encode(transactionModel.toJson());
    await apiServiceFactory.apiPut(apiName, body);
  }

  Future<TransactionWithBalanceModel> addV2(
      TransactionModel transactionModel) async {
    var body = json.encode(transactionModel.toJson());
    var result = await apiServiceFactory.postWithReturn('$apiName/v2', body);
    return TransactionWithBalanceModel.fromJson(result);
  }
}
