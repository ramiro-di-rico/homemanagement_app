import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/app-textfield.dart';
import 'package:home_management_app/custom/components/dropdown.component.dart';
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
  FloatingActionButton onSubmitFloatingButton;

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
      floatingActionButton: onSubmitFloatingButton,
      appBar: AppBar(
        title: Text('Edit ${widget.account.name}'),
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
      padding: EdgeInsets.all(10),
      child: AppTextField(
        label: 'Account Name',
        editingController: controller,
      ),
    );
  }

  Padding buildSecondRow() {
    return Padding(
      padding: const EdgeInsets.all(10),
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
    );
  }

  Padding buildThirdRow() {
    return Padding(
      padding: EdgeInsets.all(20),
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
    );
  }

  @override
  void dispose() {
    controller.removeListener(onTextChanged);
    controller.dispose();
    super.dispose();
  }

  onTextChanged() {
    setState(() {
      this.enableButton = controller.text.length > 0;
      this.onSubmitFloatingButton =
          this.enableButton ? createSubmitButton() : null;
      widget.account.name = controller.text;
    });
  }

  Widget accountTypeDropDown() {
    return DropdownComponent(
      items: accountTypes,
      onChanged: onAccountTypeChanged,
      currentValue: widget.account.accountType == AccountType.Cash
          ? accountTypes[0]
          : accountTypes[1],
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
      currentValue: currencies
          .firstWhere((element) => element.id == widget.account.currencyId)
          .name,
    );
  }

  onCurrencyTypeChanged(String currency) {
    setState(() {
      var currency = this
          .currencies
          .firstWhere((element) => element.id == widget.account.currencyId);
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

  FloatingActionButton createSubmitButton() => FloatingActionButton(
        onPressed: submit,
        child: Icon(Icons.check),
      );
}
