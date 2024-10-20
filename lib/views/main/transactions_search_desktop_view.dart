import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:home_management_app/extensions/datehelper.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';
import '../../services/infra/platform/platform_context.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/transaction_paging_service.dart';
import '../accounts/account-details-behaviors/account-list-scrolling-behavior.dart';
import 'widgets/transaction_search_filtering_options.dart';

class TransactionsSearchDesktopView extends StatefulWidget {
  static const String fullPath = '/home_screen/transactions_search_desktop_view';
  static const String path = '/transactions_search_desktop_view';

  TransactionsSearchDesktopView();

  @override
  State<TransactionsSearchDesktopView> createState() =>
      _TransactionsSearchDesktopViewState();
}

class _TransactionsSearchDesktopViewState
    extends State<TransactionsSearchDesktopView>
    with AccountListScrollingBehavior {
  TransactionPagingService _transactionPagingService =
      GetIt.I<TransactionPagingService>();
  AccountRepository _accountRepository = GetIt.I<AccountRepository>();
  PlatformContext _platform = GetIt.instance<PlatformContext>();

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
          DropdownButton<int>(
            value: _transactionPagingService.pageSize,
            icon: Icon(Icons.arrow_downward),
            onChanged: !_transactionPagingService.filtering
                ? null
                : (int? pageSize) {
                    setState(() {
                      _transactionPagingService.pageSize = pageSize!;
                      _transactionPagingService.performSearch();
                    });
                  },
            items:
                [10, 20, 30, 50, 100].map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
          IconButton(
              onPressed: !_transactionPagingService.filtering
                  ? null
                  : _platform.isDownloadEnabled()
                      ? () {
                          var csvContent =
                              _transactionPagingService.generateCsvContent();
                          _platform.saveFile('transactions', 'csv', csvContent);
                        }
                      : null,
              icon: Icon(Icons.file_download),
              tooltip: 'Export transactions'),
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
                ? _filteringNumber
                    .elementAt(_transactionPagingService.selectedFilters)
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
                                child: Text(DateFormat.yMMMd().format(element)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemBuilder: (context, transaction) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          height: 60,
                          child: Card(
                            child: Row(
                              children: [
                                SizedBox(width: 20),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    _accountRepository.accounts
                                        .firstWhere((element) =>
                                            element.id == transaction.accountId)
                                        .name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 100),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    transaction.categoryName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 80),
                                Text(transaction.name),
                                Spacer(),
                                Text(transaction.price.toString(),
                                    style: TextStyle(
                                      color: transaction.transactionType ==
                                              TransactionType.Income
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                    )),
                                SizedBox(width: 20),
                              ],
                            ),
                          ),
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
    _transactionPagingService.currentPage++;
    _transactionPagingService.performSearch();
  }
}
