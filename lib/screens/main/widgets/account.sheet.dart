import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/app-textfield.dart';
import '../../../custom/components/dropdown.component.dart';
import '../../../custom/keyboard.factory.dart';
import '../../../models/account.dart';
import '../../../repositories/account.repository.dart';
import '../../../repositories/currency.repository.dart';

class AccountSheet extends StatefulWidget {
  const AccountSheet({Key key, AccountModel accountModel}) : super(key: key);

  @override
  State<AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends State<AccountSheet> {
  AccountRepository accountsRepository = GetIt.instance<AccountRepository>();
  CurrencyRepository currencyRepository = GetIt.I<CurrencyRepository>();
  KeyboardFactory keyboardFactory;

  String accountName = '';
  AccountType accountType;
  int currencyId;
  bool isMeasurable = false;

  List<String> currencies = [];
  bool enableButton = false;

  @override
  void initState() {
    super.initState();
    this.keyboardFactory = KeyboardFactory(context: context);
    currencies.addAll(this.currencyRepository.currencies.map((c) => c.name));
    this.currencyId = this.currencyRepository.currencies.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.all(8),
              child: AppTextField(
                label: 'Account Name',
                onTextChanged: (value) {
                  setState(() {
                    this.enableButton = value.length > 0;
                    this.accountName = value;
                  });
                },
              )),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: accountTypeDropDown(),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: currencyTypeDropDown(),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Checkbox(
                  value: isMeasurable,
                  onChanged: onMeasurableChanged,
                ),
                Expanded(
                  child: Text('Is Measurable'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget accountTypeDropDown() {
    return DropdownComponent(
      items: ['Cash', 'Bank Account'],
      onChanged: onAccountTypeChanged,
    );
  }

  onAccountTypeChanged(String accountType) {
    setState(() {
      this.accountType =
          accountType == 'Cash' ? AccountType.Cash : AccountType.BankAccount;
    });
  }

  Widget currencyTypeDropDown() {
    return DropdownComponent(
      items: currencies,
      onChanged: onCurrencyTypeChanged,
    );
  }

  onCurrencyTypeChanged(String currency) {
    setState(() {
      this.currencyId = this.currencies.indexOf(currency);
    });
  }

  onMeasurableChanged(bool value) {
    setState(() {
      this.isMeasurable = value;
    });
  }

  void addNewAccount() {
    AccountModel accountModel = AccountModel(0, this.accountName, 0,
        this.isMeasurable, this.accountType, this.currencyId, 0, false);
    this.accountsRepository.add(accountModel);
    Navigator.pop(context);
  }
}
