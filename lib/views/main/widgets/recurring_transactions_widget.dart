import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../models/recurring_transaction.dart';
import '../../../services/endpoints/recurring_transaction_service.dart';
import 'recurring_transaction_form_widget.dart';

class RecurringTransactionList extends StatefulWidget {
  @override
  _RecurringTransactionListState createState() =>
      _RecurringTransactionListState();
}

class _RecurringTransactionListState extends State<RecurringTransactionList> {
  final RecurringTransactionService _transactionService =  GetIt.I.get<RecurringTransactionService>();
  late Future<List<RecurringTransaction>> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = _transactionService.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecurringTransaction>>(
      future: _transactions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No recurring transactions found.'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var transaction = snapshot.data![index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(transaction.name),
                  subtitle: transaction.price == null ? Text('Price not set') : Text(transaction.price.toString()),
                  onTap: () async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecurringTransactionForm(
                              transaction: transaction)),
                    );
                    if (result == true) {
                      setState(() {
                        _transactions = _transactionService.getAll();
                      });
                    }
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
