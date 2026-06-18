import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/services/transaction_paging_service.dart';
import 'package:home_management_app/ui/features/home/views/shared/search_statistics/transaction_counts_widget.dart';
import 'package:home_management_app/ui/features/home/views/shared/search_statistics/transaction_totals_widget.dart';
import 'package:home_management_app/ui/features/home/views/shared/search_statistics/transactions_by_account_chart.dart';
import 'package:home_management_app/ui/features/home/views/shared/search_statistics/transactions_by_category_chart.dart';

class TransactionsSearchStatisticsView extends StatefulWidget {
  static const String fullPath = '/home_screen/transactions_search_statistics';
  static const String path = '/transactions_search_statistics';

  const TransactionsSearchStatisticsView({super.key});

  @override
  State<TransactionsSearchStatisticsView> createState() =>
      _TransactionsSearchStatisticsViewState();
}

class _TransactionsSearchStatisticsViewState
    extends State<TransactionsSearchStatisticsView> {
  final TransactionPagingService _pagingService =
      GetIt.I<TransactionPagingService>();
  final AccountRepository _accountRepository = GetIt.I<AccountRepository>();

  @override
  void initState() {
    super.initState();
    _pagingService.addListener(_onServiceChanged);
    _pagingService.loadAllForStats();
  }

  @override
  void dispose() {
    _pagingService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final transactions = _pagingService.allFilteredTransactions;
    final accountNamesById = {
      for (final account in _accountRepository.accounts)
        account.id: account.name
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.transactionsSearchStatistics),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _pagingService.loadAllForStats,
            tooltip: localizations.refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: !_pagingService.filtering
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    localizations.selectFilterToDisplayTransactions,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Skeletonizer(
                enabled: _pagingService.loadingStats,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 1100;

                    if (isWide) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 220,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child:
                                          TransactionCountsWidget(transactions: transactions),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child:
                                          TransactionTotalsWidget(transactions: transactions),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 380,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: TransactionsByCategoryChart(
                                            transactions: transactions),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: TransactionsByAccountChart(
                                          transactions: transactions,
                                          accountNamesById: accountNamesById,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TransactionCountsWidget(
                                  transactions: transactions),
                            ),
                          ),
                          SizedBox(
                            height: 220,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TransactionTotalsWidget(
                                  transactions: transactions),
                            ),
                          ),
                          SizedBox(
                            height: 380,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TransactionsByCategoryChart(
                                  transactions: transactions),
                            ),
                          ),
                          SizedBox(
                            height: 380,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TransactionsByAccountChart(
                                transactions: transactions,
                                accountNamesById: accountNamesById,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
