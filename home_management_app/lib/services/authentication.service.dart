import 'package:flutter/material.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/repositories/user.repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cryptography.service.dart';

class AuthenticationService{

  CryptographyService cryptographyService;
  UserRepository userRepository;
  String url = 'http://206.189.239.38:5300/';
  String authenticateApi = 'api/Authentication/MobileSignIn';
  UserModel user;

  AuthenticationService({@required this.cryptographyService, this.userRepository});

  init(){
    this.user = this.userRepository.userModel;
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
        this.userRepository.store(this.user);
        return true;
      }else{
        return false;
      }
  }

  void logout(){
    this.user = null;
    this.userRepository.clear();
  }
}