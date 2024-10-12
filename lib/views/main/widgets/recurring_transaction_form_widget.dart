import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../models/recurring_transaction.dart';
import '../../../models/transaction.dart';
import '../../../services/endpoints/recurring_transaction_service.dart';

class RecurringTransactionForm extends StatefulWidget {
  final RecurringTransaction? transaction;

  RecurringTransactionForm({this.transaction});

  @override
  _RecurringTransactionFormState createState() => _RecurringTransactionFormState();
}

class _RecurringTransactionFormState extends State<RecurringTransactionForm> {
  late RecurringTransaction _recurringTransaction;

  @override
  void initState() {
    super.initState();
    _recurringTransaction = widget.transaction ?? RecurringTransaction.empty(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    final RecurringTransactionService _transactionService =
        GetIt.I.get<RecurringTransactionService>();

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(labelText: 'Name'),
              ),
            ),
            SizedBox(width: 20),
            SizedBox(
              width: 100,
              child: TextField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 20),
            SizedBox(
              width: 100,
              child: DropdownButton<String>(
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
                value: _recurringTransaction.recurrence ==
                    Recurrence.Monthly
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
                    _recurringTransaction.recurrence =
                    newValue == 'Monthly'
                        ? Recurrence.Monthly
                        : Recurrence.Annually;
                  });
                },
              ),
            ),
            SizedBox(width: 20),
            ElevatedButton(
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
          ],
        ),
      ),
    );
  }
}
