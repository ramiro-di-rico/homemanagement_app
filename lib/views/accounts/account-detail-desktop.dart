import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:home_management_app/extensions/datehelper.dart';
import 'package:home_management_app/views/accounts/widgets/add_transaction_sheet_desktop.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/overall.dart';
import '../../models/transaction.dart';
import '../../services/endpoints/metrics.service.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/transaction.repository.dart';
import '../main/widgets/overview/overview-widget.dart';
import 'account-details-behaviors/account-list-scrolling-behavior.dart';
import 'account-details-behaviors/transaction-list-skeleton-behavior.dart';
import 'widgets/account-most-expensive-categories.dart';
import 'widgets/account.info.dart';
import 'widgets/transaction.row.info.dart';

class AccountDetailDesktop extends StatefulWidget {
  const AccountDetailDesktop({super.key});

  @override
  State<AccountDetailDesktop> createState() => _AccountDetailDesktopState();
}

class _AccountDetailDesktopState extends State<AccountDetailDesktop>
    with TransactionListSkeletonBehavior, AccountListScrollingBehavior {
  late AccountModel account;
  Overall? overall;

  MetricService _metricService = GetIt.I<MetricService>();
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    transactionRepository.addListener(refreshState);
    accountRepository.addListener(refreshState);
    super.initState();
  }

  @override
  void dispose() {
    transactionRepository.removeListener(refreshState);
    accountRepository.removeListener(refreshState);
    super.dispose();
  }

  void refreshState() {
    setState(() {
      transactions = transactionRepository.transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    account = ModalRoute.of(context)!.settings.arguments as AccountModel;
    load();

    return Scaffold(
      appBar: AppBar(title: Text('Account: ${account.name}')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: 660,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AccountDetailWidget(accountModel: account),
                          account.measurable
                              ? Container(
                                  height: 300,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                        AccountMostExpensiveCategories(account),
                                  ),
                                )
                              : Container(),
                          account.measurable
                              ? Container(
                                  height: 300,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: OverviewWidget(overall: overall),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          Card(
                            child: ListTile(
                              title: Text(
                                'Transactions',
                                style: TextStyle(fontSize: 20),
                              ),
                              trailing: TextButton(
                                onPressed: () {
                                  showModalBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(25.0))),
                                      builder: (context) {
                                        return SizedBox(
                                          height: 100,
                                          child: AnimatedPadding(
                                              padding: MediaQuery.of(context)
                                                  .viewInsets,
                                              duration: Duration(seconds: 1),
                                              child: AddTransactionSheetDesktop(
                                                  account)),
                                        );
                                      });
                                },
                                child: Icon(Icons.add),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: SizedBox(
                              height: 575,
                              child: isDisplayingSkeletons()
                                  ? Skeletonizer(
                                      enabled: true,
                                      child: ListView.builder(
                                        itemCount: 10,
                                        itemBuilder: (context, index) {
                                          var transaction = transactions[index];
                                          return TransactionRowInfo(
                                            transaction: transaction,
                                            index: index,
                                            category: CategoryModel.empty(),
                                            account: account,
                                          );
                                        },
                                      ),
                                    )
                                  : GroupedListView<TransactionModel, DateTime>(
                                      order: GroupedListOrder.DESC,
                                      controller: scrollController,
                                      physics: ScrollPhysics(),
                                      elements: transactions,
                                      groupBy: (element) =>
                                          element.date.toMidnight(),
                                      groupSeparatorBuilder: (element) {
                                        return Container(
                                          height: 50,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 0, 0, 0),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(DateFormat.MMMd()
                                                      .format(element)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, transaction) {
                                        var index = transactionRepository
                                            .transactions
                                            .indexOf(transaction);

                                        var category = categoryRepository
                                            .categories
                                            .firstWhere((element) =>
                                                element.id ==
                                                transaction.categoryId);

                                        return TransactionRowInfo(
                                          transaction: transaction,
                                          index: index,
                                          category: category,
                                          account: account,
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void load() async {
    if (!transactionRepository.transactions
        .any((element) => element.accountId == account.id)) {
      setState(() {
        addSkeletonTransactions();
      });
      await transactionRepository.loadFirstPage(account.id);
      overall = await _metricService.getOverallByAccountId(account.id);
      refreshState();
    } else {
      refreshState();
    }
  }

  nextPage() {
    setState(() {
      addSkeletonTransactions();
      transactionRepository.nextPage();
    });
  }
}
