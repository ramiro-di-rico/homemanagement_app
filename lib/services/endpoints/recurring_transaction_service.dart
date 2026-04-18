import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/recurring_transaction.dart';
import '../security/authentication.service.dart';
import 'api.service.factory.dart';

class RecurringTransactionService {
  AuthenticationService authenticationService;
  late ApiServiceFactory apiServiceFactory;
  final String v3ApiName = 'RecurringTransactions/v3';
  final String apiName = 'recurringtransactions';

  RecurringTransactionService({required this.authenticationService}) {
    this.apiServiceFactory =
        ApiServiceFactory(authenticationService: this.authenticationService);
  }

  Future<List<RecurringTransaction>> getAll() async {
    dynamic data = await apiServiceFactory.apiGet('$apiName');
    return (data as List)
        .map((item) => RecurringTransaction.fromJson(item))
        .toList();
  }

  Future create(RecurringTransaction transaction) async {
    var body = jsonEncode(transaction.toJson());
    await apiServiceFactory.apiPost(apiName, body);
  }

  Future<RecurringTransaction> update(RecurringTransaction transaction) async {
    var body = jsonEncode(transaction.toJson());
    dynamic data = await apiServiceFactory.apiPut(apiName, body);
    return RecurringTransaction.fromJson(data);
  }

  Future<void> delete(int id) async {
    await apiServiceFactory.apiDelete('$apiName', id.toString());
  }
}