import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_management_app/custom/components/dropdown.component.dart';
import 'package:home_management_app/custom/input.factory.dart';

class AddAccountScreen extends StatefulWidget {
  static const String id = 'add_account_screen';

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  bool isMeasurable = false;

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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: accountNameTextField(),
            ),
            Padding(
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
            Padding(
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
                )),
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
            InputFactory.createdRoundedOutLineDecoration('Account Name'));
  }

  Widget accountTypeDropDown() {
    return DropdownComponent(
      items: ['Cash', 'Bank Account'],
      onChanged: onAccountTypeChanged,
    );
  }

  onAccountTypeChanged(String accountType) {}

  Widget currencyTypeDropDown() {
    return DropdownComponent(
      items: ['USD', 'EUR', 'ARS'],
      onChanged: onCurrencyTypeChanged,
    );
  }

  onCurrencyTypeChanged(String accountType) {}

  onMeasurableChanged(bool value){
    setState(() {
      this.isMeasurable = value;
    });
  }
}
