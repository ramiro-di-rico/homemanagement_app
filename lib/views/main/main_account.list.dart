import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/main_account.dart';
import 'package:home_management_app/services/repositories/main_account.repository.dart';
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
        shrinkWrap: true,
        itemCount: this.mainAccounts.length,
        itemBuilder: (context, index) {
          final item = this.mainAccounts[index];

          return Slidable(
            startActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: ((context) => {
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
                                child: MainAccountSheet(mainAccountModel: item)),
                          );
                        })
                  }),
                  icon: Icons.edit,
                  backgroundColor: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                SlidableAction(
                  onPressed: (context) async {
                    await mainAccountsRepo.hide(item);
                  },
                  icon: item.isHidden ? Icons.visibility : Icons.visibility_off,
                  backgroundColor: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                SlidableAction(
                  onPressed: (context) async => await remove(item),
                  icon: Icons.delete,
                  backgroundColor: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(
                  item.name,
                ),
                trailing: Chip(
                  label: Text(
                    item.childAccountCount.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainAccountDetailScreen(mainAccount: item),
                    ),
                  );
                },
              ),
            ),
          );
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
