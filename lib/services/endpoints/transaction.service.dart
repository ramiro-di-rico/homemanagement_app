import 'dart:typed_data';

import '../../models/http-models/transaction-with-balance.dart';
import '../../models/transaction.dart';
import '../../models/transaction.page.dart';
import 'api.service.factory.dart';
import '../security/authentication.service.dart';
import 'dart:convert';

class TransactionService {
  AuthenticationService authenticationService;
  late ApiServiceFactory apiServiceFactory;
  final String v3ApiName = 'transactions/v3';

  TransactionService({required this.authenticationService}) {
    this.apiServiceFactory =
        ApiServiceFactory(authenticationService: this.authenticationService);
  }

  Future<List<TransactionModel>> page(TransactionPageModel page) async {
    dynamic data = await apiServiceFactory.apiGet(
        '$v3ApiName/filter?accountId=${page.accountId}&currentPage=${page.currentPage}&pageSize=${page.pageCount}');
    var pageResult = TransactionPageModel.fromJson(data);
    return pageResult.items;
  }

  Future<List<TransactionModel>> pageNameFiltering(
      TransactionPageModel page, String name) async {
    dynamic data = await apiServiceFactory.apiGet(
        '$v3ApiName/filter?accountId=${page.accountId}&name=$name&currentPage=${page.currentPage}&pageSize=${page.pageCount}');

    var pageResult = TransactionPageModel.fromJson(data);
    return pageResult.items;
  }

  Future<List<TransactionModel>> filter(int currentPage, int pageSize,
      List<int>? accountIds, String? name, DateTime? startDate, DateTime? endDate) async {

    var queryFilter = 'currentPage=${currentPage}&pageSize=${pageSize}';

    if (accountIds != null) {
      queryFilter = 'accountIds=' + accountIds.join('&accountIds=');
    }

    if (name != null) {
      queryFilter += '&name=$name';
    }

    if (startDate != null) {
      queryFilter += '&startDate=${startDate.toUtc().toIso8601String()}';
    }

    if (endDate != null) {
      queryFilter += '&endDate=${endDate.toUtc().toIso8601String()}';
    }

    dynamic data = await apiServiceFactory.apiGet(
        '$v3ApiName/filter?${queryFilter}');
    var pageResult = TransactionPageModel.fromJson(data);
    return pageResult.items;
  }

  Future<TransactionWithBalanceModel> add(
      TransactionModel transactionModel) async {
    var body = json.encode(transactionModel.toJson());
    var result = await apiServiceFactory.postWithReturn(v3ApiName, body);
    return TransactionWithBalanceModel.fromJson(result);
  }

  Future delete(int id) async {
    await apiServiceFactory.apiDelete(v3ApiName, id.toString());
  }

  Future update(TransactionModel transactionModel) async {
    var body = json.encode(transactionModel.toJson());
    await apiServiceFactory.apiPut(
        v3ApiName + '/' + transactionModel.id.toString(), body);
  }

  Future<String> export(int accountId) async {
    var body = await apiServiceFactory.rawApiGet('$v3ApiName/export?accountId=$accountId');
    return body;
  }
}
