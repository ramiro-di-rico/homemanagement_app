import 'package:home_management_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:injector/injector.dart';
import 'cryptography.service.dart';

class AuthenticationService{

  String url = 'http://206.189.239.38:5300/';
  String authenticateApi = 'api/Authentication/MobileSignIn';
  UserModel user;

  bool isAuthenticated(){
    return user != null;
  }

  String getUserToken() => user.token;

  Future<bool> authenticate(String email, String password) async {

    var cryptographyService = Injector.appInstance.getDependency<CryptographyService>();
    var pass = await cryptographyService.encryptToAES(password);

    var response = await http.post(this.url + this.authenticateApi, 
      headers: <String, String>{
          'Content-Type':'application/json',
          'HomeManagementApp':'PR0DT0K3N'
        },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': pass
      }));

      if(response.statusCode == 200){
        this.user = UserModel.fromJson(json.decode(response.body));
        return true;
      }else{
        return false;
      }
  }
}