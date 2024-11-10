import 'package:flutter/cupertino.dart';

import '../../models/budget.dart';
import '../../models/http-models/budget_metric_model.dart';
import '../endpoints/budget_http_service.dart';
import '../infra/error_notifier_service.dart';

class BudgetRepository extends ChangeNotifier{
  NotifierService errorNotifierService;
  BudgetHttpService budgetHttpService;
  List<BudgetModel> _budgets = [];
  List<BudgetMetricModel> budgetMetrics = [];

  BudgetRepository(this.errorNotifierService, this.budgetHttpService);

  List<BudgetModel> get budgets => _budgets;

  Future load() async {
    try {
      _budgets = await budgetHttpService.getBudgets();
      await loadBudgetMetrics();
      //notifyListeners();
    } on Exception catch (e) {
      errorNotifierService.notify('Error loading budgets: $e', isError: true);
    }
  }

  Future loadBudgetMetrics() async {
    try {
      budgetMetrics = await budgetHttpService.getBudgetMetrics();
      notifyListeners();
    } on Exception catch (e) {
      errorNotifierService.notify('Error loading budget metrics: $e', isError: true);
    }
  }

  Future addBudget(BudgetModel budget) async {
    try {
      var addedBudget = await budgetHttpService.addBudget(budget);
      _budgets.add(addedBudget);
      _notify('Budget ${budget.name} added successfully');
    } on Exception catch (e) {
      _notify('Error adding budget: $e', isError: true);
    }
  }

  Future updateBudget(BudgetModel budget) async {
    try {
      await budgetHttpService.updateBudget(budget);
      var index = _budgets.indexWhere((element) => element.id == budget.id);
      _budgets[index] = budget;
      _notify('Budget ${budget.name} updated successfully');
    } on Exception catch (e) {
      _notify('Error updating budget: $e', isError: true);
    }
  }

  Future removeBudget(BudgetModel budget) async {
    try {
      await budgetHttpService.removeBudget(budget);
      _budgets.remove(budget);
      _notify('Budget ${budget.name} removed successfully');
    } on Exception catch (e) {
      _notify('Error removing budget: $e', isError: true);
    }
  }

  void _notify(String message, {bool isError = false}) {
    errorNotifierService.notify(message);
    notifyListeners();
    Future.delayed(Duration(milliseconds: 300), () async {
      await loadBudgetMetrics();
    });
  }
}