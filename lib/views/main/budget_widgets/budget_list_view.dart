import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../services/repositories/budget_repository.dart';
import '../../mixins/notifier_mixin.dart';
import 'budget_sheet_desktop.dart';

class BudgetListView extends StatefulWidget {
  @override
  State<BudgetListView> createState() => _BudgetListViewState();
}

class _BudgetListViewState extends State<BudgetListView> with NotifierMixin {
  BudgetRepository _budgetRepository = GetIt.I.get<BudgetRepository>();

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
                  return Card(
                    child: ListTile(
                      title: Text(_budgetRepository.budgets[index].name),
                      subtitle: Text(
                          _budgetRepository.budgets[index].amount.toString()),
                      onTap: () {
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
                                    padding: MediaQuery.of(context).viewInsets,
                                    duration: Duration(seconds: 1),
                                    child: BudgetSheetDesktop(
                                      budget: _budgetRepository.budgets[index],
                                    )),
                              );
                            });
                      },
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
