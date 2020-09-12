import 'package:flutter/material.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/category.dart';
import 'package:http/http.dart' as http;
import 'authentication.service.dart';
import 'dart:convert';

class CategoryService{
  AuthenticationService authenticationService;

  CategoryService(
      {@required this.authenticationService});

  Future<List<CategoryModel>> fetch() async {
    var token = this.authenticationService.getUserToken();

    var response = await http.get('http://206.189.239.38:5100/api/category',
        headers: <String, String>{'Authorization': token});

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      var result = data.map((e) => CategoryModel.fromJson(e)).toList();
      return result;
    } else {
      throw Exception('Failed to fetch Categories.');
    }
  }
}