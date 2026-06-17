import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/extensions/hex_color_extension.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/models/category.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/services/repositories/transaction.repository.dart';

import '../../../models/account.dart';
import 'add.transaction.sheet.dart';
import 'manage_transaction_tags_sheet.dart';

class TransactionRowInfo extends StatelessWidget {
  final TransactionModel transaction;
  final int index;
  final CategoryModel category;
  final AccountModel account;

  TransactionRowInfo(
      {required this.transaction,
      required this.category,
      required this.index,
      required this.account});

  final TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Slidable(
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              autoClose: true,
              onPressed: (context) {
                var copy = transaction.duplicate();
                transactionRepository.add(copy);
              },
              icon: Icons.copy,
              backgroundColor: Colors.lightBlueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            SlidableAction(
              autoClose: true,
              icon: Icons.label_outline,
              backgroundColor: Colors.teal,
              borderRadius: BorderRadius.circular(10),
              onPressed: (context) => openManageTags(context),
            ),
            SlidableAction(
              autoClose: true,
              icon: Icons.delete,
              backgroundColor: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
              onPressed: (context) => remove(transaction, index, context),
            ),
          ],
        ),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: ListTile(
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
                            child: AddTransactionSheet(
                              account,
                              transactionModel: transaction,
                            )),
                      );
                    });
              },
              onLongPress: () => openManageTags(context),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          transaction.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Chip(
                          label: Text(
                              category.name,
                              style: TextStyle(
                                  color: category.color.fromHex().computeLuminance() > 0.5
                                      ? Colors.black
                                      : Colors.white
                              )
                          ),
                          backgroundColor: category.color.fromHex(),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Padding(
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
                        ),
                      )
                    ],
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
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                ))
                            .toList(),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => openManageTags(context),
                      icon: const Icon(Icons.label_outline, size: 16),
                      label: Text(
                        transaction.tags.isEmpty
                            ? localizations.addTag
                            : localizations.manageTransactionTags,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        closeOnScroll: true);
  }

  Future openManageTags(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (sheetContext) {
        return ManageTransactionTagsSheet(transaction: transaction);
      },
    );
  }

  Future remove(TransactionModel item, int index, BuildContext context) async {
    try {
      this.transactionRepository.remove(item);
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove ${item.name}')));
    }
  }
}
