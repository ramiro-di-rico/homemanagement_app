import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:http/http.dart' as http;

class ApiServiceFactory {
  AuthenticationService authenticationService;
  Uri backendEndpoint =
      Uri.https('ramiro-di-rico.dev', 'homemanagementapi/api/');

  ApiServiceFactory({@required this.authenticationService});

  Future<List> fetchList(String api) async {
    var token = this.authenticationService.getUserToken();

    var response = await http.get(backendEndpoint.resolve(api),
        headers: <String, String>{'Authorization': token});

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch list from $api.');
    }
  }

  Future apiGet(String api) async {
    var token = this.authenticationService.getUserToken();

    var response = await http.get(
      backendEndpoint.resolve(api),
      headers: <String, String>{
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to post to $api');
    }

    List data = json.decode(response.body);
    return data;
  }

  Future apiPost(String api, dynamic body) async {
    var token = this.authenticationService.getUserToken();

    var response = await http.post(backendEndpoint.resolve(api),
        headers: <String, String>{
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to post to $api');
    }
  }

  Future apiPut(String api, String body) async {
    var token = this.authenticationService.getUserToken();

    var response = await http.put(backendEndpoint.resolve(api),
        headers: <String, String>{
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to put to $api');
    }
  }

  Future apiDelete(String api, String id) async {
    var token = this.authenticationService.getUserToken();

    var response = await http.delete(
      backendEndpoint.resolve('$api/$id'),
      headers: <String, String>{
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to put to $api');
    }
  }
}
