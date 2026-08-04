import 'dart:async';
import 'dart:convert';

import 'package:home_management_app/data/services/authentication.service.dart';
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

    if (_isSuccesFullResponse(response)) {
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

    if (!_isSuccesFullResponse(response)) {
      throw Exception('Failed to post to $api');
    }

    return json.decode(response.body);
  }

  Future<String> rawApiGet(String api) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.get(
      backendEndpoint.resolve(api),
      headers: _getHeaders(),
    );

    if (!_isSuccesFullResponse(response)) {
      throw Exception('Failed to post to $api');
    }

    return response.body;
  }

  Future apiPost(String api, dynamic body) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.post(backendEndpoint.resolve(api),
        headers: _getHeaders(), body: body);

    if (!_isSuccesFullResponse(response)) {
      throw Exception('Failed to post to $api');
    }
  }

  Future<dynamic> postWithReturn(String api, dynamic body) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.post(backendEndpoint.resolve(api),
        headers: _getHeaders(),
        body: body,
        encoding: Encoding.getByName('utf-8'),
    );

    if (!_isSuccesFullResponse(response)) {
      throw Exception('Failed to post to $api');
    }

    return json.decode(response.body);
  }

  Future apiPut(String api, String body) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.put(backendEndpoint.resolve(api),
        headers: _getHeaders(), body: body);

    if (!_isSuccesFullResponse(response)) {
      throw Exception('Failed to put to $api');
    }

    return response.body.isEmpty
        ? null
        : json.decode(response.body);
  }

  Future apiPatch(String api, String body) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.patch(backendEndpoint.resolve(api),
        headers: _getHeaders(), body: body);

    if (!_isSuccesFullResponse(response)) {
      throw Exception('Failed to patch to $api');
    }

    return response.body.isEmpty
        ? null
        : json.decode(response.body);
  }

  Future apiDelete(String api, String id, {String? body}) async {
    await _autoAuthenticateIfNeeded();

    var response = await http.delete(
      backendEndpoint.resolve('$api/$id'),
      headers: _getHeaders(),
      body: body,
    );
    if (!_isSuccesFullResponse(response)) {
      throw Exception('Failed to delete to $api');
    }
  }

  Future upload(String api, dynamic file) async {
    await _autoAuthenticateIfNeeded();

    var response = await _send(api, file);
    if (!_isSuccessfulStatusCode(response.statusCode)) {
      throw Exception('Failed to upload to $api');
    }
  }

  /// Same as [upload] but returning the decoded response body.
  Future<dynamic> uploadWithReturn(String api, dynamic file) async {
    await _autoAuthenticateIfNeeded();

    var response = await _send(api, file);
    var body = await response.stream.bytesToString();

    if (!_isSuccessfulStatusCode(response.statusCode)) {
      throw Exception('Failed to upload to $api. $body');
    }

    return body.isEmpty ? null : json.decode(body);
  }

  Future<http.StreamedResponse> _send(String api, dynamic file) async {
    var request = http.MultipartRequest('POST', backendEndpoint.resolve(api))
      ..files.add(file);
    // Only the auth header: MultipartRequest sets its own Content-Type with the boundary, and
    // overwriting it with application/json leaves the server unable to read the form.
    request.headers.addAll(_getAuthHeaders());

    return await request.send();
  }

  Future _autoAuthenticateIfNeeded() async {
    if (!authenticationService.isAuthenticated() &&
        authenticationService.canAutoAuthenticate()) {
      await authenticationService.autoAuthenticate();
    }
  }

  Map<String, String> _getHeaders() => <String, String>{
        ..._getAuthHeaders(),
        'Content-Type': 'application/json',
      };

  Map<String, String> _getAuthHeaders() {
    var token = authenticationService.getUserToken();
    return <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    };
  }

  bool _isSuccesFullResponse(http.Response response) =>
      _isSuccessfulStatusCode(response.statusCode);

  bool _isSuccessfulStatusCode(int statusCode) =>
      statusCode >= 200 && statusCode < 300;
}
