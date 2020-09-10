import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/dropdown.component.dart';
import 'package:home_management_app/custom/input.factory.dart';
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
  Function onAddPressed = null;


  @override
  void initState() {
    super.initState();
    this.keyboardFactory = KeyboardFactory(context: context);
    currencies.addAll(this.currencyRepository.currencies.map((c) => c.name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Account'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: accountNameTextField(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: accountTypeDropDown(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: currencyTypeDropDown(),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
            ),
            Expanded(
              flex: this.keyboardFactory.isKeyboardVisible() ? 1 : 5,
              child: SizedBox()
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: OutlineButton(                  
                  onPressed: onAddPressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      Text('Add')
                    ],
                  ),
                ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget accountNameTextField() {
    return TextField(
        keyboardType: TextInputType.name,
        textAlign: TextAlign.center,
        decoration:
            InputFactory.createdRoundedOutLineDecoration('Account Name'),
        onChanged: (value){
          setState(() {
            this.enableButton = value.length > 0;
            this.onAddPressed = this.enableButton ? addNewAccount : null;
            this.accountName = value;
          });
        },
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
      this.accountType = accountType == 'Cash' ? AccountType.Cash : AccountType.BankAccount;
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

  void addNewAccount(){
    AccountModel accountModel = AccountModel(0, this.accountName, 0, this.isMeasurable, this.accountType, this.currencyId, 0);
    this.accountsRepository.add(accountModel);
    Navigator.pop(context);
  }
}
