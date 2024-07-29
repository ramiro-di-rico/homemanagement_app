import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../services/repositories/preferences.repository.dart';

class PreferredCurrency extends StatefulWidget {
  const PreferredCurrency({super.key});

  @override
  State<PreferredCurrency> createState() => _PreferredCurrencyState();
}

class _PreferredCurrencyState extends State<PreferredCurrency> {
  PreferencesRepository preferencesRepository =
      GetIt.I<PreferencesRepository>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(
          'Preferred Currency',
        ),
        title: Text(preferencesRepository.getPreferredCurrency()),
        titleAlignment: ListTileTitleAlignment.center,
      ),
    );
  }
}
