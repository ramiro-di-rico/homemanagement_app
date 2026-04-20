import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/main_account.dart';
import 'package:home_management_app/services/repositories/main_account.repository.dart';
import 'package:home_management_app/views/main/widgets/main_account_expansion_tile.dart';
import 'main_account.detail.dart';
import 'widgets/main_account.sheet.dart';

class MainAccountListScreen extends StatefulWidget {
  @override
  _MainAccountListScreenState createState() => _MainAccountListScreenState();
}

class _MainAccountListScreenState extends State<MainAccountListScreen> {
  List<MainAccountModel> mainAccounts = [];
  MainAccountRepository mainAccountsRepo = GetIt.instance<MainAccountRepository>();

  @override
  void initState() {
    super.initState();
    load();
    mainAccountsRepo.addListener(load);
    mainAccountsRepo.load();
  }

  @override
  void dispose() {
    mainAccountsRepo.removeListener(load);
    super.dispose();
  }

  load() {
    if (mounted) {
      setState(() {
        this.mainAccounts = mainAccountsRepo.mainAccounts;
      });
    }
  }

  Future refreshMainAccounts() async {
    await mainAccountsRepo.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshMainAccounts,
      child: ListView.builder(
        itemCount: this.mainAccounts.length,
        itemBuilder: (context, index) {
          final item = this.mainAccounts[index];

          return MainAccountExpansionTile(mainAccount: item);
        },
      ),
    );
  }

  Future remove(MainAccountModel item) async {
    try {
      await this.mainAccountsRepo.delete(item);
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
}
