import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../../models/budget.dart';
import '../infra/error_notifier_service.dart';

class BudgetRepository extends ChangeNotifier{
  NotifierService errorNotifierService;
  List<BudgetModel> _budgets = [];

  BudgetRepository(this.errorNotifierService){
    _budgets.add(BudgetModel(1, 'Groceries', 100, 3, null, null, null, null, null));
    _budgets.add(BudgetModel(2, 'Rent', 1000, 3, null, null, null, DateTime.now(), null));
    _budgets.add(BudgetModel(3, 'Utilities', 200, 3, null, null, null, null, DateTime.now()));
  }

  List<BudgetModel> get budgets => _budgets;

  Future addBudget(BudgetModel budget) async {
    try {
      _budgets.add(budget);
      errorNotifierService.notify('Budget ${budget.name} added successfully');
      notifyListeners();
    } on Exception catch (e) {
      errorNotifierService.notify('Error adding budget: $e', isError: true);
    }
  }

  Future updateBudget(BudgetModel budget) async {
    try {
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
      _budgets.remove(budget);
      errorNotifierService.notify('Budget ${budget.name} removed successfully');
      notifyListeners();
    } on Exception catch (e) {
      errorNotifierService.notify('Error removing budget: $e', isError: true);
    }
  }
}