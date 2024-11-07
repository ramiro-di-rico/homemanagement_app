import 'package:flutter/cupertino.dart';

import '../../models/budget.dart';

class BudgetRepository extends ChangeNotifier{

  List<BudgetModel> _budgets = [];

  BudgetRepository(){
    _budgets.add(BudgetModel(1, 'Groceries', 100, 3, null, null, null, null, null));
    _budgets.add(BudgetModel(2, 'Rent', 1000, 3, null, null, null, DateTime.now(), null));
    _budgets.add(BudgetModel(3, 'Utilities', 200, 3, null, null, null, null, DateTime.now()));
  }

  List<BudgetModel> get budgets => _budgets;

  Future addBudget(BudgetModel budget) async {
    _budgets.add(budget);
    notifyListeners();
  }

  Future updateBudget(BudgetModel budget) async {
    // Update the budget
    notifyListeners();
  }

  Future removeBudget(BudgetModel budget) async {
    _budgets.remove(budget);
    notifyListeners();
  }
}