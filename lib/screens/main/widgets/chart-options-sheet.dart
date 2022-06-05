import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/extensions/datehelper.dart';

import '../../../custom/components/dropdown.component.dart';
import '../../../repositories/account.repository.dart';

// ignore: must_be_immutable
class ChartOptionsSheet extends StatefulWidget {
  String selectedAccount;
  int selectedMonth;
  Function(String, int) onChange;
  ChartOptionsSheet(this.selectedAccount, this.selectedMonth, this.onChange,
      {Key key})
      : super(key: key);

  @override
  State<ChartOptionsSheet> createState() => _ChartOptionsSheetState();
}

class _ChartOptionsSheetState extends State<ChartOptionsSheet> {
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  List<String> accounts = ["All Accounts"];
  String selectedAccount = "All Accounts";
  int selectedMonth = 0;
  List<String> months = [
    DateTime.january.toMonthName(),
    DateTime.february.toMonthName(),
    DateTime.march.toMonthName(),
    DateTime.april.toMonthName(),
    DateTime.may.toMonthName(),
    DateTime.june.toMonthName(),
    DateTime.july.toMonthName(),
    DateTime.august.toMonthName(),
    DateTime.september.toMonthName(),
    DateTime.october.toMonthName(),
    DateTime.november.toMonthName(),
    DateTime.december.toMonthName()
  ];

  @override
  Widget build(BuildContext context) {
    selectedMonth = widget.selectedMonth;
    selectedAccount = widget.selectedAccount;
    accounts.addAll(accountRepository.accounts.map((x) => x.name).toList());
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownComponent(
                items: accounts,
                onChanged: (accountName) async {
                  selectedAccount = accountName;
                },
                currentValue: selectedAccount),
            DropdownComponent(
                items: months,
                onChanged: (month) async {
                  selectedMonth = months.indexOf(month);
                },
                currentValue: months[selectedMonth]),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            widget.onChange.call(selectedAccount, selectedMonth);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(40),
          ),
          child: Icon(
            Icons.check,
            color: Colors.greenAccent,
          ),
        ),
      ),
    ]);
  }
}
