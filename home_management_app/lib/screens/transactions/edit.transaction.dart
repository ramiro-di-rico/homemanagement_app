import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/app-textfield.dart';
import 'package:home_management_app/custom/components/dropdown.component.dart';
import 'package:home_management_app/models/category.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/repositories/category.repository.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'package:intl/intl.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transactionModel;

  EditTransactionScreen(this.transactionModel);

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
   TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TextEditingController nameController;
  TextEditingController priceController;
  double price;
  CategoryModel selectedCategory;
  FloatingActionButton actionButton = null;

  @override
  void initState() {
    super.initState();
    selectedCategory = categoryRepository.categories.firstWhere((element) => widget.transactionModel.categoryId == element.id);
    nameController = TextEditingController(text: widget.transactionModel.name);
    nameController.addListener(onNameChanged);
    priceController = TextEditingController(text: widget.transactionModel.price.toString());
    priceController.addListener(onPriceChanged);
    price = widget.transactionModel.price;
  }

  @override
  void dispose() {
    this.nameController.removeListener(onNameChanged);
    this.nameController.dispose();
    this.priceController.removeListener(onPriceChanged);
    this.priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: actionButton,
      appBar: AppBar(
        title: Text('Edit ${widget.transactionModel.name}'),
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
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                decoration: InputDecoration(icon: Icon(Icons.attach_money)),
                controller: priceController,
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
                  widget.transactionModel.date = date;
                },
                resetIcon: null,
                initialValue: widget.transactionModel.date,
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
                  currentValue: selectedCategory.name,
                )),
          ),
          Expanded(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: DropdownComponent(
                  items: TransactionModel.getTransactionTypes(),
                  onChanged: (transactionType) {
                    widget.transactionModel.transactionType =
                        TransactionModel.parseByName(transactionType);
                  },
                  currentValue: widget.transactionModel.parseTransactionByType(),
                )),
          ),
        ],
      ),
    );
  }

  void onNameChanged() {
    checkIfShouldEnableButton();
  }

  void onPriceChanged(){
    price = priceController.text.length > 0 ? double.parse(priceController.text) : 0;
    checkIfShouldEnableButton();
  }

  void checkIfShouldEnableButton() {
    var shouldEnable = nameController.text.length > 0 &&
        selectedCategory != null &&
        price > 0;
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
    widget.transactionModel.name = nameController.text;
    widget.transactionModel.price = this.price;
    this.transactionRepository.update(widget.transactionModel);
    Navigator.pop(context);
  }
}
