import 'package:flutter/material.dart';
import 'package:home_management_app/models/preference.dart';
import 'api.service.factory.dart';
import 'authentication.service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PreferenceService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;

  PreferenceService(
      {@required this.authenticationService, @required this.apiServiceFactory});

  Future<List<PreferenceModel>> fetch() async {
    var token = this.authenticationService.getUserToken();

    var response = await http.get(
        Uri.https('ramiro-di-rico.dev', 'homemanagementapi/api/preferences'),
        headers: <String, String>{'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      var result = data.map((e) => PreferenceModel.fromJson(e)).toList();
      return result;
    } else {
      throw Exception('Failed to fetch Accounts.');
    }
  }
}
