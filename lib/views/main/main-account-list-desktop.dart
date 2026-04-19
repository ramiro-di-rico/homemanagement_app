import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/main_account.dart';
import 'package:home_management_app/services/repositories/main_account.repository.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    load();
    mainAccountsRepo.addListener(load);
    mainAccountsRepo.load();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    mainAccountsRepo.removeListener(load);
    _searchController.dispose();
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
    final List<MainAccountModel> visibleAccounts = _query.trim().isEmpty
        ? mainAccounts
        : mainAccounts
            .where((a) => a.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search main accounts',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
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
        SingleChildScrollView(
          child: Container(
            height: 330,
            child: RefreshIndicator(
              onRefresh: refreshMainAccounts,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: visibleAccounts.length,
                itemBuilder: (context, index) {
                  final item = visibleAccounts[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        item.name,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              item.childAccountCount.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
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
                                tooltip: 'Show menu',
                              );
                            },
                            menuChildren: [
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
                                              child: MainAccountSheet(mainAccountModel: item)),
                                        );
                                      });
                                },
                              ),
                              MenuItemButton(
                                leadingIcon: Icon(item.isHidden ? Icons.visibility : Icons.visibility_off, color: Colors.blueAccent),
                                child: Text(item.isHidden ? 'Show' : 'Hide',
                                    style: TextStyle(color: Colors.blueAccent)),
                                onPressed: () {
                                  mainAccountsRepo.hide(item);
                                },
                              ),
                              MenuItemButton(
                                leadingIcon: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                child: Text('Delete',
                                    style: TextStyle(color: Colors.redAccent)),
                                onPressed: () async {
                                  await remove(item);
                                },
                              ),
                            ],
                          ),
                        ],
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
                  );
                },
              ),
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
