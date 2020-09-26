import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/app-textfield.dart';
import 'package:home_management_app/custom/components/dropdown.component.dart';
import 'package:home_management_app/custom/keyboard.factory.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:home_management_app/repositories/currency.repository.dart';

class AddAccountScreen extends StatefulWidget {
  static const String id = 'add_account_screen';

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  AccountRepository accountsRepository = GetIt.instance<AccountRepository>();
  CurrencyRepository currencyRepository = GetIt.I<CurrencyRepository>();
  KeyboardFactory keyboardFactory;

  String accountName = '';
  AccountType accountType;
  int currencyId;
  bool isMeasurable = false;

  List<String> currencies = [];
  bool enableButton = false;
  FloatingActionButton onSubmitFloatingButton = null;

  @override
  void initState() {
    super.initState();
    this.keyboardFactory = KeyboardFactory(context: context);
    currencies.addAll(this.currencyRepository.currencies.map((c) => c.name));
    this.currencyId = this.currencyRepository.currencies.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: onSubmitFloatingButton,
      appBar: AppBar(
        title: Text('Add Account'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildFirstRow(),
            buildSecondRow(),
            buildThirdRow(),
          ],
        ),
      ),
    );
  }

  Padding buildFirstRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: AppTextField(
        label: 'Account Name',
        onTextChanged: (value) {
          setState(() {
            this.enableButton = value.length > 0;
            this.onSubmitFloatingButton =
                this.enableButton ? createSubmitButton() : null;
            this.accountName = value;
          });
        },
      )
    );
  }

  Padding buildSecondRow() {
    return Padding(
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
    );
  }

  Padding buildThirdRow() {
    return Padding(
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
        this.isMeasurable, this.accountType, this.currencyId, 0);
    this.accountsRepository.add(accountModel);
    Navigator.pop(context);
  }

  FloatingActionButton createSubmitButton() => FloatingActionButton(
        onPressed: addNewAccount,
        child: Icon(Icons.check),
      );
}
