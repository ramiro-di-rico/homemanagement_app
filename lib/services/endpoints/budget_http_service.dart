import '../../models/budget.dart';
import 'api.service.factory.dart';
import 'dart:convert';

class BudgetHttpService{

  ApiServiceFactory apiServiceFactory;
  final endpoint = 'budgets';

  BudgetHttpService(
      {required this.apiServiceFactory});

  Future<List<BudgetModel>> getBudgets() async {
    final response = await apiServiceFactory.fetchList(endpoint);

    return response.map((e) => BudgetModel.fromJson(e)).toList();
  }

  Future<BudgetModel> addBudget(BudgetModel budget) async {
    final decodedJson = await apiServiceFactory.postWithReturn(endpoint, jsonEncode(budget.ToJson()));
    return BudgetModel.fromJson(decodedJson);
  }

  Future updateBudget(BudgetModel budget) async {
    await apiServiceFactory.apiPut(endpoint, jsonEncode(budget.ToJson()));
  }

  Future<void> removeBudget(BudgetModel budget) async {
    await apiServiceFactory.apiDelete(endpoint, budget.id.toString());
  }
}