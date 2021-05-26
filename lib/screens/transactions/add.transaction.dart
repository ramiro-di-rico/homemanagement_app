import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/app-textfield.dart';
import 'package:home_management_app/custom/components/dropdown.component.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/category.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/repositories/category.repository.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  static const String id = 'add_transaction_screen';

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TextEditingController nameController = TextEditingController();
  AccountModel accountModel;

  double price = 0;
  CategoryModel selectedCategory;
  TransactionType selectedTransactionType = TransactionType.Outcome;
  DateTime selectedDate = DateTime.now();

  FloatingActionButton actionButton;

  @override
  void initState() {
    super.initState();
    selectedCategory = categoryRepository.categories.first;
    nameController.addListener(onNameChanged);
  }

  @override
  Widget build(BuildContext context) {
    accountModel = ModalRoute.of(context).settings.arguments as AccountModel;

    return Scaffold(
      floatingActionButton: actionButton,
      appBar: AppBar(
        title: Text('New Transaction'),
      ),
      body: Container(
        child: Column(
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
        editingController: nameController,
        label: 'Transaction Name',
      ),
    );
  }

  Padding buildSecondRow() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))],
                decoration: InputDecoration(icon: Icon(Icons.attach_money)),
                onChanged: (value) {
                  price = value.length > 0 ? double.parse(value) : 0;
                  checkIfShouldEnableButton();
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: DateTimeField(
                decoration: InputDecoration(
                  icon: Icon(Icons.date_range),
                ),
                format: DateFormat("dd MMM yyyy"),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
                onChanged: (date) {
                  selectedDate = date;
                },
                resetIcon: null,
                initialValue: DateTime.now(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Padding buildThirdRow() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: DropdownComponent(
                  items:
                      categoryRepository.categories.map((e) => e.name).toList(),
                  onChanged: (categoryName) {
                    selectedCategory = categoryRepository.categories
                        .firstWhere((element) => element.name == categoryName);
                    checkIfShouldEnableButton();
                  },
                )),
          ),
          Expanded(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: DropdownComponent(
                  items: TransactionModel.getTransactionTypes(),
                  onChanged: (transactionType) {
                    selectedTransactionType =
                        TransactionModel.parseByName(transactionType);
                  },
                  currentValue: TransactionModel.getTransactionTypes().last,
                )),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    this.nameController.removeListener(onNameChanged);
    this.nameController.dispose();
    super.dispose();
  }

  void onNameChanged() {
    checkIfShouldEnableButton();
  }

  void checkIfShouldEnableButton() {
    var shouldEnable =
        nameController.text.length > 0 && selectedCategory != null && price > 0;
    setState(() {
      actionButton = shouldEnable ? createFloatingAction() : null;
    });
  }

  FloatingActionButton createFloatingAction() {
    return FloatingActionButton(
      child: Icon(Icons.check),
      onPressed: addTransaction,
    );
  }

  Future addTransaction() async {
    var transactionModel = TransactionModel(0, accountModel.id, selectedCategory.id, nameController.text, price, selectedDate, selectedTransactionType);
    this.transactionRepository.add(transactionModel);
    Navigator.pop(context);
  }
}
