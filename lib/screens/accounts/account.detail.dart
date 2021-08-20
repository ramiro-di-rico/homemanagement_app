import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:home_management_app/repositories/category.repository.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'package:home_management_app/screens/transactions/add.transaction.dart';
import 'package:home_management_app/services/transaction.paging.service.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'account-metrics.dart';
import 'widgets/account-app-bar.dart';
import 'widgets/account.info.dart';
import 'widgets/transaction.row.info.dart';

class AccountDetailScren extends StatefulWidget {
  static const String id = 'account_detail_screen';
  final AccountModel account;
  AccountDetailScren({this.account});

  @override
  _AccountDetailScrenState createState() => _AccountDetailScrenState();
}

class _AccountDetailScrenState extends State<AccountDetailScren> {
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  AccountModel account;
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TransactionPagingService transactionPagingService =
      GetIt.I<TransactionPagingService>();
  TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();
  TextEditingController filteringNameController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool displayFilteringBox = false;
  bool resultsFiltered = false;
  List<TransactionModel> transactions = [];
  FocusNode filteringTextFocusNode = FocusNode();

  @override
  void initState() {
    account = widget.account;
    transactionPagingService.addListener(() {
      setState(() {});
    });
    scrollController.addListener(onScroll);
    transactionPagingService.loadFirstPage(account.id);
    filteringTextFocusNode.addListener(() {});
    filteringNameController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    filteringNameController.dispose();
    filteringTextFocusNode.dispose();
    super.dispose();
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
                  transactionPagingService.refresh();
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
              transactionPagingService.transactions.length > 0
                  ? Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          transactionPagingService.refresh();
                          await transactionPagingService
                              .loadFirstPage(account.id);
                          transactionPagingService.loadFirstPage(account.id);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: ListView.builder(
                              controller: scrollController,
                              itemCount: this
                                  .transactionPagingService
                                  .transactions
                                  .length,
                              itemBuilder: (context, index) {
                                var transaction = this
                                    .transactionPagingService
                                    .transactions[index];
                                var category = categoryRepository.categories
                                    .firstWhere((element) =>
                                        element.id == transaction.categoryId);

                                return TransactionRowInfo(
                                    transaction: transaction,
                                    index: index,
                                    category: category);
                              }),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
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
                      transactionPagingService
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
            child: Icon(OMIcons.barChart),
            backgroundColor: Colors.red,
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountMetrics(
                      account: account,
                    ),
                  ),
                )),
      );
    }

    options.add(SpeedDialChild(
        child: Icon(Icons.filter_list),
        backgroundColor: Colors.blue,
        labelStyle: TextStyle(fontSize: 18.0),
        onTap: () => displayBox()));

    options.add(SpeedDialChild(
      child: Icon(Icons.add),
      backgroundColor: Colors.green,
      labelStyle: TextStyle(fontSize: 18.0),
      onTap: () => Navigator.pushNamed(context, AddTransactionScreen.id,
          arguments: account),
    ));

    return SpeedDial(
      overlayOpacity: 0.1,
      animatedIcon: AnimatedIcons.menu_close,
      children: options,
    );
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
      transactionPagingService.nextPage();
    });
  }

  onScroll() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      nextPage();
    }
  }

  void applyNameFiltering() {
    transactionPagingService.applyFilterByName(filteringNameController.text);
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
