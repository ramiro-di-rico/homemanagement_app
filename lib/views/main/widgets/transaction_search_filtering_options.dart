import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/views/main/widgets/account_dialog_selection.dart';
import 'package:intl/intl.dart';

import '../../../models/account.dart';
import '../../../models/transaction.dart';
import '../../../services/repositories/account.repository.dart';
import '../../../services/transaction_paging_service.dart';

class TransactionSearchFilteringOptionsSheet extends StatefulWidget {

  @override
  _TransactionSearchFilteringOptionsSheetState createState() => _TransactionSearchFilteringOptionsSheetState();
}

class _TransactionSearchFilteringOptionsSheetState extends State<TransactionSearchFilteringOptionsSheet> {
  TransactionPagingService _transactionPagingService = GetIt.I<TransactionPagingService>();
  AccountRepository _accountRepository = GetIt.I<AccountRepository>();

  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _selectedAccountsTextEditingController = TextEditingController();

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
    _selectedAccountsTextEditingController.text = _transactionPagingService.selectedAccounts.map((account) => account.name).join(', ');

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
              crossAxisAlignment: CrossAxisAlignment.end,
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
                SizedBox(
                  width: 320,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                          context: this.context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AccountDialogSelection();
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: false,
                                style: TextStyle(color: Colors.white), // TODO use color based on theme
                                controller: _selectedAccountsTextEditingController,
                                decoration: InputDecoration(
                                  labelText: 'Select accounts',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(onPressed: () {
                              showDialog(
                                  context: this.context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AccountDialogSelection();
                                  });
                            }, icon: Icon(Icons.view_list))
                          ],
                        ),
                      ),
                    ),
                  ),
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

  void refresh() {
    setState(() {});
  }
}