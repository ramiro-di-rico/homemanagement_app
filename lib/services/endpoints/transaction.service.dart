import 'package:home_management_app/models/currency.dart';
import 'package:http/http.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/http-models/transaction-with-balance.dart';
import '../../models/transaction.dart';
import '../../models/transaction.page.dart';
import 'api.service.factory.dart';
import '../security/authentication.service.dart';
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
      TransactionType? transactionType, List<AccountModel> accounts, List<CategoryModel> categories, List<CurrencyModel> currencies) async {

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

  Future<String> export(int accountId) async {
    var body = await apiServiceFactory.rawApiGet('$apiName/export?accountId=$accountId');
    return body;
  }

  Future import(int id, String fileContent) async {

    var file = MultipartFile.fromString('csv', fileContent, filename: "file.csv");
    await apiServiceFactory.upload(apiName + '/import', file);
  }
}
