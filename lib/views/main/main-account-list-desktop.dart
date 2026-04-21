import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/main_account.dart';
import 'package:home_management_app/services/repositories/main_account.repository.dart';
import 'widgets/main_account_expansion_tile.dart';
import 'main_account.detail.dart';
import 'widgets/main_account.sheet.dart';

class MainAccountListDesktopView extends StatefulWidget {
  @override
  _MainAccountListDesktopViewState createState() => _MainAccountListDesktopViewState();
}

class _MainAccountListDesktopViewState extends State<MainAccountListDesktopView> {
  List<MainAccountModel> mainAccounts = [];
  MainAccountRepository mainAccountsRepo = GetIt.instance<MainAccountRepository>();
  bool showHidden = false;

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
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  tooltip: showHidden
                      ? 'Show all main accounts'
                      : 'Hide main accounts',
                  icon: Icon(
                      showHidden ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      mainAccountsRepo.displayHidden(!showHidden);
                      showHidden = !showHidden;
                    });
                  },
                ),
                Text(
                  'Main Accounts',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(width: 12),
                Spacer(),
                IconButton(
                  tooltip: 'Add main account',
                  icon: Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        constraints: BoxConstraints(
                          maxHeight: 500,
                          maxWidth: 1200,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0))),
                        builder: (context) {
                          return SizedBox(
                            height: 250,
                            child: AnimatedPadding(
                                padding: MediaQuery.of(context).viewInsets,
                                duration: Duration(seconds: 1),
                                child: MainAccountSheet()),
                          );
                        });
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: refreshMainAccounts,
            child: ListView.builder(
              itemCount: mainAccounts.length,
              itemBuilder: (context, index) {
                final item = mainAccounts[index];

                return MainAccountExpansionTile(mainAccount: item);
              },
            ),
          ),
        ),
      ],
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
