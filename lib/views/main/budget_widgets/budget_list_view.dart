import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../models/budget.dart';
import '../../../services/repositories/account.repository.dart';
import '../../../services/repositories/budget_repository.dart';
import '../../../services/repositories/category.repository.dart';
import '../../mixins/notifier_mixin.dart';
import '../widgets/account_select/account_select.dart';
import '../widgets/category_select/category_select.dart';
import 'budget_sheet_desktop.dart';
import '../../../extensions/number_format_extension.dart';

class BudgetListView extends StatefulWidget {
  @override
  State<BudgetListView> createState() => _BudgetListViewState();
}

class _BudgetListViewState extends State<BudgetListView> with NotifierMixin {
  BudgetRepository _budgetRepository = GetIt.I.get<BudgetRepository>();
  CategoryRepository _categoryRepository = GetIt.I.get<CategoryRepository>();
  AccountRepository _accountRepository = GetIt.I.get<AccountRepository>();

  int? selectedCategoryId;
  int? selectedAccountId;
  bool showFilters = false;
  BudgetState? selectedBudgetState;
  List<BudgetState> budgetStates = BudgetState.values;

  @override
  void initState() {
    super.initState();
    _budgetRepository.addListener(refreshState);
    selectedBudgetState = BudgetState.Active;
  }

  @override
  void dispose() {
    _budgetRepository.removeListener(refreshState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  children: [
                    Text('Budgets'),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showFilters = !showFilters;
                        });
                      },
                      child:
                          Text(showFilters ? 'Hide Filters' : 'Show Filters'),
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
                                    padding: MediaQuery.of(context).viewInsets,
                                    duration: Duration(seconds: 1),
                                    child: BudgetSheetDesktop()),
                              );
                            });
                      },
                      child: Text('Add Budget'),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: !showFilters
                  ? SizedBox.shrink()
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: CategorySelect(
                                      multipleSelection: false,
                                      selectedCategories:
                                          selectedCategoryId == null
                                              ? []
                                              : [
                                                  _categoryRepository.categories
                                                      .where((category) =>
                                                          category.id ==
                                                          selectedCategoryId)
                                                      .first
                                                ],
                                      onSelectedCategoriesChanged:
                                          (categories) {
                                        selectedCategoryId =
                                            categories.isNotEmpty
                                                ? categories.first.id
                                                : null;
                                        doFiltering();
                                      }),
                                ),
                                SizedBox(width: 20),
                                SizedBox(
                                  width: 200,
                                  child: AccountSelect(
                                      multipleSelection: false,
                                      selectedAccounts:
                                          selectedAccountId == null
                                              ? []
                                              : [
                                                  _accountRepository.accounts
                                                      .where((account) =>
                                                          account.id ==
                                                          selectedAccountId)
                                                      .first
                                                ],
                                      onSelectedAccountsChanged: (accounts) {
                                        selectedAccountId = accounts.isNotEmpty
                                            ? accounts.first.account.id
                                            : null;
                                        doFiltering();
                                      }),
                                ),
                                SizedBox(width: 20),
                                DropdownButton<BudgetState>(
                                  value: selectedBudgetState,
                                  onChanged: (BudgetState? newValue) {
                                    setState(() {
                                      selectedBudgetState = newValue;
                                      doFiltering();
                                    });
                                  },
                                  items: BudgetState.values
                                      .map<DropdownMenuItem<BudgetState>>(
                                          (BudgetState state) {
                                    return DropdownMenuItem<BudgetState>(
                                      value: state,
                                      child: Text(
                                          state.toString().split('.').last),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                          ],
                        ),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      width: 200, child: Text(budget.name)),
                                  Text(
                                      "Budget target: ${budget.amount.formatWithDot()}")
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                      width: 200,
                                      child: Text('Start: ${startDate}')),
                                  SizedBox(
                                      width: 200,
                                      child: Text('End: ${endDate}')),
                                  Spacer(),
                                  SizedBox(
                                    width: 150,
                                    child: Chip(
                                      color: WidgetStateProperty.resolveWith(
                                          (states) {
                                        switch (budget.state) {
                                          case BudgetState.New:
                                            return Colors.blue;
                                          case BudgetState.Active:
                                            return Colors.green;
                                          case BudgetState.Archived:
                                            return Colors.red;
                                          default:
                                            return Colors.grey;
                                        }
                                      }),
                                      label: Text(budget.state
                                          .toString()
                                          .split('.')
                                          .last),
                                    ),
                                  ),
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
                                  SizedBox(
                                    width: 150,
                                    child: Chip(
                                      label: Text(account?.name ?? 'N/A'),
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Open the budget sheet to create a copy of the current budget
                                      showModalBottomSheet<void>(
                                          context: context,
                                          constraints: BoxConstraints(
                                            maxHeight: 1000,
                                            maxWidth: 1200,
                                          ),
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          25.0))),
                                          builder: (context) {
                                            return SizedBox(
                                              height: 175,
                                              child: AnimatedPadding(
                                                  padding:
                                                      MediaQuery.of(context)
                                                          .viewInsets,
                                                  duration:
                                                      Duration(seconds: 1),
                                                  child: BudgetSheetDesktop(
                                                    budget:
                                                        BudgetModel.duplicate(
                                                            budget),
                                                  )),
                                            );
                                          });
                                    },
                                    child: Text('Copy'),
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
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          25.0))),
                                          builder: (context) {
                                            return SizedBox(
                                              height: 175,
                                              child: AnimatedPadding(
                                                  padding:
                                                      MediaQuery.of(context)
                                                          .viewInsets,
                                                  duration:
                                                      Duration(seconds: 1),
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
        ),
      ),
    );
  }

  void refreshState() {
    setState(() {});
  }

  void doFiltering() {
    _budgetRepository.filterBudgetsBy(
        categoryId: selectedCategoryId,
        accountId: selectedAccountId,
        state: selectedBudgetState);
  }
}
