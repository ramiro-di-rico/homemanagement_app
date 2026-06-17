import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:home_management_app/extensions/datehelper.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';
import '../../services/infra/platform/platform_context.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/transaction_paging_service.dart';
import '../accounts/account-details-behaviors/account-list-scrolling-behavior.dart';
import '../accounts/widgets/manage_transaction_tags_sheet.dart';
import 'transactions_search_statistics_view.dart';
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
    final localizations = AppLocalizations.of(context)!;
    final isCompact = MediaQuery.of(context).size.width < 700;
    final accountNamesById = {
      for (final account in _accountRepository.accounts) account.id: account.name
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.searchTransactions),
        actions: isCompact
            ? [
                IconButton(
                  onPressed: !_transactionPagingService.filtering
                      ? null
                      : () {
                          context.go(
                              TransactionsSearchStatisticsView.fullPath);
                        },
                  icon: Icon(Icons.bar_chart),
                  tooltip: localizations.transactionsSearchStatistics,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'pageSize':
                        _showPageSizePicker();
                        break;
                      case 'export':
                        if (_transactionPagingService.filtering &&
                            _platform.isDownloadEnabled()) {
                          final csvContent =
                              _transactionPagingService.generateCsvContent();
                          _platform.saveFile('transactions', 'csv', csvContent);
                        }
                        break;
                      case 'clear':
                        setState(() {
                          _transactionPagingService.clearFilters();
                        });
                        break;
                      case 'filter':
                        displayFilteringOptions();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pageSize',
                      child: Text(localizations.pageSize),
                    ),
                    PopupMenuItem(
                      value: 'export',
                      enabled:
                          _transactionPagingService.filtering &&
                              _platform.isDownloadEnabled(),
                      child: Text(localizations.exportTransactions),
                    ),
                    PopupMenuItem(
                      value: 'clear',
                      child: Text(localizations.clearFilters),
                    ),
                    PopupMenuItem(
                      value: 'filter',
                      child: Text(localizations.filterTransactions),
                    ),
                  ],
                ),
              ]
            : [
                DropdownButton<int>(
                  value: _transactionPagingService.pageSize,
                  icon: Icon(Icons.arrow_downward),
                  onChanged: !_transactionPagingService.filtering
                      ? null
                      : (int? pageSize) {
                          setState(() {
                            _transactionPagingService.pageSize = pageSize!;
                            _transactionPagingService.performSearch(
                                resetPaging: true);
                          });
                        },
                  items: [10, 20, 30, 50, 100]
                      .map<DropdownMenuItem<int>>((int value) {
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
                                final csvContent =
                                    _transactionPagingService
                                        .generateCsvContent();
                                _platform.saveFile(
                                    'transactions', 'csv', csvContent);
                              }
                            : null,
                    icon: Icon(Icons.file_download),
                    tooltip: localizations.exportTransactions),
                IconButton(
                  onPressed: !_transactionPagingService.filtering
                      ? null
                      : () {
                          context.go(TransactionsSearchStatisticsView.fullPath);
                        },
                  icon: Icon(Icons.bar_chart),
                  tooltip: localizations.transactionsSearchStatistics,
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _transactionPagingService.clearFilters();
                      });
                    },
                    icon: Icon(Icons.filter_alt_off),
                    tooltip: localizations.clearFilters),
                IconButton(
                  onPressed: () {
                    displayFilteringOptions();
                  },
                  icon: Icon(_transactionPagingService.filtering
                      ? _filteringNumber
                          .elementAt(_transactionPagingService.selectedFilters)
                      : Icons.filter_alt_outlined),
                  tooltip: localizations.filterTransactions,
                )
              ],
      ),
      body: Container(
        child: !_transactionPagingService.filtering
            ? Center(child: Text(localizations.selectFilterToDisplayTransactions))
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
                      final accountName =
                          accountNamesById[transaction.accountId] ?? localizations.unknownAccount;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => openManageTags(transaction),
                            child: isCompact
                                ? ListTile(
                                    title: Text(
                                      transaction.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$accountName · ${transaction.categoryName}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (transaction.tags.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: transaction.tags
                                                  .map((tag) => Chip(
                                                        label: Text(
                                                          tag.name,
                                                          style: const TextStyle(
                                                              fontSize: 11),
                                                        ),
                                                        visualDensity:
                                                            VisualDensity.compact,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        padding: EdgeInsets.zero,
                                                      ))
                                                  .toList(),
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          transaction.price.toString(),
                                          style: TextStyle(
                                            color: transaction.transactionType ==
                                                    TransactionType.Income
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.label_outline,
                                              size: 20),
                                          tooltip: transaction.tags.isEmpty
                                              ? localizations.addTag
                                              : localizations.manageTransactionTags,
                                          onPressed: () =>
                                              openManageTags(transaction),
                                        ),
                                      ],
                                    ),
                                  )
                                : ConstrainedBox(
                                    constraints: const BoxConstraints(minHeight: 60),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 20),
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            accountName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 100),
                                        SizedBox(
                                          width: 120,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                transaction.categoryName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (transaction.tags.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Wrap(
                                                    spacing: 4,
                                                    runSpacing: 4,
                                                    children: transaction.tags
                                                        .map((tag) => Chip(
                                                              label: Text(
                                                                tag.name,
                                                                style: const TextStyle(
                                                                    fontSize: 11),
                                                              ),
                                                              visualDensity:
                                                                  VisualDensity.compact,
                                                              materialTapTargetSize:
                                                                  MaterialTapTargetSize
                                                                      .shrinkWrap,
                                                              padding: EdgeInsets.zero,
                                                            ))
                                                        .toList(),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 80),
                                        Expanded(child: Text(transaction.name)),
                                        Text(transaction.price.toString(),
                                            style: TextStyle(
                                              color: transaction.transactionType ==
                                                      TransactionType.Income
                                                  ? Colors.greenAccent
                                                  : Colors.redAccent,
                                            )),
                                        IconButton(
                                          icon: const Icon(Icons.label_outline),
                                          tooltip: transaction.tags.isEmpty
                                              ? localizations.addTag
                                              : localizations.manageTransactionTags,
                                          onPressed: () =>
                                              openManageTags(transaction),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                    ),
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
          maxHeight: MediaQuery.of(context).size.height * 0.92,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        builder: (context) {
          return TransactionSearchFilteringOptionsSheet();
        });
  }

  Future<void> openManageTags(TransactionModel transaction) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (sheetContext) {
        return ManageTransactionTagsSheet(transaction: transaction);
      },
    );
    if (saved == true) {
      _transactionPagingService.performSearch(resetPaging: true);
    }
  }

  @override
  void load() {
    // TODO: implement load
  }

  @override
  void nextPage() {
    if (_transactionPagingService.loading || !_transactionPagingService.hasMore) {
      return;
    }

    _transactionPagingService.currentPage++;
    _transactionPagingService.performSearch();
  }

  void _showPageSizePicker() {
    showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final pageSize in [10, 20, 30, 50, 100])
                ListTile(
                  title: Text(pageSize.toString()),
                  onTap: () {
                    Navigator.pop(context, pageSize);
                  },
                ),
            ],
          ),
        );
      },
    ).then((pageSize) {
      if (pageSize == null || !_transactionPagingService.filtering) {
        return;
      }

      setState(() {
        _transactionPagingService.pageSize = pageSize;
        _transactionPagingService.performSearch(resetPaging: true);
      });
    });
  }
}
