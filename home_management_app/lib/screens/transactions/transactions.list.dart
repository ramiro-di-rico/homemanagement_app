import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/category.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/repositories/category.repository.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'package:home_management_app/services/transaction.paging.service.dart';
import 'package:intl/intl.dart';

import 'edit.transaction.dart';

class TransactionListController {
  void Function() showFilters;
}

class TransactionListWidget extends StatefulWidget {
  final int accountId;
  final TransactionListController controller;

  TransactionListWidget({@required this.accountId, this.controller});

  @override
  _TransactionListWidgetState createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget> {
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TransactionPagingService transactionPagingService =
      GetIt.I<TransactionPagingService>();
  TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();
  TextEditingController filteringNameController = TextEditingController();
  Function applyFilterButton = null;

  List<TransactionModel> transctions = List<TransactionModel>();
  ScrollController scrollController = ScrollController();
  GlobalKey<FlipCardState> flipCardKey = GlobalKey<FlipCardState>();

  void showFilters() {
    flipCardKey.currentState.toggleCard();
  }

  @override
  void initState() {
    scrollController.addListener(onScroll);
    transactionPagingService.addListener(load);
    transactionPagingService.loadFirstPage(widget.accountId);
    filteringNameController.addListener(onFilterNameChanged);

    if (this.widget.controller != null) {
      this.widget.controller.showFilters = showFilters;
    }
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    transactionPagingService.removeListener(load);
    filteringNameController.removeListener(onFilterNameChanged);
    filteringNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          transactionPagingService.refresh();
          await transactionPagingService.loadFirstPage(widget.accountId);
          this.load();
        },
        child: FlipCard(
          key: flipCardKey,
          flipOnTouch: false,
          back: buildFilteringCard(),
          front: buildListViewCard(),
        ),
      ),
    );
  }

  Card buildFilteringCard() {
    return Card(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Column(
        children: [
          Container(        
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: filteringNameController,
                decoration: InputDecoration(
                  hintText: 'Filter by Name',
                  suffix: FlatButton(
                    onPressed: applyFilterButton, 
                    child: Icon(Icons.check), 
                    shape: CircleBorder())
                ),
              ),
            )
          ),
        ],
      ),
    );
  }

  Card buildListViewCard() {
    return Card(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: transctions.length > 0
          ? ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              controller: scrollController,
              itemCount: this.transctions.length,
              itemBuilder: (context, index) {
                var transaction =
                    this.transactionPagingService.transactions[index];
                var category = categoryRepository.categories.firstWhere(
                    (element) => element.id == transaction.categoryId);

                return buildDismissible(transaction, index, context, category);
              })
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text('No transactions to display.'),
                ),
              ],
            ),
    );
  }

  Dismissible buildDismissible(TransactionModel transaction, int index,
      BuildContext context, CategoryModel category) {
    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.blueAccent,
      ),
      secondaryBackground: Container(
        color: Colors.redAccent,
      ),
      onDismissed: (direction) => remove(transaction, index),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTransactionScreen(transaction),
            ),
          );
        },
        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFirstRow(transaction),
            buildSecondRow(transaction, category)
          ],
        ),
      ),
    );
  }

  Row buildFirstRow(TransactionModel transaction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(transaction.name),
        Text(
          transaction.price.toStringAsFixed(0),
          style: TextStyle(
              color: transaction.transactionType == TransactionType.Income
                  ? Colors.greenAccent
                  : Colors.redAccent),
        )
      ],
    );
  }

  Row buildSecondRow(TransactionModel transaction, CategoryModel category) {
    return Row(
      children: [
        Text(
          DateFormat.MMMd().format(transaction.date),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Chip(
            label: Text(category.name),
          ),
        )
      ],
    );
  }

  load() {
    setState(() {
      transctions.clear();
      transctions.addAll(transactionPagingService.transactions);
    });
  }

  nextPage() {
    setState(() {
      transactionPagingService.nextPage();
      load();
    });
  }

  onScroll() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      nextPage();
    }

    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {
      print('reached top');
    }
  }

  Future remove(item, index) async {
    try {
      this.transactionRepository.remove(item);
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(item.name + ' removed')));
    } catch (ex) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove ${item.name}')));
    }
  }

  void onFilterNameChanged(){
    setState(() {
      applyFilterButton = filteringNameController.text.length > 0 ? applyNameFiltering : null;
    });
  }

  void applyNameFiltering(){
    print(filteringNameController.text);
    transactionPagingService.applyFilterByName(filteringNameController.text);
    flipCardKey.currentState.toggleCard();
  }
}
