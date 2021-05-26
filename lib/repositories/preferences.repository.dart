import 'package:flutter/cupertino.dart';
import 'package:home_management_app/models/preference.dart';
import 'package:home_management_app/services/preferences.service.dart';

class PreferencesRepository extends ChangeNotifier {
  PreferenceService preferenceService;
  List<PreferenceModel> preferences = [];

  PreferencesRepository(
      {@required this.preferenceService});

  Future load() async {
    var result = await this.preferenceService.fetch();
    this.preferences.addAll(result);
    notifyListeners();
  }

  bool getDailyBackupValue() => this.preferences.firstWhere((element) => element.name == 'enableDailyBackups').value == 'true';

  
}
