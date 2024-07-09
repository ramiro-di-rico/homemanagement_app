import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/app-textfield.dart';
import '../../../custom/components/dropdown.component.dart';
import '../../../custom/keyboard.factory.dart';
import '../../../models/account.dart';
import '../../../services/repositories/account.repository.dart';
import '../../../services/repositories/currency.repository.dart';

class AccountSheetDesktop extends StatefulWidget {
  AccountModel? accountModel;

  AccountSheetDesktop({Key? key, this.accountModel}) : super(key: key);

  @override
  State<AccountSheetDesktop> createState() => _AccountSheetDesktopState();
}

class _AccountSheetDesktopState extends State<AccountSheetDesktop> {
  AccountRepository accountsRepository = GetIt.instance<AccountRepository>();
  CurrencyRepository currencyRepository = GetIt.I<CurrencyRepository>();
  TextEditingController _textEditingController = TextEditingController();
  KeyboardFactory? keyboardFactory;
  late AccountModel account;
  bool isEditMode = false;

  List<String> currencies = [];
  bool enableButton = false;

  @override
  void initState() {
    super.initState();
    this.keyboardFactory = KeyboardFactory(context: context);
    currencies.addAll(this.currencyRepository.currencies.map((c) => c.name));
    account = widget.accountModel ??
        AccountModel.empty(this.currencyRepository.currencies.first.id);
    isEditMode = widget.accountModel != null;
    _textEditingController.text = account.name;
    _textEditingController.addListener(onNameChanged);
  }

  @override
  void dispose() {
    this._textEditingController.removeListener(onNameChanged);
    this._textEditingController.dispose();
    super.dispose();
  }

  void onNameChanged() {
    setState(() {
      this.account.name = this._textEditingController.text;
      this.enableButton = this.account.name.length > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          SizedBox(width: 50),
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppTextField(
                label: 'Account Name',
                editingController: _textEditingController,
              ),
            ),
          ),
          SizedBox(width: 50),
          Row(
            children: [
              Text('Account type'),
              SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownComponent(
                  items: ['Cash', 'Bank Account'],
                  onChanged: onAccountTypeChanged,
                  currentValue: 'Cash',
                ),
              ),
            ],
          ),
          SizedBox(width: 50),
          Row(
            children: [
              Text('Currency'),
              SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownComponent(
                  items: currencies,
                  onChanged: onCurrencyTypeChanged,
                  currentValue: currencies[0],
                ),
              ),
            ],
          ),
          SizedBox(width: 50),
          Row(
            children: [
              Checkbox(
                value: account.measurable,
                onChanged: onMeasurableChanged,
              ),
              Text('Is Measurable'),
            ],
          ),
          SizedBox(width: 50),
          ElevatedButton(
            onPressed: enableButton ? addNewAccount : null,
            child: Icon(Icons.check),
          ),
        ],
      ),
    );
  }

  onAccountTypeChanged(String accountType) {
    setState(() {
      this.account.accountType =
          accountType == 'Cash' ? AccountType.Cash : AccountType.BankAccount;
    });
  }

  onCurrencyTypeChanged(String currency) {
    setState(() {
      this.account.currencyId = this.currencies.indexOf(currency);
    });
  }

  onMeasurableChanged(bool? value) {
    setState(() {
      this.account.measurable = value ?? false;
    });
  }

  void addNewAccount() {
    if (isEditMode) {
      this.accountsRepository.update(account);
    } else {
      this.accountsRepository.add(account);
    }
    Navigator.pop(context);
  }
}
