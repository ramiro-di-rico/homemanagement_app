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

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  TransactionModel transactionModel = TransactionModel.empty(0, 0);
  AccountModel accountModel = AccountModel.empty(0);

  @override
  Widget build(BuildContext context) {

    accountModel = widget._accountModel;

    transactionModel = widget.transactionModel ??
        TransactionModel.empty(
            accountModel.id, categoryRepository.categories.first.id);

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
              onPressed: () {
                transactionModel.name = nameController.text;
                transactionModel.price = double.parse(priceController.text);
                Navigator.pop(context, transactionModel);
              },
              child: Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}
