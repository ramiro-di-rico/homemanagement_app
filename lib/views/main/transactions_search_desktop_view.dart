import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:home_management_app/extensions/datehelper.dart';
import 'package:home_management_app/views/main/widgets/transaction_search_filtering_options.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';
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

  TransactionPagingService _transactionPagingService = GetIt.I<TransactionPagingService>();

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
                  _transactionPagingService.clearFilters();
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
            ? Center(child: Text('Select a filter to display transactions'))
            : _transactionPagingService.loading
            ? Center(child: CircularProgressIndicator())
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
          return TransactionSearchFilteringOptionsSheet();
        });
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
