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
  String cacheKey = 'getMostExpensiveCategories';

  CategoryMetricService(
      {@required this.authenticationService, @required this.caching});

  Future<CategoriesMetric> getMostExpensiveCategories(int month) async {
    if (this.caching.exists(cacheKey)) {
      return this.caching.fetch(cacheKey) as CategoriesMetric;
    }

    if (this.categoriesMetric == null) {
      var token = this.authenticationService.getUserToken();

      var response = await http.get(
          Uri.https('ramiro-di-rico.dev',
              'homemanagementapi/api/account/toptransactions/$month'),
          headers: <String, String>{'Authorization': token});

      if (response.statusCode == 200) {
        this.categoriesMetric =
            CategoriesMetric.fromJson(json.decode(response.body));
        caching.add(cacheKey, this.categoriesMetric);
      } else {
        throw Exception('Failed to fetch Categories Metric.');
      }
    }

    return this.categoriesMetric;
  }
}
