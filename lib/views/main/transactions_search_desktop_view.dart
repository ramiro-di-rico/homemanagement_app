import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:home_management_app/extensions/datehelper.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';
import '../../services/endpoints/transaction.service.dart';
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
  bool _filtering = false;
  List<TransactionModel> _transactions = List.empty(growable: true);

  TransactionService _transactionService = GetIt.I<TransactionService>();

  TextEditingController _nameTextEditingController = TextEditingController();
  DateTime? _startDate = null;
  DateTime? _endDate = null;

  int _amountOfFilters = 0;
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Search transactions'),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _filtering = false;
                    _transactions.clear();
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
              icon: Icon(_filtering
                  ? _filteringNumber.elementAt(_amountOfFilters)
                  : Icons.filter_alt_outlined),
              tooltip: 'Filter transactions',
            )
          ],
        ),
        body: Container(
          child: !_filtering
              ? Center(child: Text('Filtering transactions...'))
              : GroupedListView<TransactionModel, DateTime>(
                  order: GroupedListOrder.DESC,
                  controller: scrollController,
                  physics: ScrollPhysics(),
                  elements: _transactions,
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
        ));
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
                        // create a category dropdown component that somehow output the selected item
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              doFiltering();
                              Navigator.pop(context);
                            });
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
                      ],
                    ),
                  ],
                )),
          );
        });
  }

  Future doFiltering() async {
    var result = await _transactionService.filter(
        1, 10, null, _nameTextEditingController.text, _startDate, _endDate);

    calculateAmountOfFilters();
    setState(() {
      _filtering = true;
      _transactions = result;
    });
  }

  void calculateAmountOfFilters() {
    _amountOfFilters = 0;
    if (_nameTextEditingController.text.isNotEmpty) {
      _amountOfFilters++;
    }
    if (_startDate != null) {
      _amountOfFilters++;
    }
    if (_endDate != null) {
      _amountOfFilters++;
    }
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
