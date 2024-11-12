import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../models/budget.dart';
import '../../../models/currency.dart';
import '../../../services/repositories/account.repository.dart';
import '../../../services/repositories/budget_repository.dart';
import '../../../services/repositories/category.repository.dart';
import '../widgets/account_select/account_select.dart';
import '../widgets/category_select/category_select.dart';

class BudgetSheetDesktop extends StatefulWidget {
  final BudgetModel? budget;

  BudgetSheetDesktop({this.budget});

  @override
  State<BudgetSheetDesktop> createState() => _BudgetSheetDesktopState();
}

class _BudgetSheetDesktopState extends State<BudgetSheetDesktop> {
  BudgetRepository _budgetRepository = GetIt.I.get<BudgetRepository>();
  AccountRepository _accountRepository = GetIt.I.get<AccountRepository>();
  CategoryRepository _categoryRepository = GetIt.I.get<CategoryRepository>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  List<CurrencyModel> currencies = [];
  bool isEditMode = false;
  bool isDuplicate = false;
  late BudgetModel budget;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.budget != null && widget.budget?.id != 0;
    isDuplicate = widget.budget?.id == 0;
    budget = isEditMode
        ? BudgetModel.copy(widget.budget!)
        : isDuplicate
          ? BudgetModel.duplicate(widget.budget!)
          : BudgetModel.empty();

    _nameController.text = budget.name;
    _amountController.text = budget.amount.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 15),
          Row(
            children: [
              SizedBox(width: 50),
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                  controller: _nameController,
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 150,
                child: TextField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  controller: _amountController,
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: AccountSelect(
                  multipleSelection: false,
                  selectedAccounts: budget.accountId == null
                      ? []
                      : [
                          _accountRepository.accounts
                              .where(
                                  (account) => account.id == budget.accountId)
                              .first
                        ],
                  onSelectedAccountsChanged: (accounts) {
                    if (accounts.isNotEmpty) {
                      budget.accountId = accounts.first.account.id;
                      return;
                    }

                    budget.accountId = null;
                  },
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: CategorySelect(
                    multipleSelection: false,
                    selectedCategories: [
                      budget.categoryId == null
                          ? _categoryRepository.categories.first
                          : _categoryRepository.categories
                              .where((category) =>
                                  category.id == budget.categoryId)
                              .first
                    ],
                    onSelectedCategoriesChanged: (categories) {
                      if (categories.isNotEmpty) {
                        budget.categoryId = categories.first.id;
                        return;
                      }

                      budget.categoryId = null;
                    }),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            children: [
              SizedBox(width: 20),
              SizedBox(
                width: 180,
                child: DateTimeField(
                  decoration: InputDecoration(
                    label: Text('Start Date'),
                    icon: Icon(Icons.date_range),
                  ),
                  format: DateFormat("dd MMM yyyy"),
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                  onChanged: (date) {
                    setState(() {
                      budget.startDate = date;
                    });
                  },
                  resetIcon: Icon(Icons.clear),
                  initialValue: budget.startDate,
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 180,
                child: DateTimeField(
                  decoration: InputDecoration(
                    label: Text('End Date'),
                    icon: Icon(Icons.date_range),
                  ),
                  format: DateFormat("dd MMM yyyy"),
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                  onChanged: (date) {
                    setState(() {
                      budget.endDate = date;
                    });
                  },
                  resetIcon: Icon(Icons.clear),
                  initialValue: budget.endDate,
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 100,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    budget.name = _nameController.text;
                    budget.amount = double.parse(_amountController.text);

                    if (isEditMode) {
                      _budgetRepository.updateBudget(budget);
                    }

                    _budgetRepository.addBudget(budget);

                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
