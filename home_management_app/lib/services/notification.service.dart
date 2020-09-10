import 'package:flutter/material.dart';
import 'package:home_management_app/models/notification.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  
  AuthenticationService authenticationService;

  NotificationService(
      {@required this.authenticationService});

  Future<List<NotificationModel>> fetch() async {
    var token = this.authenticationService.getUserToken();

    var response = await http.get('http://206.189.239.38:5100/api/notification',
        headers: <String, String>{'Authorization': token});

    if (response.statusCode == 200) {
      List data = json.decode(response.body);

      var result = data.map((e) => NotificationModel.fromJson(e)).toList();
      return result;
    } else {
      throw Exception('Failed to fetch Accounts.');
    }
  }
}