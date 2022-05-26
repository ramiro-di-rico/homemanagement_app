import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../custom/components/app-textfield.dart';
import '../../../custom/components/dropdown.component.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
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
  AccountModel accountModel;

  double price = 0;
  CategoryModel selectedCategory;
  TransactionType selectedTransactionType = TransactionType.Outcome;
  DateTime selectedDate = DateTime.now();
  FloatingActionButton actionButton;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(onNameChanged);
    selectedCategory = categoryRepository.categories.first;
    isEditing = widget.transactionModel != null;

    if (isEditing) {
      setInitialValues();
    }
  }

  @override
  void dispose() {
    this.nameController.removeListener(onNameChanged);
    this.nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    accountModel = widget._accountModel;

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
                      onChanged: (value) {
                        price = value.length > 0 ? double.parse(value) : 0;
                        onNameChanged();
                      },
                      controller: isEditing
                          ? TextEditingController(text: price.toString())
                          : null,
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
                      initialValue:
                          widget.transactionModel?.date ?? DateTime.now(),
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
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: DropdownComponent(
                        currentValue: isEditing
                            ? categoryRepository.categories
                                .firstWhere((element) =>
                                    element.id ==
                                    widget.transactionModel.categoryId)
                                .name
                            : "",
                        items: categoryRepository.categories
                            .map((e) => e.name)
                            .toList(),
                        onChanged: (categoryName) {
                          selectedCategory = categoryRepository.categories
                              .firstWhere(
                                  (element) => element.name == categoryName);
                          onNameChanged();
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
                        currentValue: isEditing
                            ? widget.transactionModel.transactionType.name
                            : TransactionModel.getTransactionTypes().last,
                      )),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          AnimatedOpacity(
            opacity: enableSubmitButton() ? 1.0 : 0,
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

  bool enableSubmitButton() {
    return nameController.text.length > 0 &&
        selectedCategory != null &&
        price > 0;
  }

  void onNameChanged() {
    setState(() {
      enableSubmitButton();
    });
  }

  Future addTransaction() async {
    if (isEditing) {
      widget.transactionModel.name = nameController.text;
      widget.transactionModel.price = this.price;
      widget.transactionModel.categoryId = selectedCategory.id;
      widget.transactionModel.transactionType = selectedTransactionType;
      this.transactionRepository.update(widget.transactionModel);
    } else {
      var transactionModel = TransactionModel(
          0,
          accountModel.id,
          selectedCategory.id,
          nameController.text,
          price,
          selectedDate,
          selectedTransactionType);
      this.transactionRepository.add(transactionModel);
    }

    Navigator.pop(context);
  }

  void setInitialValues() {
    price = widget.transactionModel.price;
    selectedCategory = categoryRepository.categories.firstWhere(
        (element) => element.id == widget.transactionModel.categoryId);
    selectedTransactionType = widget.transactionModel.transactionType;
    selectedDate = widget.transactionModel.date;

    nameController.text = widget.transactionModel.name;
  }
}
