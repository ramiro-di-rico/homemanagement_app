import 'package:home_management_app/models/preference.dart';
import 'package:home_management_app/services/endpoints/api-mixin.dart';
import 'api.service.factory.dart';
import '../security/authentication.service.dart';
import 'dart:convert';

class PreferenceService with HttpApiServiceMixin {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;

  PreferenceService(
      {required this.authenticationService, required this.apiServiceFactory});

  Future<List<PreferenceModel>> fetch() async {
    var token = this.authenticationService.getUserToken();
    var response = await httpGet(createUri('preferences/v3'), token);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      var result = data.map((e) => PreferenceModel.fromJson(e)).toList();
      return result;
    } else {
      throw Exception('Failed to fetch Accounts.');
    }
  }
}
