import 'package:flutter/cupertino.dart';

import '../../models/budget.dart';
import '../../models/http-models/budget_metric_model.dart';
import '../endpoints/budget_http_service.dart';
import '../infra/error_notifier_service.dart';

class BudgetRepository extends ChangeNotifier{
  NotifierService errorNotifierService;
  BudgetHttpService budgetHttpService;
  List<BudgetModel> _allBudgets = [];
  List<BudgetModel> budgets = [];
  List<BudgetMetricModel> budgetMetrics = [];
  BudgetFilteringOptions filteringOptions = BudgetFilteringOptions();

  BudgetRepository(this.errorNotifierService, this.budgetHttpService);

  Future load() async {
    try {
      await loadBudgetMetrics();
      await loadBudgets();
    } on Exception catch (e) {
      errorNotifierService.notify('Error loading budgets and metrics: $e', isError: true);
    }
  }

  Future loadBudgets() async {
    try {
      _allBudgets = await budgetHttpService.getBudgets();
      filterBudgetsBy();
    } on Exception catch (e) {
      errorNotifierService.notify('Error loading budgets: $e', isError: true);
    }
  }

  Future loadBudgetMetrics() async {
    try {
      budgetMetrics = await budgetHttpService.getBudgetMetrics();
    } on Exception catch (e) {
      errorNotifierService.notify('Error loading budget metrics: $e', isError: true);
    }
  }

  Future addBudget(BudgetModel budget) async {
    try {
      var addedBudget = await budgetHttpService.addBudget(budget);
      _allBudgets.add(addedBudget);
      _notify('Budget ${budget.name} added successfully');
    } on Exception catch (e) {
      _notify('Error adding budget: $e', isError: true);
    }
  }

  Future updateBudget(BudgetModel budget) async {
    try {
      await budgetHttpService.updateBudget(budget);
      var index = _allBudgets.indexWhere((element) => element.id == budget.id);
      _allBudgets[index] = budget;
      _notify('Budget ${budget.name} updated successfully');
    } on Exception catch (e) {
      _notify('Error updating budget: $e', isError: true);
    }
  }

  Future removeBudget(BudgetModel budget) async {
    try {
      await budgetHttpService.removeBudget(budget);
      _allBudgets.remove(budget);
      _notify('Budget ${budget.name} removed successfully');
    } on Exception catch (e) {
      _notify('Error removing budget: $e', isError: true);
    }
  }

  void _notify(String message, {bool isError = false}) {
    errorNotifierService.notify(message);
    filterBudgetsBy(categoryId: filteringOptions.categoryId,
        accountId: filteringOptions.accountId,
        currencyId: filteringOptions.currencyId,
        state: filteringOptions.state);
    Future.delayed(Duration(milliseconds: 300), () async {
      await loadBudgetMetrics();
      notifyListeners();
    });
  }

  void filterBudgetsBy({int? categoryId = null, int? accountId = null, int? currencyId = null, BudgetState? state = null}) {
    filteringOptions.accountId = accountId;
    filteringOptions.categoryId = categoryId;
    filteringOptions.currencyId = currencyId;
    filteringOptions.state = state;
    budgets = _allBudgets.where((element) {
      var categoryMatch = filteringOptions.categoryId == null || element.categoryId == categoryId;
      var accountMatch = filteringOptions.accountId == null || element.accountId == accountId;
      var currencyMatch = filteringOptions.currencyId == null || element.currencyId == currencyId;
      var stateMatch = filteringOptions.state == null || element.state == state;
      return categoryMatch && accountMatch && currencyMatch && stateMatch;
    }).toList();
    notifyListeners();
  }
}
class BudgetFilteringOptions{
  int? categoryId;
  int? accountId;
  int? currencyId;
  BudgetState? state;

  BudgetFilteringOptions({this.categoryId, this.accountId, this.currencyId, this.state});
}