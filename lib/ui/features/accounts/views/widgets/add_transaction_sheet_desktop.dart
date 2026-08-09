import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/ui/core/custom/components/app-textfield.dart';
import 'package:home_management_app/ui/core/custom/formatters/localized_number_input_formatter.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:intl/intl.dart';

import 'package:home_management_app/ui/core/custom/components/dropdown.component.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';

class AddTransactionSheetDesktop extends StatefulWidget {
  final TransactionModel? transactionModel;
  final AccountModel _accountModel;
  final fromRecurring;
  final isEditing;

  AddTransactionSheetDesktop(this._accountModel, {this.transactionModel = null, this.fromRecurring = false, this.isEditing = false});

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
  FocusNode nameFocusNode = FocusNode();

  TransactionModel transactionModel = TransactionModel.empty(0, 0);
  AccountModel accountModel = AccountModel.empty(0);
  String? _localeCode;
  bool _syncingPriceText = false;

  List<TransactionModel> suggestions = [];

  @override
  void initState() {
    super.initState();
    accountModel = widget._accountModel;
    transactionModel = widget.transactionModel ??
        TransactionModel.empty(
            accountModel.id, categoryRepository.categories.first.id);
    nameController.addListener(onNameChanged);
    priceController.addListener(onPriceChanged);
    nameController.text = transactionModel.name;
    fetchSuggestions();
  }

  void fetchSuggestions() async {
    final fetched = await transactionRepository.getSuggestions();
    if (mounted) {
      setState(() {
        suggestions = fetched;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final localeCode = Localizations.localeOf(context).toString();
    if (_localeCode == localeCode) {
      return;
    }

    _localeCode = localeCode;
    _syncingPriceText = true;
    try {
      priceController.text = widget.isEditing || widget.fromRecurring
          ? LocalizedNumberInputFormatterHelper.formatDouble(
              transactionModel.price,
              localeCode,
            )
          : "";
    } finally {
      _syncingPriceText = false;
    }
  }

  @override
  void dispose() {
    this.nameController.removeListener(onNameChanged);
    priceController.removeListener(onPriceChanged);
    nameController.dispose();
    priceController.dispose();
    nameFocusNode.dispose();
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
            child: Autocomplete<TransactionModel>(
              textEditingController: nameController,
              focusNode: nameFocusNode,
              displayStringForOption: (TransactionModel option) => option.name,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<TransactionModel>.empty();
                }
                return suggestions.where((TransactionModel option) {
                  return option.name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                }).toList();
              },
              optionsViewOpenDirection: OptionsViewOpenDirection.up,
              optionsViewBuilder: (context, onSelected, options) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.bottomLeft,
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(15),
                        clipBehavior: Clip.antiAlias,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 260,
                            maxWidth: constraints.maxWidth,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final TransactionModel option =
                                  options.elementAt(index);
                              return ListTile(
                                title: Text(option.name),
                                subtitle: Text(
                                  '${option.categoryName} - \$${option.price}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              onSelected: (TransactionModel selection) {
                nameController.text = selection.name;
                transactionModel.name = selection.name;
                transactionModel.categoryId = selection.categoryId;
                transactionModel.price = selection.price;
                transactionModel.transactionType = selection.transactionType;
                _syncingPriceText = true;
                priceController.text =
                    LocalizedNumberInputFormatterHelper.formatDouble(
                  selection.price,
                  _localeCode ?? Localizations.localeOf(context).toString(),
                );
                _syncingPriceText = false;
                setState(() {});
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                if (nameController.text != controller.text &&
                    nameController.text.isNotEmpty &&
                    controller.text.isEmpty) {
                  controller.text = nameController.text;
                }
                return AppTextField(
                  editingController: controller,
                  customFocusNode: focusNode,
                  label: 'Transaction Name',
                  focus: true,
                );
              },
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  LocalizedNumberInputFormatter(
                    locale:
                        _localeCode ?? Localizations.localeOf(context).toString(),
                  ),
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
            width: 200,
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
          AnimatedOpacity(
            opacity: transactionModel.isValid() ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: SizedBox(
              width: 100,
              child: TextButton(
                onPressed: transactionModel.isValid() ? addTransaction : null,
                child: Icon(Icons.check),
              ),
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
    if (_syncingPriceText) {
      return;
    }

    if (priceController.text.isNotEmpty) {
      final localeCode =
          _localeCode ?? Localizations.localeOf(context).toString();
      final parsedPrice = LocalizedNumberInputFormatterHelper.parseDouble(
        priceController.text,
        localeCode,
      );

      if (parsedPrice == null) {
        return;
      }

      transactionModel.price = parsedPrice;
      setState(() {});
    }
  }

  Future addTransaction() async {
    if (widget.isEditing) {
      await transactionRepository.update(widget.transactionModel!);
    } else {
      await transactionRepository.add(transactionModel);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }
}
