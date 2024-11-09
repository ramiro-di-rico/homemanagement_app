import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../services/repositories/account.repository.dart';
import '../../../services/repositories/budget_repository.dart';
import '../../../services/repositories/category.repository.dart';
import '../../mixins/notifier_mixin.dart';
import 'budget_sheet_desktop.dart';

class BudgetListView extends StatefulWidget {
  @override
  State<BudgetListView> createState() => _BudgetListViewState();
}

class _BudgetListViewState extends State<BudgetListView> with NotifierMixin {
  BudgetRepository _budgetRepository = GetIt.I.get<BudgetRepository>();
  CategoryRepository _categoryRepository = GetIt.I.get<CategoryRepository>();
  AccountRepository _accountRepository = GetIt.I.get<AccountRepository>();

  @override
  void initState() {
    super.initState();
    _budgetRepository.addListener(refreshState);
  }

  @override
  void dispose() {
    _budgetRepository.removeListener(refreshState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            title: Text('Budgets'),
            trailing: ElevatedButton(
              onPressed: () {
                // Open the budget sheet
                showModalBottomSheet<void>(
                    context: context,
                    constraints: BoxConstraints(
                      maxHeight: 1000,
                      maxWidth: 1200,
                    ),
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0))),
                    builder: (context) {
                      return SizedBox(
                        height: 175,
                        child: AnimatedPadding(
                            padding: MediaQuery.of(context).viewInsets,
                            duration: Duration(seconds: 1),
                            child: BudgetSheetDesktop()),
                      );
                    });
              },
              child: Text('Add Budget'),
            ),
          ),
        ),
        _budgetRepository.budgets.isEmpty
            ? Card(
                child: ListTile(
                  title: Text('Budgets list is empty'),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _budgetRepository.budgets.length,
                itemBuilder: (context, index) {
                  var budget = _budgetRepository.budgets[index];
                  var dateFormat = 'dd-MM-yyyy';
                  var startDate = budget.startDate != null
                      ? DateFormat(dateFormat).format(budget.startDate!)
                      : 'N/A';
                  var endDate = budget.endDate != null
                      ? DateFormat(dateFormat).format(budget.endDate!)
                      : 'N/A';

                  var category = budget.categoryId != null
                      ? _categoryRepository.categories.firstWhere(
                          (element) => element.id == budget.categoryId)
                      : null;

                  var account = budget.accountId != null
                      ? _accountRepository.accounts.firstWhere(
                          (element) => element.id == budget.accountId)
                      : null;
                  return Card(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 200, child: Text(budget.name)),
                              Text(budget.amount.toString())
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                  width: 200,
                                  child: Text('Start: ${startDate}')),
                              SizedBox(
                                  width: 200, child: Text('End: ${endDate}')),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 150,
                                child: Chip(
                                  label: Text(category?.name ?? 'N/A'),
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 150,
                                child: Chip(
                                  label: Text(account?.name ?? 'N/A'),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Open the budget sheet
                                  showModalBottomSheet<void>(
                                      context: context,
                                      constraints: BoxConstraints(
                                        maxHeight: 1000,
                                        maxWidth: 1200,
                                      ),
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(25.0))),
                                      builder: (context) {
                                        return SizedBox(
                                          height: 175,
                                          child: AnimatedPadding(
                                              padding: MediaQuery.of(context)
                                                  .viewInsets,
                                              duration: Duration(seconds: 1),
                                              child: BudgetSheetDesktop(
                                                budget: budget,
                                              )),
                                        );
                                      });
                                },
                                child: Text('Edit'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _budgetRepository.removeBudget(budget);
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
      ],
    );
  }

  void refreshState() {
    setState(() {});
  }
}