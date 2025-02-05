import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/services/repositories/currency.repository.dart';

import '../../../../models/currency.dart';

class CurrencySelect extends StatefulWidget {
  final List<CurrencyModel> selectedCurrencies;
  final bool multipleSelection;
  final ValueChanged<List<CurrencyModel>> onSelectedCurrenciesChanged;

  CurrencySelect({
    required this.selectedCurrencies,
    required this.multipleSelection,
    required this.onSelectedCurrenciesChanged,
  });

  @override
  _CurrencySelectState createState() => _CurrencySelectState();
}

class _CurrencySelectState extends State<CurrencySelect> {
  CurrencyRepository _currencyRepository = GetIt.I<CurrencyRepository>();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<CurrencyModel>(
      hint: Text('Select currency'),
      value: widget.selectedCurrencies.isNotEmpty ? widget.selectedCurrencies.first : null,
      items: _currencyRepository.currencies.map((currency) {
        return DropdownMenuItem<CurrencyModel>(
          value: currency,
          child: Text(currency.name),
        );
      }).toList(),
      onChanged: (CurrencyModel? newValue) {
        if (newValue != null) {
          widget.onSelectedCurrenciesChanged([newValue]);
        }
      },
    );
  }
}