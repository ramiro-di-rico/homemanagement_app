import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../models/recurring_transaction.dart';
import '../../../models/transaction.dart';
import '../../../services/endpoints/recurring_transaction_service.dart';
import '../../../services/repositories/account.repository.dart';
import '../../../services/repositories/category.repository.dart';
import 'recurring_transaction_form_widget.dart';

class RecurringTransactionList extends StatefulWidget {
  @override
  _RecurringTransactionListState createState() =>
      _RecurringTransactionListState();
}

class _RecurringTransactionListState extends State<RecurringTransactionList> {
  final RecurringTransactionService _recurringTransactionService =
      GetIt.I.get<RecurringTransactionService>();
  final AccountRepository _accountRepository = GetIt.I.get<AccountRepository>();
  final CategoryRepository _categoryRepository = GetIt.I.get<CategoryRepository>();
  late Future<List<RecurringTransaction>> _recurringTransactions;

  @override
  void initState() {
    super.initState();
    _recurringTransactions = _recurringTransactionService.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecurringTransaction>>(
      future: _recurringTransactions,
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
              var recurringTransaction = snapshot.data![index];
              var account = _accountRepository.accounts.where(
                  (account) => account.id == recurringTransaction.accountId).firstOrNull;
              var category = _categoryRepository.categories.where(
                  (category) => category.id == recurringTransaction.categoryId).firstOrNull;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Text(recurringTransaction.name),
                      Spacer(),
                      Chip(
                          label: Text(account == null ? 'Account not set' : account.name)
                      ),
                      SizedBox(width: 10),
                      Chip(
                          label: Text(category == null ? 'Category not set' : category.name)
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    color: Colors.redAccent,
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _recurringTransactionService.delete(recurringTransaction.id);
                      setState(() {
                        _recurringTransactions = _recurringTransactionService.getAll();
                      });
                    },
                  ),
                  subtitle: Row(
                    children: [
                      recurringTransaction.price == null
                          ? Text('Price not set')
                          : Text(
                          recurringTransaction.price.toString(),
                          style: TextStyle(
                            color: recurringTransaction.transactionType ==
                                TransactionType.Income
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                      ),
                      Spacer(),
                      Text(
                        recurringTransaction.recurrence ==
                            Recurrence.Monthly
                            ? 'Monthly'
                            : 'Annually',
                      ),
                    ],
                  ),
                  onTap: () async {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      constraints: BoxConstraints(
                        maxHeight: 500,
                        maxWidth: 1200,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25.0))),
                      builder: (context) {
                        return SizedBox(
                            height: 200,
                            width: 900,
                            child: AnimatedPadding(
                                padding: MediaQuery.of(context).viewInsets,
                                duration: Duration(seconds: 1),
                                child: RecurringTransactionForm(
                                    transaction: recurringTransaction)));
                      },
                    );
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
