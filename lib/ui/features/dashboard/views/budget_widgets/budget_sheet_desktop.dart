import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/ui/core/custom/formatters/localized_number_input_formatter.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:home_management_app/domain/models/budget.dart';
import 'package:home_management_app/domain/models/currency.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/budget_repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/ui/features/home/views/shared/account_select/account_select.dart';
import 'package:home_management_app/ui/features/home/views/shared/category_select/category_select.dart';

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
  String? _localeCode;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final localeCode = Localizations.localeOf(context).toString();
    if (_localeCode == localeCode) {
      return;
    }

    _localeCode = localeCode;
    _amountController.text = LocalizedNumberInputFormatterHelper.formatDouble(
      budget.amount,
      localeCode,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                  decoration: InputDecoration(labelText: localizations.budgetName),
                  controller: _nameController,
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 150,
                child: TextField(
                  decoration: InputDecoration(labelText: localizations.budgetAmount),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    LocalizedNumberInputFormatter(
                      locale: Localizations.localeOf(context).toString(),
                    ),
                  ],
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
                    label: Text(localizations.budgetStartDate),
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
                    label: Text(localizations.budgetEndDate),
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
                    final amount = LocalizedNumberInputFormatterHelper.parseDouble(
                      _amountController.text,
                      Localizations.localeOf(context).toString(),
                    );

                    if (amount == null) {
                      return;
                    }

                    budget.amount = amount;

                    if (isEditMode) {
                      _budgetRepository.updateBudget(budget);
                      Navigator.pop(context);
                      return;
                    }

                    _budgetRepository.addBudget(budget);

                    Navigator.pop(context);
                  },
                  child: Text(localizations.save),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
