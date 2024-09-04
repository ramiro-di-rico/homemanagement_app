import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:home_management_app/extensions/datehelper.dart';
import 'package:intl/intl.dart';

import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/transaction_paging_service.dart';
import '../accounts/account-details-behaviors/account-list-scrolling-behavior.dart';

class TransactionsSearchDesktopView extends StatefulWidget {
  static const String id = 'transactions_search_desktop_view';

  TransactionsSearchDesktopView();

  @override
  State<TransactionsSearchDesktopView> createState() =>
      _TransactionsSearchDesktopViewState();
}

class _TransactionsSearchDesktopViewState
    extends State<TransactionsSearchDesktopView>
    with AccountListScrollingBehavior {

  AccountRepository _accountRepository = GetIt.I<AccountRepository>();
  TransactionPagingService _transactionPagingService = GetIt.I<TransactionPagingService>();

  TextEditingController _nameTextEditingController = TextEditingController();
  DateTime? _startDate = null;
  DateTime? _endDate = null;
  List<DropdownAccountSelection> _accountsSelection = List.empty(growable: true);

  List<IconData> _filteringNumber = [
    Icons.filter_alt,
    Icons.filter_1,
    Icons.filter_2,
    Icons.filter_3,
    Icons.filter_4,
    Icons.filter_5,
    Icons.filter_6,
    Icons.filter_7,
    Icons.filter_8,
    Icons.filter_9,
    Icons.filter_9_plus,
  ];

  @override
  void initState() {
    super.initState();
    _accountsSelection = _accountRepository.accounts.map((e) => DropdownAccountSelection(e, false)).toList();
    _transactionPagingService.addListener(refreshList);
  }

  void refreshList() {
    setState(() {});
  }

  @override
  void dispose() {
    _transactionPagingService.removeListener(refreshList);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search transactions'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _transactionPagingService.filtering = false;
                  _transactionPagingService.transactions.clear();
                  _nameTextEditingController.clear();
                  _startDate = null;
                  _endDate = null;
                });
              },
              icon: Icon(Icons.filter_alt_off),
              tooltip: 'Clear filters'),
          IconButton(
            onPressed: () {
              displayFilteringOptions();
            },
            icon: Icon(_transactionPagingService.filtering
                ? _filteringNumber.elementAt(_transactionPagingService.selectedFilters)
                : Icons.filter_alt_outlined),
            tooltip: 'Filter transactions',
          )
        ],
      ),
      body: Container(
        child: !_transactionPagingService.filtering
            ? Center(child: Text('Filtering transactions...'))
            : GroupedListView<TransactionModel, DateTime>(
                order: GroupedListOrder.DESC,
                controller: scrollController,
                physics: ScrollPhysics(),
                elements: _transactionPagingService.transactions,
                groupBy: (element) => element.date.toMidnight(),
                groupSeparatorBuilder: (element) {
                  return Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(DateFormat.MMMd().format(element)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemBuilder: (context, transaction) {
                  return Card(
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(transaction.name),
                              Text(transaction.price.toString()),
                            ],
                          ),
                        ),
                        Text(transaction.price.toString()),
                        SizedBox(width: 20),
                      ],
                    ),
                  );
                }),
      ),
    );
  }

  void displayFilteringOptions() {
    showModalBottomSheet(
        context: context,
        constraints: BoxConstraints(
          maxHeight: 1000,
          maxWidth: 1000,
        ),
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        builder: (context) {
          return SizedBox(
            height: 200,
            child: AnimatedPadding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
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
                              _startDate = date;
                              setState(() {});
                            },
                            resetIcon: Icon(Icons.clear),
                            initialValue: _startDate,
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
                              _endDate = date;
                              setState(() {});
                            },
                            resetIcon: Icon(Icons.clear),
                            initialValue: _endDate,
                          ),
                        ),
                        SizedBox(width: 20),
                        DropdownButton(
                          hint: Text('Select an account'),
                          items: _accountsSelection
                              .map(
                                (e) => DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      e.checkbox,
                                      Text(e.account.name),
                                    ],
                                  ),
                                  value: e.account.id,
                                ),
                              )
                              .toList(),
                          onChanged: (accountId) {
                            print(accountId);
                          },
                        )
                      ],
                    ),
                  ],
                )),
          );
        });
  }

  Future doFiltering() async {
    await _transactionPagingService.performSearch(TransactionSearchOptions(
        _nameTextEditingController.text, _startDate, _endDate, _accountsSelection));
  }

  @override
  void load() {
    // TODO: implement load
  }

  @override
  void nextPage() {
    // TODO: implement nextPage
  }
}

class DropdownAccountSelection{
  final AccountModel account;
  bool isSelected;
  late Checkbox checkbox;

  DropdownAccountSelection(this.account, this.isSelected){
    checkbox = Checkbox(
        value: isSelected,
        onChanged: (value) {
      isSelected = value == true;
    });
  }
}
