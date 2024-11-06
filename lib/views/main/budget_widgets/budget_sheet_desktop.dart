import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/views/main/widgets/category_select/category_select.dart';

import '../../../models/budget.dart';
import '../../../models/currency.dart';
import '../../../services/repositories/budget_repository.dart';
import '../widgets/account_select/account_select.dart';

class BudgetSheetDesktop extends StatefulWidget {
  final BudgetModel? budget;

  BudgetSheetDesktop({this.budget});

  @override
  State<BudgetSheetDesktop> createState() => _BudgetSheetDesktopState();
}

class _BudgetSheetDesktopState extends State<BudgetSheetDesktop> {
  BudgetRepository _budgetRepository = GetIt.I.get<BudgetRepository>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  List<CurrencyModel> currencies = [];
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.budget != null;
    _nameController.text = widget.budget!.name;
    _amountController.text = widget.budget!.amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          SizedBox(width: 50),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: _nameController,
            ),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 150,
            child: TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              controller: _amountController,
            ),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 200,
            child: AccountSelect(
              multipleSelection: false,
              //accounts: _budgetRepository.accounts,
              //selectedAccount: widget.budget?.account,
              onSelectedAccountsChanged: (accounts) {
                //widget.budget.account = accounts.first;
              },
            ),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 200,
            child: CategorySelect(
                multipleSelection: false,
                onSelectedCategoriesChanged: (categories){

                }),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 100,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Save the budget
              },
              child: Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
