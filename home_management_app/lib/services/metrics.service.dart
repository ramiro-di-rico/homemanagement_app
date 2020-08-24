import 'package:flutter/material.dart';
import 'package:home_management_app/models/overall.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MetricService{

  AuthenticationService authenticationService;
  Overall overall;
  
  MetricService({@required this.authenticationService});

  Future<Overall> getOverall() async {

    if(this.overall == null){
      var token = this.authenticationService.getUserToken();

      var response = await http.get('http://206.189.239.38:5100/api/account/3/overall',
        headers: <String, String>{
          'Authorization': token
        });

      if(response.statusCode == 200){
        this.overall = Overall.fromJson(json.decode(response.body));
      }else{
        throw Exception('Failed to fetch overall.');
      }
    }

    return this.overall;
  }
}