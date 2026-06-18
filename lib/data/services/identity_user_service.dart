import 'package:home_management_app/ui/features/authentication/view_models/my_user_view_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:home_management_app/data/services/authentication.service.dart';

class IdentityUserService {
  String usersMy = 'identity/api/users/my';
  String url = 'www.ramiro-di-rico.dev';

  AuthenticationService authenticationService;

  IdentityUserService({required this.authenticationService});

  Future<MyUserViewModel> getUser() async {
    await _autoAuthenticateIfNeeded();
    var response = await http.get(
      Uri.https(this.url, usersMy),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      var jsonModel = json.decode(response.body);
      return MyUserViewModel.fromJson(jsonModel);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<MyUserViewModel> updateLanguage(
    String language,
    String timeZone,
  ) async {
    await _autoAuthenticateIfNeeded();
    var response = await http.put(
      Uri.https(this.url, usersMy),
      headers: _getHeaders(),
      body: jsonEncode(<String, String>{
        'language': language,
        'timeZone': timeZone,
      }),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Failed to update language');
      }

      var jsonModel = json.decode(response.body);
      return MyUserViewModel.fromJson(jsonModel);
    }

    throw Exception('Failed to update language');
  }

  Map<String, String> _getHeaders() {
    var token = authenticationService.getUserToken();
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future _autoAuthenticateIfNeeded() async {
    if (!authenticationService.isAuthenticated() &&
        authenticationService.canAutoAuthenticate()) {
      await authenticationService.autoAuthenticate();
    }
  }
}
