import 'package:flutter/cupertino.dart';
import 'package:home_management_app/models/preference.dart';
import 'package:home_management_app/services/endpoints/preferences.service.dart';

class PreferencesRepository extends ChangeNotifier {
  PreferenceService preferenceService;
  List<PreferenceModel> preferences = [];

  PreferencesRepository({required this.preferenceService});

  Future load() async {
    var result = await this.preferenceService.fetch();
    this.preferences.addAll(result);
    notifyListeners();
  }

  bool getDailyBackupValue()
  {
    if (this.preferences.length == 0) return false;

    var dailyBackupConfig = this.preferences.firstWhere((element) => element.name == 'EnableDailyBackups');

    return dailyBackupConfig.value == 'true';
  }

  String getPreferredCurrency()
  {
    if (this.preferences.length == 0) return '';

    return this.preferences.firstWhere((element) => element.name == 'PreferredCurrency').value;
  }
}
