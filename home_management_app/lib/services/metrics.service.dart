import 'package:flutter/material.dart';
import 'package:home_management_app/models/overall.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'caching.dart';

class MetricService{

  AuthenticationService authenticationService;
  Caching caching;
  Overall overall;
  String cacheKey = 'overall'; 
  
  MetricService({@required this.authenticationService, @required this.caching});

  Future<Overall> getOverall() async {

    if(this.caching.exists(cacheKey)){
      return this.caching.fetch(cacheKey) as Overall;
    }

    if(this.overall == null){
      var token = this.authenticationService.getUserToken();

      var response = await http.get('http://206.189.239.38:5100/api/account/3/overall',
        headers: <String, String>{
          'Authorization': token
        });

      if(response.statusCode == 200){
        this.overall = Overall.fromJson(json.decode(response.body));
        caching.add(cacheKey, this.overall);
      }else{
        throw Exception('Failed to fetch overall.');
      }
    }

    return this.overall;
  }
}