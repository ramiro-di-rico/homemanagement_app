import 'package:flutter/material.dart';
import 'package:home_management_app/models/metrics/categories.metric.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'caching.dart';

class CategoryMetricService {
  AuthenticationService authenticationService;
  Caching caching;
  CategoriesMetric categoriesMetric;
  List<CategoryMetric> metrics = List.empty(growable: true);
  String cacheKey = 'getMostExpensiveCategories';

  CategoryMetricService(
      {@required this.authenticationService, @required this.caching});

  Future<List<CategoryMetric>> getMostExpensiveCategories(int month) async {
    if (this.caching.exists(cacheKey)) {
      return this.caching.fetch(cacheKey) as List<CategoryMetric>;
    }

    if (this.metrics.isEmpty) {
      var token = this.authenticationService.getUserToken();
      final queryParameters = {'month': month.toString(), 'take': '3'};

      var uri = Uri.https('ramiro-di-rico.dev',
          'homemanagementapi/api/account/toptransactions', queryParameters);
      var response = await http.get(uri,
          headers: <String, String>{'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        var result = data.map((e) => CategoryMetric.fromJson(e)).toList();
        this.metrics.addAll(result);
        caching.add(cacheKey, this.metrics);
      } else {
        throw Exception('Failed to fetch Categories Metric.');
      }
    }

    return this.metrics;
  }

  Future<List<CategoryMetric>> getMostExpensiveCategoriesByAccount(
      int accountId, int month) async {
    List<CategoryMetric> metrics;
    if (this.categoriesMetric == null) {
      var token = this.authenticationService.getUserToken();

      var response = await http.get(
          Uri.https('ramiro-di-rico.dev',
              'homemanagementapi/api/account/$accountId/toptransactions/$month'),
          headers: <String, String>{'Authorization': token});

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        metrics = data.map((e) => CategoryMetric.fromJson(e)).toList();
        //caching.add(cacheKey, this.categoriesMetric);
      } else {
        throw Exception('Failed to fetch Categories Metric by account id.');
      }
    }

    return metrics;
  }
}
