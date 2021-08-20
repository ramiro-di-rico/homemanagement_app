import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';

class AccountAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar _appBar = new AppBar();
  final List<Widget> actions;
  final AccountModel account;
  AccountAppBar({this.account, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(account.name.length > 15
                ? account.name.substring(0, 15) + '...'
                : account.name),
          ],
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(_appBar.preferredSize.height);
}
