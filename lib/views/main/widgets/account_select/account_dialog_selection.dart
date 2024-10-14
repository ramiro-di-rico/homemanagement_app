import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../models/account.dart';
import '../../../../services/repositories/account.repository.dart';
import 'account_select_model.dart';

class AccountDialogSelection extends StatefulWidget {
  final Function(List<AccountSelectModel>) onSelectedAccountsChanged;
  final bool multipleSelection;
  final List<AccountModel> selectedAccounts;

  AccountDialogSelection({
    required this.onSelectedAccountsChanged,
    this.multipleSelection = false,
    this.selectedAccounts = const [],
  });

  @override
  State<AccountDialogSelection> createState() => _AccountDialogSelectionState();
}

class _AccountDialogSelectionState extends State<AccountDialogSelection> {
  List<AccountSelectModel> _allAccounts = [];
  AccountRepository _accountRepository = GetIt.I<AccountRepository>();
  AccountSelectModel? _selectedAccount;

  @override
  void initState() {
    super.initState();

    if (widget.selectedAccounts.isNotEmpty) {
      _allAccounts.addAll(_accountRepository.accounts
          .map((account) => AccountSelectModel(account, false))
          .toList());
      for (var account in widget.selectedAccounts) {
        for (var accountModel in _allAccounts) {
          if (account.id == accountModel.account.id) {
            accountModel.isSelected = true;
            _selectedAccount = accountModel;
          }
        }
      }
    } else {
      _allAccounts.addAll(_accountRepository.accounts
          .map((account) => AccountSelectModel(account, false))
          .toList());
      _selectedAccount = _allAccounts.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.multipleSelection ? 'Select accounts' : 'Select account'),
      content: SizedBox(
        height: 400,
        width: 200,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _allAccounts.length,
          itemBuilder: (context, index) {
            var selectedAccount = _allAccounts[index];

            return widget.multipleSelection
                ? CheckboxListTile(
                    title: Text(selectedAccount.account.name),
                    value: selectedAccount.isSelected,
                    onChanged: (value) {
                      setState(() {
                        for (var account in _allAccounts) {
                          if (account.account.id ==
                              selectedAccount.account.id) {
                            account.isSelected = value!;
                          }
                        }
                        widget.onSelectedAccountsChanged(_allAccounts
                            .where((account) => account.isSelected)
                            .toList());
                      });
                    },
                  )
                : RadioListTile(
                    title: Text(selectedAccount.account.name),
                    value: selectedAccount,
                    groupValue: _selectedAccount,
                    onChanged: (value) {
                      setState(() {
                        _selectedAccount = value;
                        widget.onSelectedAccountsChanged([selectedAccount]);
                        Navigator.of(context).pop();
                      });
                    },
                  );
          },
        ),
      ),
      actions: widget.multipleSelection ? [
        TextButton(
          child: Text('ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ] : [],
    );
  }
}
