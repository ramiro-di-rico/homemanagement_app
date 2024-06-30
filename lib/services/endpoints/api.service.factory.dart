import 'dart:async';
import 'dart:convert';

import 'package:home_management_app/services/security/authentication.service.dart';
import 'package:http/http.dart' as http;

class ApiServiceFactory {
  AuthenticationService authenticationService;
  Uri backendEndpoint =
      Uri.https('www.ramiro-di-rico.dev', 'homemanagementapi/api/');

  ApiServiceFactory({required this.authenticationService});

  Future<List> fetchList(String api) async {
    await _autoAuthenticateIfNeeded();

    var response =
        await http.get(backendEndpoint.resolve(api), headers: _getHeaders());

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch list from $api.');
    }
  }

  Future apiGet(String api) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.get(
      backendEndpoint.resolve(api),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to post to $api');
    }

    return json.decode(response.body);
  }

  Future apiPost(String api, dynamic body) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.post(backendEndpoint.resolve(api),
        headers: _getHeaders(), body: body);

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Exception('Failed to post to $api');
    }
  }

  Future<dynamic> postWithReturn(String api, dynamic body) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.post(backendEndpoint.resolve(api),
        headers: _getHeaders(),
        body: body,
        encoding: Encoding.getByName('utf-8'));

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Exception('Failed to post to $api');
    }

    return json.decode(response.body);
  }

  Future apiPut(String api, String body) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.put(backendEndpoint.resolve(api),
        headers: _getHeaders(), body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to put to $api');
    }
  }

  Future apiDelete(String api, String id) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.delete(backendEndpoint.resolve('$api/$id'),
        headers: _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to delete to $api');
    }
  }

  Future _autoAuthenticateIfNeeded() async {
    if (!authenticationService.isAuthenticated() &&
        authenticationService.canAutoAuthenticate()) {
      await authenticationService.autoAuthenticate();
    }
  }

  Map<String, String> _getHeaders() {
    var token = this.authenticationService.getUserToken();
    return <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }
}
