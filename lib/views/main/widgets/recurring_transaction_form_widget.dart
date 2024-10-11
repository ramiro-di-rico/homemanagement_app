import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../models/recurring_transaction.dart';
import '../../../services/endpoints/recurring_transaction_service.dart';

class RecurringTransactionForm extends StatefulWidget {
  final RecurringTransaction? transaction;

  RecurringTransactionForm({this.transaction});

  @override
  _RecurringTransactionFormState createState() =>
      _RecurringTransactionFormState();
}

class _RecurringTransactionFormState extends State<RecurringTransactionForm> {
  final RecurringTransactionService _transactionService =  GetIt.I.get<RecurringTransactionService>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null
            ? 'Add Transaction'
            : 'Edit Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.transaction!.name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  widget.transaction!.name = value!;
                },
              ),
              TextFormField(
                initialValue: widget.transaction!.price.toString(),
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  widget.transaction!.price = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (widget.transaction == null) {
                      //await widget.transactionService.create(RecurringTransaction(name: _name, amount: _price));
                    } else {
                      await _transactionService
                          .update(widget.transaction!);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Recurring transaction saved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                },
                child: Text(widget.transaction == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
