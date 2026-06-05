import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _recurringTransactionRepository.addListener(refresh);
    load();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _recurringTransactionRepository.removeListener(refresh);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleRecurring = _query.trim().isEmpty
        ? _recurringTransactionRepository.recurringTransactions
        : _recurringTransactionRepository.recurringTransactions
            .where((rt) => rt.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    return _recurringTransactionRepository.loading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.recurringTransactions,
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: AppLocalizations.of(context)!.searchRecurringTransactions,
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.addRecurringTransaction,
                        icon: Icon(Icons.add),
                        onPressed: () {
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
                                      child: RecurringTransactionForm()));
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  height: 330,
                  child: visibleRecurring.isEmpty
                      ? Center(child: Text(AppLocalizations.of(context)!.noRecurringTransactionsFound))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: visibleRecurring.length,
                          itemBuilder: (context, index) {
                            var recurringTransaction = visibleRecurring[index];
                      var account = _accountRepository.accounts
                          .where((account) =>
                              account.id == recurringTransaction.accountId)
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
                                      ? AppLocalizations.of(context)!.accountNotSet
                                      : account.name)),
                              SizedBox(width: 10),
                              Chip(
                                  label: Text(category == null
                                      ? AppLocalizations.of(context)!.categoryNotSet
                                      : category.name)),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (String result) async {
                              if (result == 'delete') {
                                await _recurringTransactionRepository
                                    .delete(recurringTransaction);
                              } else if (result == 'create_transaction') {
                                var transaction =
                                    TransactionModel.fromRecurring(
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
                                        padding:
                                            MediaQuery.of(context).viewInsets,
                                        duration: Duration(seconds: 1),
                                        child: AddTransactionSheetDesktop(
                                            account!,
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
                              PopupMenuItem<String>(
                                value: 'create_transaction',
                                child: Row(
                                  children: [
                                    Icon(Icons.add, color: Colors.greenAccent),
                                    SizedBox(width: 10),
                                    Text(AppLocalizations.of(context)!.createTransaction,
                                        style: TextStyle(
                                            color: Colors.greenAccent)),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.redAccent),
                                    SizedBox(width: 10),
                                    Text(AppLocalizations.of(context)!.delete,
                                        style:
                                            TextStyle(color: Colors.redAccent)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              recurringTransaction.price == null
                                  ? Text(AppLocalizations.of(context)!.priceNotSet)
                                  : Text(
                                      recurringTransaction.price.toString(),
                                      style: TextStyle(
                                        color: recurringTransaction
                                                    .transactionType ==
                                                TransactionType.Income
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                      ),
                                    ),
                              Spacer(),
                              Text(
                                recurringTransaction.recurrence ==
                                        Recurrence.Monthly
                                    ? AppLocalizations.of(context)!.monthly
                                    : AppLocalizations.of(context)!.annually,
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
                                        padding:
                                            MediaQuery.of(context).viewInsets,
                                        duration: Duration(seconds: 1),
                                        child: RecurringTransactionForm(
                                            transaction:
                                                recurringTransaction)));
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
  }

  void refresh() {
    setState(() {});
  }

  Future load() async {
    await _recurringTransactionRepository.load();
  }
}
