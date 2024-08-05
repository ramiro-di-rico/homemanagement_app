import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../custom/components/dropdown.component.dart';
import '../../../services/repositories/currency.repository.dart';
import '../../../services/repositories/preferences.repository.dart';

class PreferredCurrency extends StatefulWidget {
  const PreferredCurrency({super.key});

  @override
  State<PreferredCurrency> createState() => _PreferredCurrencyState();
}

class _PreferredCurrencyState extends State<PreferredCurrency> {
  PreferencesRepository preferencesRepository =
      GetIt.I<PreferencesRepository>();
  CurrencyRepository currencyRepository = GetIt.I<CurrencyRepository>();
  final List<String> currencies = [];
  String selectedCurrency = '';

  @override
  void initState() {
    super.initState();
    currencies.addAll(currencyRepository.currencies.map((c) => c.name));
    selectedCurrency = preferencesRepository.getPreferredCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Text(
                  'Preferred Currency',
                ),
                Spacer(),
                DropdownComponent(
                  items: currencies,
                  onChanged: onCurrencyTypeChanged,
                  currentValue: selectedCurrency,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  onCurrencyTypeChanged(String currencyChanged) {
    // add logic to change currency
  }
}
