import 'package:flutter/material.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

class TransactionProjectionOptionsSheet extends StatefulWidget {
  final int initialLookbackMonths;
  final int? initialAccountId;
  final List<AccountModel> accounts;
  final Function(int lookbackMonths, int? accountId) onApply;

  const TransactionProjectionOptionsSheet({
    super.key,
    required this.initialLookbackMonths,
    required this.initialAccountId,
    required this.accounts,
    required this.onApply,
  });

  @override
  State<TransactionProjectionOptionsSheet> createState() =>
      _TransactionProjectionOptionsSheetState();
}

class _TransactionProjectionOptionsSheetState
    extends State<TransactionProjectionOptionsSheet> {
  static const List<int> _lookbackMonthsOptions = [3, 6, 9, 12, 18, 24];

  late int lookbackMonths;
  late int? accountId;

  @override
  void initState() {
    super.initState();
    lookbackMonths = widget.initialLookbackMonths;
    // Only keep the initial account selection if it still exists in the
    // current account list; otherwise fall back to "all accounts" so the
    // dropdown never gets a value that isn't among its items.
    accountId = widget.accounts.any((account) => account.id == widget.initialAccountId)
        ? widget.initialAccountId
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(localizations.selectAccount),
            trailing: DropdownButton<int?>(
              value: accountId,
              onChanged: (int? newValue) {
                setState(() {
                  accountId = newValue;
                });
              },
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(localizations.allAccounts),
                ),
                ...widget.accounts.map((account) => DropdownMenuItem<int?>(
                      value: account.id,
                      child: Text(account.name),
                    )),
              ],
            ),
          ),
          ListTile(
            title: Text(localizations.lookbackMonths),
            trailing: DropdownButton<int>(
              value: lookbackMonths,
              onChanged: (int? newValue) {
                setState(() {
                  lookbackMonths = newValue!;
                });
              },
              items: _lookbackMonthsOptions
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onApply(lookbackMonths, accountId);
              Navigator.pop(context);
            },
            child: Text(localizations.apply),
          ),
        ],
      ),
    );
  }
}
