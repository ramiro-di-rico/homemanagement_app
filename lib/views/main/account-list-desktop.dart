import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../models/account.dart';
import '../../services/endpoints/transaction.service.dart';
import '../../services/infra/platform/platform_context.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/repositories/transaction.repository.dart';
import '../accounts/account.detail.dart';
import '../accounts/widgets/add_transaction_sheet_desktop.dart';
import '../mixins/notifier_mixin.dart';
import 'widgets/account-sheet-dektop.dart';
import 'widgets/account.sheet.dart';
import 'package:file_picker/file_picker.dart';

class AccountListDesktopView extends StatefulWidget {
  @override
  _AccountListDesktopViewState createState() => _AccountListDesktopViewState();
}

class _AccountListDesktopViewState extends State<AccountListDesktopView>
    with NotifierMixin {
  List<AccountModel> accounts = [];
  AccountRepository accountsRepo = GetIt.instance<AccountRepository>();
  TransactionRepository transactionsRepo =
      GetIt.instance<TransactionRepository>();
  TransactionService transactionService = GetIt.instance<TransactionService>();
  PlatformContext platform = GetIt.instance<PlatformContext>();
  bool showArchive = false;

  @override
  void initState() {
    super.initState();
    load();
    accountsRepo.addListener(load);
    transactionsRepo.addListener(refreshAccounts);
  }

  @override
  void dispose() {
    accountsRepo.removeListener(load);
    transactionsRepo.removeListener(refreshAccounts);
    super.dispose();
  }

  load() {
    setState(() {
      this.accounts = accountsRepo.accounts;
    });
  }

  Future refreshAccounts() async {
    await accountsRepo.refresh();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            title: Text(
              'Accounts',
              style: TextStyle(fontSize: 20),
            ),
            leading: IconButton(
              tooltip: showArchive ? 'Hide archived accounts' : 'Show archived accounts',
              icon: Icon(showArchive ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  accountsRepo.displayArchive(!showArchive);
                  showArchive = !showArchive;
                });
              },
            ),
            trailing: TextButton(
              onPressed: () {
                showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    constraints: BoxConstraints(
                      maxHeight: 500,
                      maxWidth: 1200,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25.0))),
                    builder: (context) {
                      return SizedBox(
                        height: 100,
                        child: AnimatedPadding(
                            padding: MediaQuery.of(context).viewInsets,
                            duration: Duration(seconds: 1),
                            child: AccountSheetDesktop()),
                      );
                    });
              },
              child: Icon(Icons.add),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            height: 330,
            child: RefreshIndicator(
              onRefresh: refreshAccounts,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: this.accounts.length,
                itemBuilder: (context, index) {
                  if (this.accounts.isEmpty) return Container();

                  final item = this.accounts[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: ListTile(
                        title: Row(
                          children: [
                            Text(
                              item.name,
                            ),
                            Spacer(),
                            Text(
                              item.balance % 1 == 0
                                  ? item.balance.toStringAsFixed(0)
                                  : item.balance.toStringAsFixed(2),
                              style: TextStyle(
                                  color: item.balance >= 0
                                      ? Colors.greenAccent
                                      : Colors.redAccent),
                            ),
                          ],
                        ),
                        onTap: () {
                          context.go(AccountDetailScreen.fullPath, extra: item);
                        },
                      ),
                      trailing: MenuAnchor(
                        builder: (BuildContext context, MenuController controller,
                            Widget? child) {
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
                              leadingIcon: Icon(Icons.add, color: Colors.greenAccent),
                              child: Text('Add',
                                  style: TextStyle(color: Colors.greenAccent)),
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
                                            padding: MediaQuery.of(context).viewInsets,
                                            duration: Duration(seconds: 1),
                                            child: AddTransactionSheetDesktop(item)),
                                      );
                                    });
                              }),
                          MenuItemButton(
                            leadingIcon: Icon(Icons.edit, color: Colors.blueAccent),
                            child: Text('Edit',
                                style: TextStyle(color: Colors.blueAccent)),
                            onPressed: () {
                              showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25.0))),
                                  builder: (context) {
                                    return SizedBox(
                                      height: 250,
                                      child: AnimatedPadding(
                                          padding: MediaQuery.of(context).viewInsets,
                                          duration: Duration(seconds: 1),
                                          child: AccountSheet(accountModel: item)),
                                    );
                                  });
                            },
                          ),
                          MenuItemButton(
                            leadingIcon: Icon(Icons.archive, color: Colors.pinkAccent),
                            child: Text(item.archive ? 'Unarchive' : 'Archive',
                                style: TextStyle(color: Colors.pinkAccent)),
                            onPressed: () {
                              accountsRepo.archive(item);
                            },
                          ),
                          MenuItemButton(
                            leadingIcon: Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            child: Text('Delete',
                                style: TextStyle(color: Colors.redAccent)),
                            onPressed: () {
                              remove(item, index);
                            },
                          ),
                          platform.isDownloadEnabled()
                              ? MenuItemButton(
                                  leadingIcon:
                                      Icon(Icons.download, color: Colors.blueAccent),
                                  child: Text('Export transactions',
                                      style: TextStyle(color: Colors.blueAccent)),
                                  onPressed: () async {
                                    var csvContent =
                                        await transactionService.export(item.id);
                                    platform.saveFile(item.name, "csv", csvContent);
                                  },
                                )
                              : Container(),
                          platform.isDownloadEnabled()
                              ? MenuItemButton(
                                  leadingIcon:
                                      Icon(Icons.description, color: Colors.orangeAccent),
                                  child: Text('Download import template',
                                      style: TextStyle(color: Colors.orangeAccent)),
                                  onPressed: () async {
                                    try {
                                      final csvContent = buildCsvTemplate(item.id);
                                      await platform.saveFile('transactions_template', 'csv', csvContent);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Template downloaded'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to download template'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                )
                              : Container(),
                          platform.isUploadEnabled()
                              ? MenuItemButton(
                                  leadingIcon:
                                      Icon(Icons.upload, color: Colors.greenAccent),
                                  child: Text('Import transactions',
                                      style: TextStyle(color: Colors.greenAccent)),
                                  onPressed: () async {

                                    var fileContent = await pickFile();

                                    if (fileContent.isEmpty) {
                                      return;
                                    }

                                    await transactionService.import(item.id, fileContent);
                                    refreshAccounts();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Transactions imported successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                )
                              : Container(),
                        ],
                        child: Icon(Icons.more_vert),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future remove(item, index) async {
    try {
      await this.accountsRepo.delete(item);
      setState(() {
        accounts.remove(item);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(item.name + ' removed')));
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Failed to remove ${item.name}',
        style: TextStyle(color: Colors.redAccent),
      )));
    }
  }


  String buildCsvTemplate(int accountId) {
    final header = 'Id;Name;Price;Date;TransactionType;Category;;AccountId';
    final today = DateTime.now();
    final exampleDate = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final exampleRow = ';Example transaction;0.00;$exampleDate;Expense;Some Category;;$accountId';
    return header + '\n' + exampleRow + '\n';
  }

  Future<String> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      var fileContent = await file.xFile.readAsString();
      return fileContent;
    }

    return '';
  }
}
