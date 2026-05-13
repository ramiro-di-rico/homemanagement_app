
import 'dart:convert';

import '../../models/user-settings.dart';
import '../infra/error_notifier_service.dart';
import '../security/authentication.service.dart';
import 'api.service.factory.dart';

class UserSettingsService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;
  NotifierService notifierService;
  final endpoint = 'UserSettings';

  UserSettingsService(
      {required this.authenticationService, required this.apiServiceFactory, required this.notifierService});

  Future<UserSettings> fetchUserSettings() async {
    var endpointResult = await this.apiServiceFactory.apiGet(endpoint);
    var result = UserSettings.fromJson(endpointResult);
    return result;
  }

  Future update(UserSettings userSettings) async {
    var msg = jsonEncode(_toJson(userSettings));
    await apiServiceFactory.apiPut('UserSettings', msg);
    notifierService.notify('User Settings updated');
  }

  Future updateCurrency(UserSettings userSettings) async {
    var msg = jsonEncode(_toJson(userSettings));
    await apiServiceFactory.apiPut('UserSettings/currency', msg);
    notifierService.notify('Preferred currency updated');
  }

  Future updateBackupFrequency(UserSettings userSettings) async {
    var msg = jsonEncode(_toJson(userSettings));
    await apiServiceFactory.apiPatch('UserSettings/backup-frequency', msg);
    notifierService.notify('Backup frequency updated');
  }

  Map<String, dynamic> _toJson(UserSettings userSettings) => {
    'csvDelimiter': userSettings.csvDelimiter,
    'currency': userSettings.currency,
    'backupFrequency': userSettings.backupFrequency.value,
  };
}
