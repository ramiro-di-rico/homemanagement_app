
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
    var msg = jsonEncode(userSettings);
    await apiServiceFactory.apiPut('UserSettings', msg);
    notifierService.notify('CSV Delimiter updated');
  }
}
