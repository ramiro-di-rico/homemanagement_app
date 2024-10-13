import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../models/transaction.dart';
import '../../../services/transaction_paging_service.dart';
import 'account_select/account_select.dart';
import 'category_select/category_dialog_selection.dart';
import 'category_select/category_select.dart';

class TransactionSearchFilteringOptionsSheet extends StatefulWidget {
  @override
  _TransactionSearchFilteringOptionsSheetState createState() =>
      _TransactionSearchFilteringOptionsSheetState();
}

class _TransactionSearchFilteringOptionsSheetState
    extends State<TransactionSearchFilteringOptionsSheet> {
  TransactionPagingService _transactionPagingService =
      GetIt.I<TransactionPagingService>();

  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _selectedCategoriesTextEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameTextEditingController.text = _transactionPagingService.name ?? '';
    _transactionPagingService.addListener(refresh);
  }

  @override
  void dispose() {
    _transactionPagingService.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _selectedCategoriesTextEditingController.text = _transactionPagingService
        .selectedCategories
        .map((category) => category.name)
        .join(', ');

    return SizedBox(
      height: 250,
      child: AnimatedPadding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: _nameTextEditingController,
                    decoration: InputDecoration(
                      labelText: 'Search transaction by name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
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
                        _transactionPagingService.startDate = date;
                      });
                    },
                    resetIcon: Icon(Icons.clear),
                    initialValue: _transactionPagingService.startDate,
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
                        _transactionPagingService.endDate = date;
                      });
                    },
                    resetIcon: Icon(Icons.clear),
                    initialValue: _transactionPagingService.endDate,
                  ),
                ),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: _transactionPagingService.transactionType == null
                      ? 'Select'
                      : _transactionPagingService.transactionType ==
                              TransactionType.Income
                          ? 'Income'
                          : 'Outcome',
                  items: ['Select', 'Outcome', 'Income'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue == 'Select') {
                        _transactionPagingService.transactionType = null;
                        return;
                      }
                      _transactionPagingService.transactionType =
                          newValue == 'Income'
                              ? TransactionType.Income
                              : TransactionType.Outcome;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 20),
                SizedBox(width: 320,
                  child: AccountSelect(
                      selectedAccounts: _transactionPagingService.selectedAccounts,
                      multipleSelection: true,
                      onSelectedAccountsChanged: (selectedAccounts){
                        _transactionPagingService.selectedAccounts.clear();
                        _transactionPagingService.selectedAccounts.addAll(selectedAccounts.map((e) => e.account));
                        setState(() {

                        });
                      }),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 320,
                  child: CategorySelect(
                    selectedCategories: _transactionPagingService.selectedCategories,
                    multipleSelection: true,
                    onSelectedCategoriesChanged: (selectedCategories) {
                      _transactionPagingService.selectedCategories.clear();
                      _transactionPagingService.selectedCategories.addAll(selectedCategories);
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  height: 60,
                  width: 150,
                  child: FilledButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: () {
                        doFiltering();
                        Navigator.pop(context);
                      },
                      child: Text('Filter')),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future doFiltering() async {
    _transactionPagingService.name = _nameTextEditingController.text;
    await _transactionPagingService.performSearch();
  }

  void refresh() {
    setState(() {});
  }
}
