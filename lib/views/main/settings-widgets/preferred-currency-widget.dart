import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/main-card.dart';
import '../../../services/repositories/preferences.repository.dart';

class PreferredCurreny extends StatefulWidget {
  const PreferredCurreny({super.key});

  @override
  State<PreferredCurreny> createState() => _PreferredCurrenyState();
}

class _PreferredCurrenyState extends State<PreferredCurreny> {
  PreferencesRepository preferencesRepository =
      GetIt.I<PreferencesRepository>();

  @override
  Widget build(BuildContext context) {
    return MainCard(
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
