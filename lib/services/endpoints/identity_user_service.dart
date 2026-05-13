import '../../models/view-models/my_user_view_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../security/authentication.service.dart';

class IdentityUserService {
  String usersMy = 'identity/api/users/my';
  String url = 'www.ramiro-di-rico.dev';

  AuthenticationService authenticationService;

  IdentityUserService({required this.authenticationService});

  Future<MyUserViewModel> getUser() async {
    var response = await http.get(
      Uri.https(this.url, usersMy),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authenticationService.getUserToken()}',
      },
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
    var response = await http.put(
      Uri.https(this.url, usersMy),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authenticationService.getUserToken()}',
      },
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
}
