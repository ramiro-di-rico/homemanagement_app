import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/main_account.dart';
import 'package:home_management_app/services/endpoints/transaction.service.dart';
import 'package:home_management_app/services/repositories/account.repository.dart';
import 'package:home_management_app/services/repositories/main_account.repository.dart';
import 'package:home_management_app/views/accounts/account.detail.dart';
import 'package:home_management_app/views/accounts/widgets/add.transaction.sheet.dart';
import 'package:home_management_app/views/main/main_account.detail.dart';
import 'package:home_management_app/views/main/widgets/account.sheet.dart';
import 'package:home_management_app/views/main/widgets/main_account.sheet.dart';
import 'package:home_management_app/views/mixins/notifier_mixin.dart';
import 'package:file_picker/file_picker.dart';

class MainAccountExpansionTile extends StatefulWidget {
  final MainAccountModel mainAccount;

  MainAccountExpansionTile({required this.mainAccount, Key? key}) : super(key: key);

  @override
  _MainAccountExpansionTileState createState() => _MainAccountExpansionTileState();
}

class _MainAccountExpansionTileState extends State<MainAccountExpansionTile>
    with NotifierMixin, TickerProviderStateMixin {
  MainAccountRepository mainAccountRepository = GetIt.I<MainAccountRepository>();
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  TransactionService transactionService = GetIt.I<TransactionService>();
  List<AccountModel> childAccounts = [];
  List<AccountModel> allAccounts = [];
  bool isLoading = false;
  bool isExpanded = false;

  Set<int> pendingAddIds = {};
  Set<int> pendingRemoveIds = {};

  final Map<int, AnimationController> _progressControllers = {};

  @override
  void initState() {
    accountRepository.addListener(_onAccountRepositoryChanged);
    allAccounts = accountRepository.getAllAccounts();
    super.initState();
  }

  @override
  void dispose() {
    accountRepository.removeListener(_onAccountRepositoryChanged);
    for (var controller in _progressControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onAccountRepositoryChanged() {
    if (mounted) {
      setState(() {
        allAccounts = accountRepository.getAllAccounts();
      });
    }
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
    });
    try {
      var children = await mainAccountRepository.getAccounts(widget.mainAccount.id);
      if (mounted) {
        setState(() {
          childAccounts = children;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.mainAccount.name),
      shape: Border.all(color: Colors.transparent),
      collapsedShape: Border.all(color: Colors.transparent),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(
              childAccounts.isNotEmpty ? childAccounts.length.toString() : widget.mainAccount.childAccountCount.toString(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blueAccent,
          ),
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
                child: Text('Edit', style: TextStyle(color: Colors.blueAccent)),
                onPressed: () {
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
                              child: MainAccountSheet(mainAccountModel: widget.mainAccount)),
                        );
                      });
                },
              ),
              MenuItemButton(
                leadingIcon: Icon(widget.mainAccount.isHidden ? Icons.visibility : Icons.visibility_off, color: Colors.blueAccent),
                child: Text(widget.mainAccount.isHidden ? 'Show' : 'Hide', style: TextStyle(color: Colors.blueAccent)),
                onPressed: () {
                  mainAccountRepository.hide(widget.mainAccount);
                },
              ),
              MenuItemButton(
                leadingIcon: Icon(Icons.delete, color: Colors.redAccent),
                child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                onPressed: () async {
                  bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Main Account'),
                          content: Text('Are you sure you want to delete ${widget.mainAccount.name}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ) ??
                      false;
                  if (confirm) {
                    await mainAccountRepository.delete(widget.mainAccount);
                  }
                },
              ),
            ],
          ),
          Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
        ],
      ),
      onExpansionChanged: (expanded) {
        setState(() {
          isExpanded = expanded;
        });
        if (expanded && childAccounts.isEmpty) {
          load();
        }
      },
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
        else ...[
          ...childAccounts.map((account) => _buildChildAccountItem(account)).toList(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: _showAddAccountDialog,
              icon: Icon(Icons.add),
              label: Text('Add Account'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildChildAccountItem(AccountModel account) {
    final isPendingRemove = pendingRemoveIds.contains(account.id);
    final isPendingAdd = pendingAddIds.contains(account.id);
    final controller = _progressControllers[account.id];

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isPendingRemove ? Colors.red.withOpacity(0.1) : null,
      clipBehavior: Clip.antiAlias,
      shape: isPendingRemove
          ? RoundedRectangleBorder(
              side: BorderSide(color: Colors.redAccent, width: 1),
              borderRadius: BorderRadius.circular(4))
          : null,
      child: InkWell(
        onTap: () {
          context.go(AccountDetailScreen.fullPath, extra: account);
        },
        child: Column(
          children: [
            ListTile(
              dense: true,
              title: Text(account.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPendingRemove ? Colors.redAccent : null)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPendingRemove || isPendingAdd)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else ...[
                    Text(
                      account.balance % 1 == 0
                          ? account.balance.toStringAsFixed(0)
                          : account.balance.toStringAsFixed(2),
                      style: TextStyle(
                          color: account.balance >= 0
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                  SizedBox(width: 8),
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
                        icon: const Icon(Icons.more_vert, size: 20),
                        tooltip: 'Show menu',
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        leadingIcon: Icon(Icons.add, color: Colors.greenAccent),
                        onPressed: () => _addTransaction(account),
                        child: Text('Add Transaction'),
                      ),
                      MenuItemButton(
                        leadingIcon: Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _editAccount(account),
                        child: Text('Edit Account'),
                      ),
                      MenuItemButton(
                        leadingIcon: Icon(account.isHidden ? Icons.visibility : Icons.visibility_off, color: Colors.orangeAccent),
                        onPressed: () => _hideAccount(account),
                        child: Text(account.isHidden ? 'Show Account' : 'Hide Account'),
                      ),
                      MenuItemButton(
                        leadingIcon: Icon(account.archive ? Icons.unarchive : Icons.archive, color: Colors.pinkAccent),
                        onPressed: () => _archiveAccount(account),
                        child: Text(account.archive ? 'Unarchive' : 'Archive'),
                      ),
                      MenuItemButton(
                        leadingIcon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteAccount(account),
                        child: Text('Delete Account'),
                      ),
                      MenuItemButton(
                        leadingIcon: Icon(Icons.upload_file, color: Colors.blueGrey),
                        onPressed: () => _importTransactions(account),
                        child: Text('Import Transactions'),
                      ),
                      Divider(),
                      MenuItemButton(
                        leadingIcon: Icon(Icons.link_off, color: Colors.redAccent),
                        onPressed: () => _removeAccount(account),
                        child: Text('Unassign from Main'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (controller != null)
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: controller.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isPendingRemove ? Colors.redAccent : Colors.blueAccent),
                    minHeight: 2,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountDialog() {
    var availableAccounts = allAccounts.where((a) => !childAccounts.any((ca) => ca.id == a.id)).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Account to ${widget.mainAccount.name}', style: TextStyle(fontSize: 18)),
        contentPadding: EdgeInsets.symmetric(vertical: 20),
        content: Container(
          width: double.maxFinite,
          child: availableAccounts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('No more accounts available to add.', textAlign: TextAlign.center),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: availableAccounts.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final account = availableAccounts[index];
                    return ListTile(
                      leading: Icon(Icons.account_balance_wallet, color: Colors.blueAccent),
                      title: Text(account.name),
                      trailing: Text(
                        account.balance % 1 == 0
                            ? account.balance.toStringAsFixed(0)
                            : account.balance.toStringAsFixed(2),
                        style: TextStyle(
                            color: account.balance >= 0
                                ? Colors.greenAccent
                                : Colors.redAccent),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _addAccount(account);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Future<void> _addAccount(AccountModel account) async {
    final controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );
    setState(() {
      childAccounts.add(account);
      pendingAddIds.add(account.id);
      _progressControllers[account.id] = controller;
    });
    controller.forward();

    try {
      await mainAccountRepository.addAccountToMain(widget.mainAccount.id, account.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          childAccounts.removeWhere((a) => a.id == account.id);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          pendingAddIds.remove(account.id);
          _progressControllers.remove(account.id);
        });
      }
      controller.dispose();
    }
  }

  Future<void> _removeAccount(AccountModel account) async {
    final controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );
    setState(() {
      pendingRemoveIds.add(account.id);
      _progressControllers[account.id] = controller;
    });
    controller.forward();

    try {
      await mainAccountRepository.removeAccountFromMain(widget.mainAccount.id, account.id);
      if (mounted) {
        setState(() {
          childAccounts.removeWhere((a) => a.id == account.id);
        });
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          pendingRemoveIds.remove(account.id);
          _progressControllers.remove(account.id);
        });
      }
      controller.dispose();
    }
  }

  void _addTransaction(AccountModel account) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        builder: (context) {
          return SizedBox(
            height: 420,
            child: AnimatedPadding(
                padding: MediaQuery.of(context).viewInsets,
                duration: Duration(seconds: 1),
                child: AddTransactionSheet(account)),
          );
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

  Future<void> _hideAccount(AccountModel account) async {
    await accountRepository.hide(account);
  }

  Future<void> _archiveAccount(AccountModel account) async {
    await accountRepository.archive(account);
  }

  Future<void> _deleteAccount(AccountModel account) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Account'),
            content: Text('Are you sure you want to delete ${account.name}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await accountRepository.delete(account);
        if (mounted) {
          setState(() {
            childAccounts.removeWhere((a) => a.id == account.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${account.name} deleted')));
        }
      } catch (e) {
      }
    }
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
