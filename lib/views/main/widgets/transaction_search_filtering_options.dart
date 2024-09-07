import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../models/account.dart';
import '../../../models/transaction.dart';
import '../../../services/repositories/account.repository.dart';
import '../../../services/transaction_paging_service.dart';

class TransactionSearchFilteringOptionsWidget extends StatefulWidget {

  @override
  _TransactionSearchFilteringOptionsWidgetState createState() => _TransactionSearchFilteringOptionsWidgetState();
}

class _TransactionSearchFilteringOptionsWidgetState extends State<TransactionSearchFilteringOptionsWidget> {
  TransactionPagingService _transactionPagingService = GetIt.I<TransactionPagingService>();
  AccountRepository _accountRepository = GetIt.I<AccountRepository>();

  TextEditingController _nameTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _transactionPagingService.accountsSelection = _accountRepository.accounts.map((e) => DropdownAccountSelection(e, false)).toList();
    _nameTextEditingController.text = _transactionPagingService.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    doFiltering();
                    Navigator.pop(context);
                  },
                  child: Text('Filter'),
                ),
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
                DropdownButton(
                  hint: Text('Select an account'),
                  items: _transactionPagingService.accountsSelection
                      .map(
                        (e) => DropdownMenuItem(
                      child: Text(e.account.name, style: TextStyle(backgroundColor: e.isSelected ? Colors.blue : Colors.transparent)),
                      value: e.account.id,
                    ),
                  ).toList(),
                  onChanged: (accountId) {
                    setState(() {
                      _transactionPagingService.accountsSelection.forEach((element) {
                        element.isSelected = element.account.id == accountId;
                      });
                    });
                    showDialog(
                        context: this.context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('TODO modal for selecting multiple accounts'),
                            actions: [
                              TextButton(
                                child: Text('ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: _transactionPagingService.transactionType == null
                      ? 'Select'
                      : _transactionPagingService.transactionType == TransactionType.Income ? 'Income' : 'Outcome',
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
                      _transactionPagingService.transactionType = newValue == 'Income' ? TransactionType.Income : TransactionType.Outcome;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future doFiltering() async {
    _transactionPagingService.name = _nameTextEditingController.text;
    await _transactionPagingService.performSearch();
  }
}

class DropdownAccountSelection{
  final AccountModel account;
  bool isSelected;
  late Checkbox checkbox;

  DropdownAccountSelection(this.account, this.isSelected);
}