import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../services/repositories/account.repository.dart';
import '../../../services/transaction_paging_service.dart';

class AccountDialogSelection extends StatefulWidget {
  const AccountDialogSelection({super.key});

  @override
  State<AccountDialogSelection> createState() => _AccountDialogSelectionState();
}

class _AccountDialogSelectionState extends State<AccountDialogSelection> {
  AccountRepository _accountRepository = GetIt.I<AccountRepository>();
  TransactionPagingService _transactionPagingService = GetIt.I<TransactionPagingService>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('TODO modal for selecting multiple accounts'),
      content :
      SizedBox(
        height: 400,
        width: 200,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _accountRepository.accounts.length,
          itemBuilder: (context, index) {
            var account = _accountRepository.accounts[index];

            var isSelected = _transactionPagingService.selectedAccounts.any((element) => element.id == account.id);

            return CheckboxListTile(
              title: Text(account.name),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (isSelected)
                    _transactionPagingService.selectedAccounts.remove(account);
                  else
                    _transactionPagingService.selectedAccounts.add(account);
                  _transactionPagingService.dispatchRefresh();
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text('ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
