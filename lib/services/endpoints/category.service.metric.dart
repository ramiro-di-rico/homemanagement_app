import 'package:home_management_app/models/metrics/categories.metric.dart';
import 'package:home_management_app/services/security/authentication.service.dart';
import 'dart:convert';

import '../../models/http-models/category_historical_response.dart';
import 'api-mixin.dart';
import '../infra/caching.dart';

class CategoryMetricService with HttpApiServiceMixin {
  AuthenticationService authenticationService;
  Caching caching;
  CategoriesMetric? categoriesMetric;
  List<CategoryMetric> metrics = List.empty(growable: true);
  String cacheKey = 'getMostExpensiveCategories';

  CategoryMetricService(
      {required this.authenticationService, required this.caching});

  Future<List<CategoryMetric>> getMostExpensiveCategories(
      int month, int take) async {
    var key = "getMostExpensiveCategoriesByAccount-$month-$take";
    if (this.caching.exists(key)) {
      return this.caching.fetch(key) as List<CategoryMetric>;
    }

    if (this.metrics.isEmpty) {
      var response = await httpGet(
          createUri('account/toptransactions',
              queryParameters: _getQueryParams(month, take)),
          authenticationService.getUserToken());

      if (response.statusCode == 200) {
        var result = _parseJson(response.body);
        _cacheResponse(key, result.categories!);
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

    var response = await httpGet(
        createUri('account/$accountId/toptransactions',
            queryParameters: _getQueryParams(month, take)),
        authenticationService.getUserToken());

    if (response.statusCode == 200) {
      var result = _parseJson(response.body);
      _cacheResponse(key, result.categories!);
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

  Future<List<CategoryHistoricalResponse>> getCategoryHistoricalResponses(DateTime dateFrom, DateTime dateTo, int take) async {

    var response = await httpGet(
      createUri('category/historical', queryParameters: {
        'dateFrom': dateFrom.toIso8601String(),
        'dateTo': dateTo.toIso8601String(),
        'take': take.toString(),
      }),
      authenticationService.getUserToken(),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => CategoryHistoricalResponse.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch category historical responses.');
    }
  }
}
