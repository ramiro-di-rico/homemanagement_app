import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../services/repositories/budget_repository.dart';

class BudgetListView extends StatefulWidget {

  @override
  State<BudgetListView> createState() => _BudgetListViewState();
}

class _BudgetListViewState extends State<BudgetListView> {
  BudgetRepository _budgetRepository = GetIt.I.get<BudgetRepository>();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _budgetRepository.budgets.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_budgetRepository.budgets[index].name),
              subtitle: Text(_budgetRepository.budgets[index].amount.toString()),
            ),
          );
        });
  }
}
