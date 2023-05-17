import 'package:home_management_app/models/preference.dart';
import 'package:home_management_app/services/api-mixin.dart';
import 'api.service.factory.dart';
import 'authentication.service.dart';
import 'dart:convert';

class PreferenceService with HttpApiServiceMixin {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;

  PreferenceService(
      {required this.authenticationService, required this.apiServiceFactory});

  Future<List<PreferenceModel>> fetch() async {
    var token = this.authenticationService.getUserToken();
    var response = await httpGet(createUri('preferences', null), token);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      var result = data.map((e) => PreferenceModel.fromJson(e)).toList();
      return result;
    } else {
      throw Exception('Failed to fetch Accounts.');
    }
  }
}
