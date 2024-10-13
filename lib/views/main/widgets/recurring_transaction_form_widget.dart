import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
import '../../../models/recurring_transaction.dart';
import '../../../models/transaction.dart';
import '../../../services/endpoints/recurring_transaction_service.dart';
import '../../../services/repositories/account.repository.dart';
import '../../../services/repositories/category.repository.dart';
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
  late RecurringTransaction _recurringTransaction;
  final List<AccountModel> _selectedAccounts = [];
  final List<CategoryModel> _selectedCategories = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recurringTransaction =
        widget.transaction ?? RecurringTransaction.empty(0, 0);
    _nameController.text = _recurringTransaction.name;

    if (_recurringTransaction.price != null)
      _priceController.text = _recurringTransaction.price.toString();

    if (_recurringTransaction.accountId != null) {
      _selectedAccounts.add(_accountRepository.accounts
          .firstWhere((element) => element.id == _recurringTransaction.accountId));
    }

    if (_recurringTransaction.categoryId != null) {
      _selectedCategories.add(_categoryRepository.categories
          .firstWhere((element) => element.id == _recurringTransaction.categoryId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final RecurringTransactionService _transactionService =
        GetIt.I.get<RecurringTransactionService>();

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
                    keyboardType: TextInputType.number,
                    controller: _priceController,
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 180,
                  child: DateTimeField(
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
                    _recurringTransaction.accountId = accounts.first.account.id;
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
                  value:
                  _recurringTransaction.recurrence == Recurrence.Monthly
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
                    if (widget.transaction == null) {
                      //await _transactionService.create();
                    } else {
                      await _transactionService.update(widget.transaction!);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Recurring transaction saved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  },
                  child: Text(widget.transaction == null ? 'Add' : 'Update'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
