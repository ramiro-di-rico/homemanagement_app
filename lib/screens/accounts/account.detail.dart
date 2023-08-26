import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get_it/get_it.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:home_management_app/extensions/datehelper.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:home_management_app/repositories/category.repository.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'package:home_management_app/screens/accounts/widgets/transaction-row-skeleton.dart';
import 'package:intl/intl.dart';

import 'account-metrics.dart';
import 'widgets/account-app-bar.dart';
import 'widgets/account.info.dart';
import 'widgets/add.transaction.sheet.dart';
import 'widgets/transaction.row.info.dart';

class AccountDetailScren extends StatefulWidget {
  static const String id = 'account_detail_screen';
  final AccountModel? account;
  AccountDetailScren({this.account});

  @override
  _AccountDetailScrenState createState() => _AccountDetailScrenState();
}

class _AccountDetailScrenState extends State<AccountDetailScren> {
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  late AccountModel account;
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();
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
    account = widget.account!;
    transactionRepository.addListener(refreshState);
    scrollController.addListener(onScroll);
    filteringTextFocusNode.addListener(() {});
    filteringNameController.addListener(refreshState);
    accountRepository.addListener(refreshState);
    load();
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
    return Scaffold(
      appBar: AccountAppBar(
        account: widget.account,
        actions: [
          Visibility(
            visible: resultsFiltered,
            child: IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  resultsFiltered = false;
                  //transactionRepository.refresh();
                });
              },
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              AccountDetailWidget(accountModel: account),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => await transactionRepository.refresh(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
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
                                  child:
                                      Text(DateFormat.MMMd().format(element)),
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
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: displayFilteringBox ? 80 : 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        focusNode: filteringTextFocusNode,
                        controller: filteringNameController,
                        decoration: InputDecoration(
                            hintText: 'Filter by name',
                            focusedBorder:
                                displayFilteringBox ? null : InputBorder.none,
                            enabledBorder: InputBorder.none),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: displayFilteringBox
          ? filteringNameController.text.isEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      displayFilteringBox = false;
                      filteringNameController.clear();
                    });
                  },
                  child: Icon(Icons.close),
                )
              : FloatingActionButton(
                  child: Icon(Icons.check),
                  onPressed: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      transactionRepository
                          .applyFilterByName(filteringNameController.text);
                      displayFilteringBox = false;
                      filteringNameController.clear();
                      resultsFiltered = true;
                    });
                  })
          : buildSpeedDial(context),
    );
  }

  SpeedDial buildSpeedDial(BuildContext context) {
    List<SpeedDialChild> options = [];

    if (account.measurable) {
      options.add(
        SpeedDialChild(
          child: Icon(Icons.bar_chart),
          backgroundColor: Colors.lightBlue,
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountMetrics(
                account: account,
              ),
            ),
          ),
        ),
      );
    }
    /* Filtering not working in transaction.repository
    filtering local by name not working
    options.add(SpeedDialChild(
        child: Icon(Icons.filter_list),
        backgroundColor: Colors.blue,
        labelStyle: TextStyle(fontSize: 18.0),
        onTap: () => displayBox()));
    */
    options.add(SpeedDialChild(
      child: Icon(Icons.add),
      backgroundColor: Colors.green,
      labelStyle: TextStyle(fontSize: 18.0),
      onTap: () {
        showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(25.0))),
            builder: (context) {
              return SizedBox(
                height: 400,
                child: AnimatedPadding(
                    padding: MediaQuery.of(context).viewInsets,
                    duration: Duration(seconds: 1),
                    child: AddTransactionSheet(account)),
              );
            });
      },
    ));

    return SpeedDial(
      overlayOpacity: 0.1,
      animatedIcon: AnimatedIcons.menu_close,
      children: options,
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

  displayBox() {
    setState(() {
      this.displayFilteringBox = !this.displayFilteringBox;

      if (!this.displayFilteringBox) {
        filteringTextFocusNode.unfocus();
        this.filteringNameController.clear();
      } else {
        filteringTextFocusNode.requestFocus();
      }
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
