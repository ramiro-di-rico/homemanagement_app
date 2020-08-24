import 'package:flutter/material.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/services/user.store.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cryptography.service.dart';

class AuthenticationService{

  CryptographyService cryptographyService;
  UserStore userStore;
  String url = 'http://206.189.239.38:5300/';
  String authenticateApi = 'api/Authentication/MobileSignIn';
  UserModel user;

  AuthenticationService({@required this.cryptographyService, @required this.userStore}){
    init();
  }

  init(){
    if(this.userStore.userModel != null){
      this.user = this.userStore.userModel;
    }
  }

  bool isAuthenticated(){
    return user != null;
  }

  String getUserToken() => user.token;

  Future<bool> authenticate(String email, String password) async {

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
        this.userStore.store(this.user);
        return true;
      }else{
        return false;
      }
  }
}