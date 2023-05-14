import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/app-textfield.dart';
import '../../../custom/components/dropdown.component.dart';
import '../../../custom/keyboard.factory.dart';
import '../../../models/account.dart';
import '../../../repositories/account.repository.dart';
import '../../../repositories/currency.repository.dart';

// ignore: must_be_immutable
class AccountSheet extends StatefulWidget {
  AccountModel? accountModel;

  AccountSheet({Key? key, this.accountModel}) : super(key: key);

  @override
  State<AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends State<AccountSheet> {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.all(8),
              child: AppTextField(
                label: 'Account Name',
                editingController: _textEditingController,
              )),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Row(
                    children: [
                      Checkbox(
                        value: account.measurable,
                        onChanged: onMeasurableChanged,
                      ),
                      Expanded(
                        child: Text('Is Measurable'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownComponent(
                    items: ['Cash', 'Bank Account'],
                    onChanged: onAccountTypeChanged,
                    currentValue: account.accountTypeToString(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownComponent(
                    items: currencies,
                    onChanged: onCurrencyTypeChanged,
                    currentValue: currencyRepository.currencies
                        .firstWhere(
                            (element) => element.id == account.currencyId)
                        .name,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          AnimatedOpacity(
            opacity: account.name.length > 3 ? 1.0 : 0,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: addNewAccount,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(40),
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          )
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
