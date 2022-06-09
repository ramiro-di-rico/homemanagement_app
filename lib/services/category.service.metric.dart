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

  Future<List<CategoryMetric>> getMostExpensiveCategories(
      int month, int take) async {
    var key = "getMostExpensiveCategoriesByAccount-$month-$take";
    if (this.caching.exists(key)) {
      return this.caching.fetch(key) as List<CategoryMetric>;
    }

    if (this.metrics.isEmpty) {
      var token = this.authenticationService.getUserToken();
      final queryParameters = {
        'month': month.toString(),
        'take': take.toString()
      };

      var uri = Uri.https('ramiro-di-rico.dev',
          'homemanagementapi/api/account/toptransactions', queryParameters);
      var response = await http.get(uri,
          headers: <String, String>{'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        var result = data.map((e) => CategoryMetric.fromJson(e)).toList();
        this.metrics.addAll(result);
        caching.add(key, this.metrics);
      } else {
        throw Exception('Failed to fetch Categories Metric.');
      }
    }

    return this.metrics;
  }

  Future<List<CategoryMetric>> getMostExpensiveCategoriesByAccount(
      int accountId, int month, int take) async {
    var key = "getMostExpensiveCategoriesByAccount-$accountId-$month-$take";
    if (this.caching.exists(key)) {
      return this.caching.fetch(key) as List<CategoryMetric>;
    }

    var token = this.authenticationService.getUserToken();
    final queryParameters = {
      'month': month.toString(),
      'take': take.toString()
    };

    var response = await http.get(
        Uri.https(
            'ramiro-di-rico.dev',
            'homemanagementapi/api/account/$accountId/toptransactions',
            queryParameters),
        headers: <String, String>{'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      var metrics = data.map((e) => CategoryMetric.fromJson(e)).toList();
      caching.add(key, metrics);
      return metrics;
    } else {
      throw Exception('Failed to fetch Categories Metric by account id.');
    }
  }
}
