import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/ui/core/custom/formatters/localized_number_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/recurring_transaction.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/recurring_transaction_repository.dart';
import 'account_select/account_select.dart';
import 'category_select/category_select.dart';

class RecurringTransactionForm extends StatefulWidget {
  final RecurringTransaction? transaction;

  RecurringTransactionForm({this.transaction});

  @override
  _RecurringTransactionFormState createState() =>
      _RecurringTransactionFormState();
}

class _RecurringTransactionFormState extends State<RecurringTransactionForm> {
  AccountRepository _accountRepository = GetIt.I<AccountRepository>();
  CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();
  final RecurringTransactionRepository _recurringTransactionRepository =
  GetIt.I.get<RecurringTransactionRepository>();

  late RecurringTransaction _recurringTransaction;
  final List<AccountModel> _selectedAccounts = [];
  final List<CategoryModel> _selectedCategories = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _localeCode;
  bool _syncingPriceText = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _recurringTransaction = widget.transaction ?? RecurringTransaction.empty();
    _nameController.text = _recurringTransaction.name;

    _priceController.addListener(onPriceChanged);
    _nameController.addListener(onNameChanged);

    if (_recurringTransaction.accountId != null) {
      _selectedAccounts.add(_accountRepository.accounts.firstWhere(
          (element) => element.id == _recurringTransaction.accountId));
    }

    if (_recurringTransaction.categoryId != null) {
      _selectedCategories.add(_categoryRepository.categories.firstWhere(
          (element) => element.id == _recurringTransaction.categoryId));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final localeCode = Localizations.localeOf(context).toString();
    if (_localeCode == localeCode) {
      return;
    }

    _localeCode = localeCode;

    if (_recurringTransaction.price != null) {
      _syncingPriceText = true;
      try {
        _priceController.text = LocalizedNumberInputFormatterHelper.formatDouble(
          _recurringTransaction.price!,
          localeCode,
        );
      } finally {
        _syncingPriceText = false;
      }
    }
  }

  @override
  void dispose() {
    _priceController.removeListener(onPriceChanged);
    _nameController.removeListener(onNameChanged);
    _priceController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Name'),
                    controller: _nameController,
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      LocalizedNumberInputFormatter(
                        locale: Localizations.localeOf(context).toString(),
                      ),
                    ],
                    controller: _priceController,
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 180,
                  child: DateTimeField(
                    //enabled: false,
                    decoration: InputDecoration(
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
                        _recurringTransaction.date = date;
                      });
                    },
                    resetIcon: Icon(Icons.clear),
                    initialValue: _recurringTransaction.date,
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 180,
                  child: DateTimeField(
                    //enabled: false,
                    decoration: InputDecoration(
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
                        _recurringTransaction.dueDate = date;
                      });
                    },
                    resetIcon: Icon(Icons.clear),
                    initialValue: _recurringTransaction.dueDate,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(children: [
              SizedBox(
                width: 200,
                child: AccountSelect(
                  selectedAccounts: _selectedAccounts,
                  multipleSelection: false,
                  onSelectedAccountsChanged: (accounts) {
                    _selectedAccounts.clear();
                    _selectedAccounts.addAll(accounts.map((e) => e.account));
                    _recurringTransaction.accountId = accounts.isNotEmpty
                        ? accounts.first.account.id
                        : null;
                  },
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: CategorySelect(
                  onSelectedCategoriesChanged: (categories) {
                    _selectedCategories.clear();
                    _selectedCategories.addAll(categories);
                    _recurringTransaction.categoryId = categories.first.id;
                  },
                  selectedCategories: _selectedCategories,
                  multipleSelection: false,
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 100,
                child: DropdownButton<String>(
                  underline: Container(),
                  value: _recurringTransaction.transactionType ==
                          TransactionType.Income
                      ? 'Income'
                      : 'Outcome',
                  items: ['Outcome', 'Income'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _recurringTransaction.transactionType =
                          newValue == 'Income'
                              ? TransactionType.Income
                              : TransactionType.Outcome;
                    });
                  },
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 100,
                child: DropdownButton<String>(
                  underline: Container(),
                  value: _recurringTransaction.recurrence == Recurrence.Monthly
                      ? 'Monthly'
                      : 'Annually',
                  items: ['Monthly', 'Annually'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _recurringTransaction.recurrence = newValue == 'Monthly'
                          ? Recurrence.Monthly
                          : Recurrence.Annually;
                    });
                  },
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                height: 60,
                width: 100,
                child: FilledButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    if (saving) return;

                    setState(() {
                      saving = true;
                    });
                    try {
                      if (widget.transaction == null) {
                        await _recurringTransactionRepository.add(_recurringTransaction);
                      } else {
                        await _recurringTransactionRepository.update(_recurringTransaction);
                      }
                    } on Exception {
                    }
                    setState(() {
                      saving = false;
                    });
                    Navigator.pop(context, true);
                  },
                  child: saving
                      ? CircularProgressIndicator()
                      : Text(widget.transaction == null ? 'Add' : 'Update'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void onPriceChanged() {
    if (_syncingPriceText) {
      return;
    }

    if (_priceController.text.isEmpty) {
      _recurringTransaction.price = null;
    } else {
      final price = LocalizedNumberInputFormatterHelper.parseDouble(
        _priceController.text,
        Localizations.localeOf(context).toString(),
      );

      if (price == null) {
        return;
      }

      _recurringTransaction.price = price;
    }
  }

  void onNameChanged() {
    _recurringTransaction.name = _nameController.text;
  }
}
