import 'package:flutter/material.dart';

import '../../models/preference.dart';
import '../endpoints/preferences.service.dart';
import '../infra/error_notifier_service.dart';

class PreferencesRepository extends ChangeNotifier {
  PreferenceService preferenceService;
  NotifierService notifierService;

  List<PreferenceModel> preferences = [];
  static const String dailyBackup = 'EnableDailyBackups';
  static const String preferredCurrency = 'PreferredCurrency';
  static const String language = 'Language';

  PreferencesRepository({required this.preferenceService, required this.notifierService});

  Future load() async {
    var result = await this.preferenceService.fetch();
    this.preferences.addAll(result);
    notifyListeners();
  }

  bool getDailyBackupValue()
  {
    if (this.preferences.length == 0) return false;

    var dailyBackupConfig = this.preferences.firstWhere((element) => element.name == dailyBackup);

    return dailyBackupConfig.value == 'true';
  }

  String getPreferredCurrency()
  {
    if (this.preferences.length == 0) return '';

    var pref = this.preferences.firstWhere(
      (element) => element.name == preferredCurrency,
      orElse: () => PreferenceModel(preferredCurrency, ''),
    );
    return pref.value;
  }

  String getCurrentLanguage()
  {
    if (this.preferences.length == 0) return '';

    return this.preferences.firstWhere((element) => element.name == language).value;
  }

  Future update(PreferenceModel preference) async {
    await this.preferenceService.update(preference);
    this.preferences.removeWhere((element) => element.name == preference.name);
    this.preferences.add(preference);
    this.notifierService.notify('Preference updated');
    notifyListeners();
  }
}
