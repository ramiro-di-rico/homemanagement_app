
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/services/infra/logger_wrapper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IdentityService {
  String url = 'ramiro-di-rico.dev';
  String authenticateApi = 'identity/api/Authentication/SignIn';
  String authenticateApiV2 = 'identity/api/Authentication/SignIn';
  String registrationApi = 'api/registration';
  String twoFactorApi = 'identity/api/Authentication/CompleteTwoFactorAuthenticationSignIn';
  final _logger = LoggerWrapper();

  Future<UserModel?> internalAuthenticate(String email, String password) async {
    _logger.i('Calling v1 authentication endpoint');
    var response = await http.post(Uri.https(this.url, this.authenticateApi),
        headers: <String, String>{'Content-Type': 'application/json'},
        body:
        jsonEncode(<String, String>{'email': email, 'password': password}));

    return _handleAuthResponse(response, password);
  }

  Future<UserModel?> internalAuthenticateV2(String username, String password) async {
    _logger.i('Calling v2 authentication endpoint');
    var queryParameter = {
      'api-version': '2'
    };

    var response = await http.post(Uri.https(this.url, this.authenticateApiV2, queryParameter),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(
            <String, String>{'username': username, 'password': password}));

    return _handleAuthResponse(response, password);
  }

  UserModel? _handleAuthResponse(http.Response response, String password) {
    _logger.i('Response is ${response.statusCode}');
    if (response.statusCode == 200) {
      var jsonModel = json.decode(response.body);
      jsonModel['password'] = password;
      _logger.i('Converting user from json');
      var user = UserModel.fromJson(jsonModel);
      return user;
    } else {
      return null;
    }
  }

  Future<bool> register(String email, String password) async {
    var response = await http.post(Uri.https(this.url, this.registrationApi),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'email': email, 'password': password}));

    return response.statusCode == 200;
  }

  Future<UserModel?> completeTwoFactorAuthentication(String username, String code) async {
    var response = await http.post(Uri.https(this.url, this.twoFactorApi),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'username': username, 'code': code}));

    if (response.statusCode == 200) {
      var jsonModel = json.decode(response.body);
      return UserModel.fromJson(jsonModel);
    } else {
      return null;
    }
  }
}