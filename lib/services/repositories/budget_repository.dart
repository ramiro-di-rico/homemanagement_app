import 'package:flutter/cupertino.dart';

import '../../models/budget.dart';

class BudgetRepository extends ChangeNotifier{

  List<Budget> _budgets = [];

  BudgetRepository(){
    _budgets.add(Budget(1, 'Groceries', 100, null, null, null, null, null, null));
    _budgets.add(Budget(2, 'Rent', 1000, null, null, null, null, DateTime.now(), null));
    _budgets.add(Budget(3, 'Utilities', 200, null, null, null, null, null, DateTime.now()));
  }

  List<Budget> get budgets => _budgets;

  Future addBudget(Budget budget) async {
    _budgets.add(budget);
    notifyListeners();
  }

  Future updateBudget(Budget budget) async {
    // Update the budget
    notifyListeners();
  }

  Future removeBudget(Budget budget) async {
    _budgets.remove(budget);
    notifyListeners();
  }
}