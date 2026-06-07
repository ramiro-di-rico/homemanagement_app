import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/views/main/widgets/currency_select/currency_select.dart';
import 'package:intl/intl.dart';

import '../../../models/transaction.dart';
import '../../../services/transaction_paging_service.dart';
import 'account_select/account_select.dart';
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
    final localizations = AppLocalizations.of(context)!;
    final isCompact = MediaQuery.of(context).size.width < 700;
    _selectedCategoriesTextEditingController.text = _transactionPagingService
        .selectedCategories
        .map((category) => category.name)
        .join(', ');

    return SafeArea(
      child: AnimatedPadding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameTextEditingController,
                  decoration: InputDecoration(
                    labelText: localizations.searchTransactionByName,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                if (isCompact)
                  Column(
                    children: [
                      DateTimeField(
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
                      SizedBox(height: 12),
                      DateTimeField(
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
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _transactionPagingService.transactionType == null
                            ? localizations.selectOption
                            : _transactionPagingService.transactionType ==
                                    TransactionType.Income
                                ? localizations.income
                                : localizations.outcome,
                        items: [
                          localizations.selectOption,
                          localizations.outcome,
                          localizations.income,
                        ]
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            if (newValue == localizations.selectOption) {
                              _transactionPagingService.transactionType = null;
                              return;
                            }
                            _transactionPagingService.transactionType =
                                newValue == localizations.income
                                    ? TransactionType.Income
                                    : TransactionType.Outcome;
                          });
                        },
                      ),
                      SizedBox(height: 12),
                      CurrencySelect(
                        selectedCurrencies:
                            _transactionPagingService.selectedCurrencies,
                        multipleSelection: false,
                        onSelectedCurrenciesChanged: (selectedCurrencies) {
                          _transactionPagingService.selectedCurrencies.clear();
                          _transactionPagingService.selectedCurrencies
                              .addAll(selectedCurrencies);
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 12),
                      AccountSelect(
                          selectedAccounts:
                              _transactionPagingService.selectedAccounts,
                          multipleSelection: true,
                          onSelectedAccountsChanged: (selectedAccounts) {
                            _transactionPagingService.selectedAccounts.clear();
                            _transactionPagingService.selectedAccounts.addAll(
                                selectedAccounts.map((e) => e.account));
                            setState(() {});
                          }),
                      SizedBox(height: 12),
                      CategorySelect(
                        selectedCategories:
                            _transactionPagingService.selectedCategories,
                        multipleSelection: true,
                        onSelectedCategoriesChanged: (selectedCategories) {
                          _transactionPagingService.selectedCategories.clear();
                          _transactionPagingService.selectedCategories
                              .addAll(selectedCategories);
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
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
                            child: Text(localizations.filter)),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
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
                          Expanded(
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
                            width: 140,
                            child: DropdownButton<String>(
                              value: _transactionPagingService.transactionType ==
                                      null
                                  ? localizations.selectOption
                                  : _transactionPagingService
                                              .transactionType ==
                                          TransactionType.Income
                                      ? localizations.income
                                      : localizations.outcome,
                              items: [
                                localizations.selectOption,
                                localizations.outcome,
                                localizations.income,
                              ]
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  if (newValue == localizations.selectOption) {
                                    _transactionPagingService.transactionType =
                                        null;
                                    return;
                                  }
                                  _transactionPagingService.transactionType =
                                      newValue == localizations.income
                                          ? TransactionType.Income
                                          : TransactionType.Outcome;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 20),
                          SizedBox(
                            width: 140,
                            child: CurrencySelect(
                              selectedCurrencies:
                                  _transactionPagingService.selectedCurrencies,
                              multipleSelection: false,
                              onSelectedCurrenciesChanged: (selectedCurrencies) {
                                _transactionPagingService.selectedCurrencies
                                    .clear();
                                _transactionPagingService.selectedCurrencies
                                    .addAll(selectedCurrencies);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AccountSelect(
                                selectedAccounts:
                                    _transactionPagingService.selectedAccounts,
                                multipleSelection: true,
                                onSelectedAccountsChanged: (selectedAccounts) {
                                  _transactionPagingService.selectedAccounts
                                      .clear();
                                  _transactionPagingService.selectedAccounts
                                      .addAll(selectedAccounts
                                          .map((e) => e.account));
                                  setState(() {});
                                }),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: CategorySelect(
                              selectedCategories:
                                  _transactionPagingService.selectedCategories,
                              multipleSelection: true,
                              onSelectedCategoriesChanged: (selectedCategories) {
                                _transactionPagingService.selectedCategories
                                    .clear();
                                _transactionPagingService.selectedCategories
                                    .addAll(selectedCategories);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: 150,
                        height: 60,
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
                            child: Text(localizations.filter)),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future doFiltering() async {
    _transactionPagingService.name = _nameTextEditingController.text;
    await _transactionPagingService.performSearch(resetPaging: true);
  }

  void refresh() {
    setState(() {});
  }
}
