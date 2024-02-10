import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/views/main/account.list.dart';

import '../../services/repositories/account.repository.dart';
import '../../services/repositories/category.repository.dart';
import '../../services/repositories/currency.repository.dart';
import 'dashboard.dart';

class HomeDesktop extends StatefulWidget {
  const HomeDesktop({super.key});

  @override
  State<HomeDesktop> createState() => _HomeDesktopState();
}

class _HomeDesktopState extends State<HomeDesktop> {
  @override
  void initState() {
    super.initState();
    AccountRepository accountRepository = GetIt.instance<AccountRepository>();
    accountRepository.load();
    GetIt.I<CurrencyRepository>().load();
    GetIt.I<CategoryRepository>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Management'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: 1000,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(flex: 1, child: Dashboard()),
                    Flexible(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Card(
                              child: ListTile(
                                  title: Text(
                                'Accounts',
                                style: TextStyle(fontSize: 20),
                              )),
                            ),
                            AccountListScreen(),
                          ],
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
