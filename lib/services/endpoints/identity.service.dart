
import 'package:home_management_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IdentityService {
  String url = 'ramiro-di-rico.dev';
  String authenticateApi = 'identity/api/Authentication/SignIn';
  String authenticateApiV2 = 'identity/api/Authentication/V2/SignIn';
  String registrationApi = 'api/registration';

  Future<UserModel?> internalAuthenticate(String email, String password) async {
    var response = await http.post(Uri.https(this.url, this.authenticateApi),
        headers: <String, String>{'Content-Type': 'application/json'},
        body:
        jsonEncode(<String, String>{'email': email, 'password': password}));

    if (response.statusCode == 200) {
      var jsonModel = json.decode(response.body);
      jsonModel['password'] = password;
      var user = UserModel.fromJson(jsonModel);
      return user;
    } else {
      return null;
    }
  }

  Future<UserModel?> internalAuthenticateV2(String username, String password) async {
    var response = await http.post(Uri.https(this.url, this.authenticateApiV2),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(
            <String, String>{'username': username, 'password': password}));

    if (response.statusCode == 200) {
      var jsonModel = json.decode(response.body);
      jsonModel['password'] = password;
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
}