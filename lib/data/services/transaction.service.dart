import 'package:home_management_app/domain/models/currency.dart';
import 'package:http/http.dart';

import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/data/models/transaction-with-balance.dart';
import 'package:home_management_app/domain/models/tag.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/domain/models/transaction.page.dart';
import 'api.service.factory.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'dart:convert';

class TransactionService {
  AuthenticationService authenticationService;
  late ApiServiceFactory apiServiceFactory;
  final String apiName = 'transactions';

  TransactionService({required this.authenticationService}) {
    this.apiServiceFactory =
        ApiServiceFactory(authenticationService: this.authenticationService);
  }

  Future<List<TransactionModel>> page(TransactionPageModel page) async {
    dynamic data = await apiServiceFactory.apiGet(
        '$apiName/filter?accountId=${page.accountId}&currentPage=${page.currentPage}&pageSize=${page.pageCount}');
    var pageResult = TransactionPageModel.fromJson(data);
    return pageResult.items;
  }

  Future<List<TransactionModel>> pageNameFiltering(
      TransactionPageModel page, String name) async {
    dynamic data = await apiServiceFactory.apiGet(
        '$apiName/filter?accountId=${page.accountId}&name=$name&currentPage=${page.currentPage}&pageSize=${page.pageCount}');

    var pageResult = TransactionPageModel.fromJson(data);
    return pageResult.items;
  }

  Future<List<TransactionModel>> filter(int currentPage, int pageSize,
      List<int>? accountIds, String? name, DateTime? startDate, DateTime? endDate,
      TransactionType? transactionType, List<AccountModel> accounts, List<CategoryModel> categories, List<CurrencyModel> currencies,
      {List<String>? tagNames}) async {

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

    if (transactionType != null) {
      queryFilter += '&transactionType=${transactionType == TransactionType.Income ? 0 : 1}';
    }

    if (accounts.isNotEmpty) {
      queryFilter += '&accountIds=' + accounts.map((e) => e.id).join('&accountIds=');
    }

    if (categories.isNotEmpty) {
      queryFilter += '&categoryIds=' + categories.map((e) => e.id).join('&categoryIds=');
    }

    if (currencies.isNotEmpty) {
      queryFilter += '&currencyId=' + currencies.first.id.toString();
    }

    if (tagNames != null && tagNames.isNotEmpty) {
      queryFilter += '&tagNames=' + tagNames.join('&tagNames=');
    }

    dynamic data = await apiServiceFactory.apiGet(
        '$apiName/filter?${queryFilter}');
    var pageResult = TransactionPageModel.fromJson(data);
    return pageResult.items;
  }

  Future<TransactionWithBalanceModel> add(
      TransactionModel transactionModel) async {
    var body = json.encode(transactionModel.toJson());
    var result = await apiServiceFactory.postWithReturn(apiName, body);
    return TransactionWithBalanceModel.fromJson(result);
  }

  Future delete(int id) async {
    await apiServiceFactory.apiDelete(apiName, id.toString());
  }

  Future update(TransactionModel transactionModel) async {
    var body = json.encode(transactionModel.toJson());
    await apiServiceFactory.apiPut(
        apiName + '/' + transactionModel.id.toString(), body);
  }

  Future<TransactionModel> syncTags(int transactionId, List<String> names) async {
    final body = json.encode(SyncTagsRequest(names).toJson());
    final result = await apiServiceFactory.apiPut(
        '$apiName/$transactionId/tags', body);
    if (result is Map<String, dynamic>) {
      return TransactionModel.fromJson(result);
    }
    throw Exception('Failed to sync tags for transaction $transactionId');
  }

  Future<String> export(int accountId) async {
    var body = await apiServiceFactory.rawApiGet('$apiName/export?accountId=$accountId');
    return body;
  }

  Future import(int id, String fileContent) async {
    var file = MultipartFile.fromString('csv', fileContent, filename: "file.csv");
    await apiServiceFactory.upload(apiName + '/import', file);
  }

  Future<List<AccountModel>> bulkAdd(List<TransactionModel> transactions) async {
    var body = json.encode({
      'transactions': transactions.map((t) => t.toJson()).toList(),
    });
    var data = await apiServiceFactory.postWithReturn('$apiName/bulk', body);
    return (data as List).map((e) => AccountModel.fromJson(e)).toList();
  }
}
