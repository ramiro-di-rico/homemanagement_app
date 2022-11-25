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
      var uri = Uri.https(
          'ramiro-di-rico.dev',
          'homemanagementapi/api/account/toptransactions',
          _getQueryParams(month, take));
      var response = await http.get(uri, headers: _getAuthHeaders());

      if (response.statusCode == 200) {
        var result = _parseJson(response.body);
        _cacheResponse(key, result.categories);
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

    var response = await http.get(
        Uri.https(
            'ramiro-di-rico.dev',
            'homemanagementapi/api/account/$accountId/toptransactions',
            _getQueryParams(month, take)),
        headers: _getAuthHeaders());

    if (response.statusCode == 200) {
      var result = _parseJson(response.body);
      _cacheResponse(key, result.categories);
      return metrics;
    } else {
      throw Exception('Failed to fetch Categories Metric by account id.');
    }
  }

  CategoriesMetric _parseJson(String body) {
    Map<String, dynamic> data = json.decode(body);
    var result = CategoriesMetric.fromJson(data);
    return result;
  }

  void _cacheResponse(String key, List<CategoryMetric> categories) {
    this.metrics.addAll(categories);
    caching.add(key, this.metrics);
  }

  Map<String, String> _getQueryParams(int month, int take) =>
      {'month': month.toString(), 'take': take.toString()};

  Map<String, String> _getAuthHeaders() {
    var token = this.authenticationService.getUserToken();
    return {'Authorization': 'Bearer $token'};
  }
}
