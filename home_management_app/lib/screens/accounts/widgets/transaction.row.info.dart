import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/category.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'package:home_management_app/screens/transactions/edit.transaction.dart';
import 'package:intl/intl.dart';

class TransactionRowInfo extends StatelessWidget {
  final TransactionModel transaction;
  final int index;
  final CategoryModel category;
  TransactionRowInfo(
      {@required this.transaction,
      @required this.category,
      @required this.index});

  final TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();

  @override
  Widget build(BuildContext context) {
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
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTransactionScreen(transaction),
                ),
              );
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(transaction.name),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Text(
                        transaction.price % 1 == 0
                            ? transaction.price.toStringAsFixed(0)
                            : transaction.price.toStringAsFixed(2),
                        style: TextStyle(
                            color: transaction.transactionType ==
                                    TransactionType.Income
                                ? Colors.greenAccent
                                : Colors.redAccent),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text(
                      DateFormat.MMMd().format(transaction.date),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Chip(
                        label: Text(category.name),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future remove(item, index) async {
    try {
      //this.transactionRepository.remove(item);
      /*ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(item.name + ' removed')));*/
    } catch (ex) {
      /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove ${item.name}')));*/
    }
  }
}
