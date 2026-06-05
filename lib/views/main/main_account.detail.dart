import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/main_account.dart';
import 'package:home_management_app/services/endpoints/transaction.service.dart';
import 'package:home_management_app/services/repositories/account.repository.dart';
import 'package:home_management_app/services/repositories/main_account.repository.dart';
import 'package:home_management_app/views/accounts/account.detail.dart';
import 'package:home_management_app/views/accounts/widgets/add.transaction.sheet.dart';
import 'package:home_management_app/views/main/widgets/account.sheet.dart';
import 'package:home_management_app/views/mixins/notifier_mixin.dart';
import 'package:file_picker/file_picker.dart';

class MainAccountDetailScreen extends StatefulWidget {
  final MainAccountModel mainAccount;

  MainAccountDetailScreen({required this.mainAccount});

  @override
  _MainAccountDetailScreenState createState() => _MainAccountDetailScreenState();
}

class _MainAccountDetailScreenState extends State<MainAccountDetailScreen>
    with NotifierMixin, TickerProviderStateMixin {
  MainAccountRepository mainAccountRepository = GetIt.I<MainAccountRepository>();
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  TransactionService transactionService = GetIt.I<TransactionService>();
  List<AccountModel> childAccounts = [];
  List<AccountModel> allAccounts = [];
  bool isLoading = true;

  Set<int> pendingAddIds = {};
  Set<int> pendingRemoveIds = {};

  // Maps account ID to its progress animation controller
  final Map<int, AnimationController> _progressControllers = {};

  @override
  void initState() {
    accountRepository.addListener(_onAccountRepositoryChanged);
    allAccounts = accountRepository.getAllAccounts();
    if (widget.mainAccount.childAccounts.isNotEmpty) {
      childAccounts = widget.mainAccount.childAccounts;
      isLoading = false;
    } else {
      load();
    }
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
         // Update childAccounts with the latest account data from the repository
         childAccounts = childAccounts.map((childAccount) {
           final updatedAccount = allAccounts.firstWhere(
             (account) => account.id == childAccount.id,
             orElse: () => childAccount,
           );
           return updatedAccount;
         }).toList();
       });
     }
   }

  Future<void> load() async {
    setState(() {
      isLoading = true;
    });
    try {
      var children = await mainAccountRepository.getAccounts(widget.mainAccount.id);
      await accountRepository.load();
      if (mounted) {
        setState(() {
          childAccounts = children;
          allAccounts = accountRepository.getAllAccounts();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mainAccount.name),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: isLoading ? null : _showAddAccountDialog,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : childAccounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No accounts assigned yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showAddAccountDialog,
                        child: Text(AppLocalizations.of(context)!.addAccount),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: childAccounts.length,
            itemBuilder: (context, index) {
              final account = childAccounts[index];
              final isPendingRemove = pendingRemoveIds.contains(account.id);
              final isPendingAdd = pendingAddIds.contains(account.id);
              final controller = _progressControllers[account.id];

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: isPendingRemove ? Colors.red.withOpacity(0.1) : null,
                clipBehavior: Clip.antiAlias,
                shape: isPendingRemove
                    ? RoundedRectangleBorder(
                        side: BorderSide(color: Colors.redAccent, width: 1),
                        borderRadius: BorderRadius.circular(4))
                    : null,
                child: InkWell(
                  onLongPress: () {
                    context.go(AccountDetailScreen.fullPath, extra: account);
                  },
                  onTap: () {
                    context.go(AccountDetailScreen.fullPath, extra: account);
                  },
                  child: Column(
                    children: [
                      ListTile(
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
                                  tooltip: AppLocalizations.of(context)!.showMenu,
                                );
                              },
                              menuChildren: [
                                MenuItemButton(
                                    leadingIcon: Icon(Icons.add, color: Colors.greenAccent),
                                    child: Text(AppLocalizations.of(context)!.addTransaction,
                                        style: TextStyle(color: Colors.greenAccent)),
                                    onPressed: () => _addTransaction(account)),
                                MenuItemButton(
                                  leadingIcon: Icon(Icons.edit, color: Colors.blueAccent),
                                  child: Text(AppLocalizations.of(context)!.editAccount,
                                      style: TextStyle(color: Colors.blueAccent)),
                                  onPressed: () => _editAccount(account),
                                ),
                                MenuItemButton(
                                  leadingIcon: Icon(account.isHidden ? Icons.visibility : Icons.visibility_off, color: Colors.blueAccent),
                                  child: Text(account.isHidden ? AppLocalizations.of(context)!.show : AppLocalizations.of(context)!.hide,
                                      style: TextStyle(color: Colors.blueAccent)),
                                  onPressed: () => _hideAccount(account),
                                ),
                                MenuItemButton(
                                  leadingIcon: Icon(Icons.archive, color: Colors.pinkAccent),
                                  child: Text(account.archive ? AppLocalizations.of(context)!.unarchive : AppLocalizations.of(context)!.archive,
                                      style: TextStyle(color: Colors.pinkAccent)),
                                  onPressed: () => _archiveAccount(account),
                                ),
                                MenuItemButton(
                                  leadingIcon: Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  child: Text(AppLocalizations.of(context)!.delete,
                                      style: TextStyle(color: Colors.redAccent)),
                                  onPressed: () => _deleteAccount(account),
                                ),
                                MenuItemButton(
                                  leadingIcon: Icon(Icons.upload, color: Colors.orangeAccent),
                                  child: Text(AppLocalizations.of(context)!.importTransactions,
                                      style: TextStyle(color: Colors.orangeAccent)),
                                  onPressed: () => _importTransactions(account),
                                ),
                                Divider(),
                                MenuItemButton(
                                  leadingIcon: Icon(Icons.remove_circle_outline, color: Colors.red),
                                  child: Text(AppLocalizations.of(context)!.unassign,
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () => _removeAccount(account),
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
            },
            ),
    );
  }

  void _showAddAccountDialog() {
    // Filter out accounts already in this main account
    var availableAccounts = allAccounts.where((a) => !childAccounts.any((ca) => ca.id == a.id)).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addAccountTo(widget.mainAccount.name), style: TextStyle(fontSize: 18)),
        contentPadding: EdgeInsets.symmetric(vertical: 20),
        content: Container(
          width: double.maxFinite,
          child: availableAccounts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(AppLocalizations.of(context)!.noMoreAccountsAvailable, textAlign: TextAlign.center),
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
            child: Text(AppLocalizations.of(context)!.close),
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
      // Error is handled by repository and NotifierMixin
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
            title: Text(AppLocalizations.of(context)!.deleteAccount),
            content: Text(AppLocalizations.of(context)!.areYouSureDelete(account.name)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red))),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.deleted(account.name))));
        }
      } catch (e) {
        // Error handled by repository
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
