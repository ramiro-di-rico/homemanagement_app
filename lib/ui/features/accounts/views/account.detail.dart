import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:home_management_app/ui/core/extensions/datehelper.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/data/services/transaction.service.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/ui/core/mixins/notifier_mixin.dart';
import 'account-details-behaviors/account-list-scrolling-behavior.dart';
import 'account-details-behaviors/transaction-list-skeleton-behavior.dart';
import 'account-metrics.dart';
import 'package:home_management_app/ui/features/accounts/views/widgets/account-app-bar.dart';
import 'package:home_management_app/ui/features/accounts/views/widgets/account.info.dart';
import 'package:home_management_app/ui/features/accounts/views/widgets/add.transaction.sheet.dart';
import 'package:home_management_app/ui/features/home/views/shared/account.sheet.dart';
import 'package:home_management_app/ui/features/accounts/views/widgets/transaction-row-skeleton.dart';
import 'package:home_management_app/ui/features/accounts/views/widgets/transaction.row.info.dart';

class AccountDetailScreen extends StatefulWidget {
  static const String fullPath = '/home_screen/account_detail_screen';
  static const String path = '/account_detail_screen';

  final AccountModel account;
  AccountDetailScreen(this.account);

  @override
  _AccountDetailScreenState createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen>
    with TransactionListSkeletonBehavior, AccountListScrollingBehavior, NotifierMixin {
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  late AccountModel account;
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TransactionService transactionService = GetIt.I<TransactionService>();
  TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();
  TextEditingController filteringNameController = TextEditingController();
  bool displayFilteringBox = false;
  bool resultsFiltered = false;
  List<TransactionModel> transactions = [];
  FocusNode filteringTextFocusNode = FocusNode();

  @override
  void initState() {
    account = widget.account;
    transactionRepository.addListener(refreshState);
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

  @override
  void didUpdateWidget(AccountDetailScreen oldWidget) {
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
      appBar: AccountAppBar(
        account: account,
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
                tooltip: AppLocalizations.of(context)!.showMenu,
              );
            },
            menuChildren: [
              MenuItemButton(
                leadingIcon: Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () => _editAccount(account),
                child: Text(AppLocalizations.of(context)!.editAccount),
              ),
              MenuItemButton(
                leadingIcon: Icon(account.archive ? Icons.unarchive : Icons.archive, color: Colors.pinkAccent),
                onPressed: () => _archiveAccount(account),
                child: Text(account.archive ? AppLocalizations.of(context)!.unarchive : AppLocalizations.of(context)!.archive),
              ),
              MenuItemButton(
                leadingIcon: Icon(Icons.upload_file, color: Colors.blueGrey),
                onPressed: () => _importTransactions(account),
                child: Text(AppLocalizations.of(context)!.importTransactions),
              ),
            ],
          ),
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
                    child: isDisplayingSkeletons()
                        ? Skeletonizer(
                            enabled: true,
                            child: ListView.builder(
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                var transaction = transactions[index];
                                return TransactionRowInfo(
                                    transaction: transaction,
                                    category: CategoryModel.empty(),
                                    index: index,
                                    account: account);
                              },
                            ),
                          )
                        : transactions.isEmpty
                            ? Center(
                                child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 48, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text(AppLocalizations.of(context)!.noTransactionsFoundForAccount),
                                ],
                              ))
                            : GroupedListView<TransactionModel, DateTime>(
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
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            DateFormat.MMMd().format(element)),
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

                              var category = categoryRepository.categories
                                  .firstWhere(
                                      (element) =>
                                          element.id == transaction.categoryId,
                                      orElse: () => CategoryModel.empty());

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
                            hintText: AppLocalizations.of(context)!.filterByName,
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
            onTap: () => context.go(AccountMetrics.fullPath, extra: account)),
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
                height: 420,
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
    refreshState();
    await transactionRepository.loadFirstPage(account.id);
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

  void applyNameFiltering() {
    transactionRepository.applyFilterByName(filteringNameController.text);
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
                content: Text(AppLocalizations.of(context)!.transactionsImportedSuccessfully),
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
            content: Text(AppLocalizations.of(context)!.failedToImportTransactions),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
