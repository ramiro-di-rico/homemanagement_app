import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../custom/components/app-textfield.dart';
import '../../../custom/components/dropdown.component.dart';
import '../../../models/account.dart';
import '../../../models/transaction.dart';
import '../../../repositories/category.repository.dart';
import '../../../repositories/transaction.repository.dart';

// ignore: must_be_immutable
class AddTransactionSheet extends StatefulWidget {
  AccountModel _accountModel;
  TransactionModel transactionModel;

  AddTransactionSheet(this._accountModel, {Key key, this.transactionModel})
      : super(key: key);

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  AccountModel accountModel;
  TransactionModel transactionModel;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    isEditing = widget.transactionModel != null;
    accountModel = widget._accountModel;
    transactionModel = widget.transactionModel ??
        TransactionModel.empty(
            accountModel.id, categoryRepository.categories.first.id);
    nameController.addListener(onNameChanged);
    priceController.addListener(onPriceChanged);
    nameController.text = transactionModel.name;
    priceController.text = isEditing ? transactionModel.price.toString() : "";
  }

  @override
  void dispose() {
    this.nameController.removeListener(onNameChanged);
    priceController.removeListener(onPriceChanged);
    this.nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          //first row
          Padding(
            padding: EdgeInsets.all(10),
            child: AppTextField(
              editingController: nameController,
              label: 'Transaction Name',
            ),
          ),
          //second row
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d+)?\.?\d{0,2}'))
                        ],
                        decoration:
                            InputDecoration(icon: Icon(Icons.attach_money)),
                        controller: priceController),
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
                        transactionModel.date = date;
                      },
                      resetIcon: null,
                      initialValue: transactionModel.date,
                    ),
                  ),
                )
              ],
            ),
          ),
          //third row
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownComponent(
                    currentValue: categoryRepository.categories
                        .firstWhere((element) =>
                            element.id == transactionModel.categoryId)
                        .name,
                    items: categoryRepository.categories
                        .map((e) => e.name)
                        .toList(),
                    onChanged: (categoryName) {
                      transactionModel.categoryId = categoryRepository
                          .categories
                          .firstWhere((element) => element.name == categoryName)
                          .id;
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: DropdownComponent(
                          items: TransactionModel.getTransactionTypes(),
                          onChanged: (transactionType) {
                            transactionModel.transactionType =
                                TransactionModel.parseByName(transactionType);
                          },
                          currentValue: transactionModel.transactionType.name)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          AnimatedOpacity(
            opacity: transactionModel.isValid() ? 1.0 : 0,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: addTransaction,
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

  void onNameChanged() {
    transactionModel.name = nameController.text;
  }

  void onPriceChanged() {
    if (priceController.text.isNotEmpty) {
      transactionModel.price = double.parse(priceController.text);
    }
  }

  Future addTransaction() async {
    if (isEditing) {
      this.transactionRepository.update(widget.transactionModel);
    } else {
      this.transactionRepository.add(transactionModel);
    }

    Navigator.pop(context);
  }
}
