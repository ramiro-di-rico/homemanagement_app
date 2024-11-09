import 'package:flutter/cupertino.dart';

import '../../models/budget.dart';
import '../endpoints/budget_http_service.dart';
import '../infra/error_notifier_service.dart';

class BudgetRepository extends ChangeNotifier{
  NotifierService errorNotifierService;
  BudgetHttpService budgetHttpService;
  List<BudgetModel> _budgets = [];

  BudgetRepository(this.errorNotifierService, this.budgetHttpService);

  List<BudgetModel> get budgets => _budgets;

  Future load() async {
    try {
      _budgets = await budgetHttpService.getBudgets();
      notifyListeners();
    } on Exception catch (e) {
      errorNotifierService.notify('Error loading budgets: $e', isError: true);
    }
  }

  Future addBudget(BudgetModel budget) async {
    try {
      var addedBudget = await budgetHttpService.addBudget(budget);
      _budgets.add(addedBudget);
      errorNotifierService.notify('Budget ${budget.name} added successfully');
      notifyListeners();
    } on Exception catch (e) {
      errorNotifierService.notify('Error adding budget: $e', isError: true);
    }
  }

  Future updateBudget(BudgetModel budget) async {
    try {
      await budgetHttpService.updateBudget(budget);
      var index = _budgets.indexWhere((element) => element.id == budget.id);
      _budgets[index] = budget;
      errorNotifierService.notify('Budget ${budget.name} updated successfully');
      notifyListeners();
    } on Exception catch (e) {
      errorNotifierService.notify('Error updating budget: $e', isError: true);
    }
  }

  Future removeBudget(BudgetModel budget) async {
    try {
      await budgetHttpService.removeBudget(budget);
      _budgets.remove(budget);
      errorNotifierService.notify('Budget ${budget.name} removed successfully');
      notifyListeners();
    } on Exception catch (e) {
      errorNotifierService.notify('Error removing budget: $e', isError: true);
    }
  }
}