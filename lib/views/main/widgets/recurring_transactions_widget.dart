import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../models/recurring_transaction.dart';
import '../../../models/transaction.dart';
import '../../../services/repositories/account.repository.dart';
import '../../../services/repositories/category.repository.dart';
import '../../../services/repositories/recurring_transaction_repository.dart';
import '../../accounts/widgets/add_transaction_sheet_desktop.dart';
import '../../mixins/notifier_mixin.dart';
import 'recurring_transaction_form_widget.dart';

class RecurringTransactionList extends StatefulWidget {
  @override
  _RecurringTransactionListState createState() =>
      _RecurringTransactionListState();
}

class _RecurringTransactionListState extends State<RecurringTransactionList>
    with NotifierMixin {
  final RecurringTransactionRepository _recurringTransactionRepository =
      GetIt.I.get<RecurringTransactionRepository>();
  final AccountRepository _accountRepository = GetIt.I.get<AccountRepository>();
  final CategoryRepository _categoryRepository =
      GetIt.I.get<CategoryRepository>();

  @override
  void initState() {
    super.initState();
    _recurringTransactionRepository.addListener(refresh);
    load();
  }

  @override
  void dispose() {
    _recurringTransactionRepository.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _recurringTransactionRepository.loading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            shrinkWrap: true,
            itemCount:
                _recurringTransactionRepository.recurringTransactions.length,
            itemBuilder: (context, index) {
              var recurringTransaction =
                  _recurringTransactionRepository.recurringTransactions[index];
              var account = _accountRepository.accounts
                  .where(
                      (account) => account.id == recurringTransaction.accountId)
                  .firstOrNull;
              var category = _categoryRepository.categories
                  .where((category) =>
                      category.id == recurringTransaction.categoryId)
                  .firstOrNull;
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
                          label: Text(account == null
                              ? 'Account not set'
                              : account.name)),
                      SizedBox(width: 10),
                      Chip(
                          label: Text(category == null
                              ? 'Category not set'
                              : category.name)),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String result) async {
                      if (result == 'delete') {
                        await _recurringTransactionRepository
                            .delete(recurringTransaction);
                      } else if (result == 'create_transaction') {
                        var transaction = TransactionModel.fromRecurring(
                            recurringTransaction);
                        var account = _accountRepository.accounts
                            .where((account) =>
                                account.id == transaction.accountId)
                            .firstOrNull;
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
                              height: 100,
                              child: AnimatedPadding(
                                padding: MediaQuery.of(context).viewInsets,
                                duration: Duration(seconds: 1),
                                child: AddTransactionSheetDesktop(account!,
                                    transactionModel: transaction,
                                    fromRecurring: true),
                              ),
                            );
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'create_transaction',
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.greenAccent),
                            SizedBox(width: 10),
                            Text('Create Transaction',
                                style: TextStyle(color: Colors.greenAccent)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text('Delete',
                                style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
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
                        recurringTransaction.recurrence == Recurrence.Monthly
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

  void refresh() {
    setState(() {});
  }

  Future load() async {
    await _recurringTransactionRepository.load();
  }
}
