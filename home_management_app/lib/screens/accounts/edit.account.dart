import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/dropdown.component.dart';
import 'package:home_management_app/custom/input.factory.dart';
import 'package:home_management_app/custom/keyboard.factory.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/currency.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:home_management_app/repositories/currency.repository.dart';

class EditAccountScreen extends StatefulWidget {
  final AccountModel account;
  EditAccountScreen({this.account});

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  AccountRepository accountsRepository = GetIt.instance<AccountRepository>();
  CurrencyRepository currencyRepository = GetIt.I<CurrencyRepository>();
  KeyboardFactory keyboardFactory;
  TextEditingController controller;
  List<String> accountTypes = ['Cash', 'Bank Account'];
  List<CurrencyModel> currencies = [];
  bool enableButton = false;
  Function onSubmitPressed = null;

  @override
  void initState() {
    super.initState();
    this.keyboardFactory = KeyboardFactory(context: context);
    currencies.addAll(this.currencyRepository.currencies);
    controller = TextEditingController(text: widget.account.name);
    controller.addListener(onTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.account.name}'),
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
                      value: widget.account.measurable,
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
                child: SizedBox()),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: OutlineButton(
                  onPressed: onSubmitPressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.check), Text('Submit')],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(onTextChanged);
    controller.dispose();
    super.dispose();
  }

  Widget accountNameTextField() {
    return TextField(
      keyboardType: TextInputType.name,
      textAlign: TextAlign.center,
      controller: controller,
      decoration: InputFactory.createdRoundedOutLineDecoration('Account Name'),
    );
  }

  onTextChanged() {
    setState(() {
      this.enableButton = controller.text.length > 0;
      this.onSubmitPressed = this.enableButton ? submit : null;
      widget.account.name = controller.text;
    });
  }

  Widget accountTypeDropDown() {
    return DropdownComponent(
      items: accountTypes,
      onChanged: onAccountTypeChanged,
      currentValue: widget.account.accountType == AccountType.Cash ? accountTypes[0] : accountTypes[1],
    );
  }

  onAccountTypeChanged(String accountType) {
    setState(() {
      this.widget.account.accountType =
          accountType == 'Cash' ? AccountType.Cash : AccountType.BankAccount;
    });
  }

  Widget currencyTypeDropDown() {
    return DropdownComponent(
      items: currencies.map((e) => e.name).toList(),
      onChanged: onCurrencyTypeChanged,
      currentValue: currencies.firstWhere((element) => element.id == widget.account.currencyId).name,
    );
  }

  onCurrencyTypeChanged(String currency) {
    setState(() {
      var currency = this.currencies.firstWhere((element) => element.id == widget.account.currencyId);
      this.widget.account.currencyId = currency.id;
    });
  }

  onMeasurableChanged(bool value) {
    setState(() {
      this.widget.account.measurable = value;
    });
  }

  void submit() {
    this.accountsRepository.update(widget.account);
    Navigator.pop(context);
  }
}
