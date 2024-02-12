import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/app-textfield.dart';
import 'package:home_management_app/models/account.dart';
import 'package:intl/intl.dart';

import '../../../custom/components/dropdown.component.dart';
import '../../../models/transaction.dart';
import '../../../services/repositories/category.repository.dart';
import '../../../services/repositories/transaction.repository.dart';

class AddTransactionSheetDesktop extends StatefulWidget {
  TransactionModel? transactionModel;
  AccountModel _accountModel;

  AddTransactionSheetDesktop(this._accountModel, {super.key, this.transactionModel});

  @override
  State<AddTransactionSheetDesktop> createState() =>
      _AddTransactionSheetDesktopState();
}

class _AddTransactionSheetDesktopState
    extends State<AddTransactionSheetDesktop> {
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  TransactionModel transactionModel = TransactionModel.empty(0, 0);
  AccountModel accountModel = AccountModel.empty(0);
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 10),
          SizedBox(
            width: 300,
            child: AppTextField(
              label: 'Transaction Name',
              editingController: nameController,
              focus: true,
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^(\d+)?\.?\d{0,2}'))
                ],
                decoration: InputDecoration(icon: Icon(Icons.attach_money)),
                controller: priceController),
          ),
          SizedBox(width: 30),
          SizedBox(
            width: 135,
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
                transactionModel.date = date!;
                setState(() {});
              },
              resetIcon: null,
              initialValue: transactionModel.date,
            ),
          ),
          SizedBox(width: 30),
          SizedBox(
            width: 100,
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
                setState(() {});
              },
              isExpanded: true,
            ),
          ),
          SizedBox(width: 30),
          SizedBox(
            width: 100,
            child: DropdownComponent(
              items: TransactionModel.getTransactionTypes(),
              onChanged: (transactionType) {
                transactionModel.transactionType =
                    TransactionModel.parseByName(transactionType);
                setState(() {});
              },
              currentValue: transactionModel.transactionType.name,
              isExpanded: true,
            )
          ),
          SizedBox(width: 30),
          SizedBox(
            width: 100,
            child: TextButton(
              onPressed: addTransaction,
              child: Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }

  void onNameChanged() {
    transactionModel.name = nameController.text;
    setState(() {});
  }

  void onPriceChanged() {
    if (priceController.text.isNotEmpty) {
      transactionModel.price = double.parse(priceController.text);
      setState(() {});
    }
  }

  Future addTransaction() async {
    if (isEditing) {
      await transactionRepository.update(widget.transactionModel!);
    } else {
      await transactionRepository.add(transactionModel);
    }

    Navigator.pop(context);
  }
}
