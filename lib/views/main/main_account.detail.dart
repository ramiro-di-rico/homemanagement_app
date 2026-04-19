import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/main_account.dart';
import 'package:home_management_app/services/repositories/account.repository.dart';
import 'package:home_management_app/services/repositories/main_account.repository.dart';

class MainAccountDetailScreen extends StatefulWidget {
  final MainAccountModel mainAccount;

  MainAccountDetailScreen({required this.mainAccount});

  @override
  _MainAccountDetailScreenState createState() => _MainAccountDetailScreenState();
}

class _MainAccountDetailScreenState extends State<MainAccountDetailScreen> {
  MainAccountRepository mainAccountRepository = GetIt.I<MainAccountRepository>();
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  List<AccountModel> childAccounts = [];
  List<AccountModel> allAccounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
    });
    var accounts = await mainAccountRepository.getAccounts(widget.mainAccount.id);
    await accountRepository.load();
    setState(() {
      childAccounts = accounts;
      allAccounts = accountRepository.getAllAccounts();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mainAccount.name),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddAccountDialog,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: childAccounts.length,
              itemBuilder: (context, index) {
                final account = childAccounts[index];
                return ListTile(
                  title: Text(account.name),
                  subtitle: Text(account.balance.toString()),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () => _removeAccount(account),
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
        title: Text('Add Account to ${widget.mainAccount.name}'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableAccounts.length,
            itemBuilder: (context, index) {
              final account = availableAccounts[index];
              return ListTile(
                title: Text(account.name),
                onTap: () {
                  Navigator.pop(context);
                  _addAccount(account);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _addAccount(AccountModel account) async {
    await mainAccountRepository.addAccountToMain(widget.mainAccount.id, account.id);
    load();
  }

  Future<void> _removeAccount(AccountModel account) async {
    await mainAccountRepository.removeAccountFromMain(widget.mainAccount.id, account.id);
    load();
  }
}
