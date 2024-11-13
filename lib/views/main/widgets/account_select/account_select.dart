import 'package:flutter/material.dart';

import '../../../../models/account.dart';
import 'account_dialog_selection.dart';
import 'account_select_model.dart';

class AccountSelect extends StatefulWidget {
  final Function(List<AccountSelectModel>) onSelectedAccountsChanged;
  final bool multipleSelection;
  final List<AccountModel> selectedAccounts;

  AccountSelect({
    required this.onSelectedAccountsChanged,
    this.multipleSelection = false,
    this.selectedAccounts = const [],
  });

  @override
  State<AccountSelect> createState() => _AccountSelectState();
}

class _AccountSelectState extends State<AccountSelect> {
  TextEditingController _selectedAccountsTextEditingController =
      TextEditingController();

  List<AccountModel> _selectedAccounts = [];

  @override
  void initState() {
    super.initState();
    _selectedAccounts.addAll(widget.selectedAccounts);
    _selectedAccountsTextEditingController.text =
        _selectedAccounts.map((account) => account.name).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: this.context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AccountDialogSelection(
                onSelectedAccountsChanged: (selectedAccounts) {
                  _selectedAccounts = selectedAccounts.where((a) => a.isSelected).map((account) => account.account).toList();
                  widget.onSelectedAccountsChanged(selectedAccounts);
                  _selectedAccountsTextEditingController.text = selectedAccounts
                      .map((account) => account.account.name)
                      .join(', ');
                },
                multipleSelection: widget.multipleSelection,
                selectedAccounts: _selectedAccounts,
              );
            });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  enabled: false,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.labelLarge?.color),
                  controller: _selectedAccountsTextEditingController,
                  decoration: InputDecoration(
                    labelText: widget.multipleSelection
                        ? 'Select accounts'
                        : 'Select account',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: this.context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AccountDialogSelection(
                            onSelectedAccountsChanged: (selectedAccounts) {
                              widget
                                  .onSelectedAccountsChanged(selectedAccounts);
                              _selectedAccountsTextEditingController.text =
                                  selectedAccounts
                                      .map((account) => account.account.name)
                                      .join(', ');
                            },
                            multipleSelection: widget.multipleSelection,
                            selectedAccounts: _selectedAccounts,
                          );
                        });
                  },
                  icon: Icon(widget.multipleSelection
                      ? Icons.view_list
                      : Icons.arrow_drop_down))
            ],
          ),
        ),
      ),
    );
  }
}
