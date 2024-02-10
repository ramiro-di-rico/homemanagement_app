import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:home_management_app/extensions/datehelper.dart';
import 'package:intl/intl.dart';

import '../../models/account.dart';
import '../../models/overall.dart';
import '../../models/transaction.dart';
import '../../services/endpoints/metrics.service.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/transaction.repository.dart';
import '../main/widgets/overview/overview-widget.dart';
import 'account-metrics.dart';
import 'widgets/account-most-expensive-categories.dart';
import 'widgets/account.info.dart';
import 'widgets/transaction-row-skeleton.dart';
import 'widgets/transaction.row.info.dart';

class AccountDetailDesktop extends StatefulWidget {
  const AccountDetailDesktop({super.key});

  @override
  State<AccountDetailDesktop> createState() => _AccountDetailDesktopState();
}

class _AccountDetailDesktopState extends State<AccountDetailDesktop> {
  late AccountModel account;
  Overall? overall;

  MetricService _metricService = GetIt.I<MetricService>();
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TransactionRepository transactionRepository = GetIt.I<TransactionRepository>();
  TextEditingController filteringNameController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool displayFilteringBox = false;
  bool resultsFiltered = false;
  List<TransactionModel> transactions = [];
  FocusNode filteringTextFocusNode = FocusNode();
  bool loading = false;
  final String skeletonName = 'skeleton';

  @override
  void initState() {
    transactionRepository.addListener(refreshState);
    scrollController.addListener(onScroll);
    filteringTextFocusNode.addListener(() {});
    filteringNameController.addListener(refreshState);
    accountRepository.addListener(refreshState);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    filteringNameController.removeListener(refreshState);
    transactionRepository.removeListener(refreshState);
    accountRepository.removeListener(refreshState);
    filteringNameController.dispose();
    filteringTextFocusNode.dispose();
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
            height: 700,
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
                          Container(
                            height: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AccountMostExpensiveCategories(account),
                            ),
                          ),
                          Container(
                            height: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: OverviewWidget(overall: overall),
                            ),
                          )
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
                                )),
                          ),
                          SizedBox(height: 15),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: SizedBox(
                              height: 500,
                              child: GroupedListView<TransactionModel, DateTime>(
                                order: GroupedListOrder.DESC,
                                controller: scrollController,
                                physics: ScrollPhysics(),
                                elements: transactions,
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
                                  var index = transactionRepository.transactions
                                      .indexOf(transaction);

                                  if (transaction.name == skeletonName) {
                                    return TransactionRowSkeleton();
                                  }

                                  var category = categoryRepository.categories.firstWhere(
                                          (element) => element.id == transaction.categoryId);

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
      changeLoadingState(true);
      setState(() {
        addSkeletonTransactions();
      });
      await transactionRepository.loadFirstPage(account.id);
      overall = await _metricService.getOverallByAccountId(account.id);
      changeLoadingState(false);
    } else {
      refreshState();
    }
  }

  void changeLoadingState(bool value) {
    setState(() {
      loading = value;
    });
  }

  nextPage() {
    setState(() {
      addSkeletonTransactions();
      transactionRepository.nextPage();
    });
  }

  onScroll() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      nextPage();
    }
  }

  void applyNameFiltering() {
    transactionRepository.applyFilterByName(filteringNameController.text);
  }

  void addSkeletonTransactions() {
    for (var i = 0; i < 10; i++) {
      transactions.add(TransactionModel(
          0, 0, 0, skeletonName, 0, DateTime.now(), TransactionType.Income));
    }
  }

  Future remove(item, index) async {
    try {
      this.transactionRepository.remove(item);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(item.name + ' removed')));
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove ${item.name}')));
    }
  }
}
