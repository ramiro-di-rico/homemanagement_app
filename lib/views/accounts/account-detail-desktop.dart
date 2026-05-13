import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
import '../../services/endpoints/transaction.service.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/transaction.repository.dart';
import '../main/widgets/account.sheet.dart';
import '../main/widgets/overview/overview-widget.dart';
import '../mixins/notifier_mixin.dart';
import 'account-details-behaviors/account-list-scrolling-behavior.dart';
import 'account-details-behaviors/transaction-list-skeleton-behavior.dart';
import 'widgets/account-most-expensive-categories.dart';
import 'widgets/account.info.dart';
import 'widgets/transaction.row.info.dart';

class AccountDetailDesktop extends StatefulWidget {

  final AccountModel account;
  AccountDetailDesktop(this.account);

  @override
  State<AccountDetailDesktop> createState() => _AccountDetailDesktopState();
}

class _AccountDetailDesktopState extends State<AccountDetailDesktop>
    with TransactionListSkeletonBehavior, AccountListScrollingBehavior, NotifierMixin {
  late AccountModel account;
  Overall? overall;

  MetricService _metricService = GetIt.I<MetricService>();
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TransactionService transactionService = GetIt.I<TransactionService>();
  TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    account = widget.account;
    transactionRepository.addListener(refreshState);
    accountRepository.addListener(refreshState);
    load();
    super.initState();
  }

  @override
  void dispose() {
    transactionRepository.removeListener(refreshState);
    accountRepository.removeListener(refreshState);
    super.dispose();
  }

  @override
  void didUpdateWidget(AccountDetailDesktop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.id != widget.account.id) {
      account = widget.account;
      load();
    }
  }

  void refreshState() {
    setState(() {
      transactions = transactionRepository.transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account: ${account.name}'),
        actions: [
          MenuAnchor(
            builder: (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_vert),
                tooltip: 'Show menu',
              );
            },
            menuChildren: [
              MenuItemButton(
                leadingIcon: Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () => _editAccount(account),
                child: Text('Edit Account'),
              ),
              MenuItemButton(
                leadingIcon: Icon(account.archive ? Icons.unarchive : Icons.archive, color: Colors.pinkAccent),
                onPressed: () => _archiveAccount(account),
                child: Text(account.archive ? 'Unarchive' : 'Archive'),
              ),
              MenuItemButton(
                leadingIcon: Icon(Icons.upload_file, color: Colors.blueGrey),
                onPressed: () => _importTransactions(account),
                child: Text('Import Transactions'),
              ),
            ],
          ),
        ],
      ),
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
                                      constraints: BoxConstraints(
                                          maxHeight: 1000,
                                          maxWidth: 1200,
                                      ),
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
                                            .firstWhere(
                                                (element) =>
                                                    element.id ==
                                                    transaction.categoryId,
                                                orElse: () =>
                                                    CategoryModel.empty());

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
    refreshState();
    await transactionRepository.loadFirstPage(account.id);
    overall = await _metricService.getOverallByAccountId(account.id);
    refreshState();
  }

  nextPage() {
    setState(() {
      addSkeletonTransactions();
      transactionRepository.nextPage();
    });
  }

  void _editAccount(AccountModel account) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        builder: (context) {
          return SizedBox(
            height: 250,
            child: AnimatedPadding(
                padding: MediaQuery.of(context).viewInsets,
                duration: Duration(seconds: 1),
                child: AccountSheet(accountModel: account)),
          );
        });
  }

  Future<void> _archiveAccount(AccountModel account) async {
    await accountRepository.archive(account);
  }

  Future<void> _importTransactions(AccountModel account) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        var fileContent = await file.xFile.readAsString();

        if (fileContent.isNotEmpty) {
          await transactionService.import(account.id, fileContent);
          await accountRepository.refresh();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Transactions imported successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import transactions'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
