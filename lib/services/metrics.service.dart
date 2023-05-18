import 'package:home_management_app/models/metrics/breakdown.dart';
import 'package:home_management_app/models/metrics/metric.dart';
import 'package:home_management_app/models/overall.dart';
import 'package:home_management_app/services/api-mixin.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'dart:convert';

import 'caching.dart';

class MetricService with HttpApiServiceMixin {
  AuthenticationService authenticationService;
  Caching caching;
  Overall? overall;
  String cacheKey = 'overall';

  MetricService({required this.authenticationService, required this.caching});

  Future<Overall> getOverall() async {
    if (this.caching.exists(cacheKey)) {
      return this.caching.fetch(cacheKey) as Overall;
    }

    if (this.overall == null) {
      var response = await httpGet(
          createUri('account/overall'), authenticationService.getUserToken());

      if (response.statusCode == 200) {
        this.overall = Overall.fromJson(json.decode(response.body));
        caching.add(cacheKey, this.overall!);
      } else {
        throw Exception('Failed to fetch overall.');
      }
    }

    return this.overall!;
  }

  Future<Overall> getOverallByAccountId(int accountId) async {
    var key = cacheKey + accountId.toString();
    if (this.caching.exists(key)) {
      return this.caching.fetch(key) as Overall;
    }

    if (this.overall == null) {
      var response = await httpGet(createUri('account/$accountId/overall'),
          authenticationService.getUserToken());

      if (response.statusCode == 200) {
        this.overall = Overall.fromJson(json.decode(response.body));
        caching.add(key, this.overall!);
      } else {
        throw Exception('Failed to fetch overall.');
      }
    }

    return this.overall!;
  }

  Future<Metric> getIncomeMetrics() async {
    return await _getMetrics('incomes');
  }

  Future<Metric> getOutcomesMetrics() async {
    return await _getMetrics('outcomes');
  }

  Future<Metric> _getMetrics(String type) async {
    Metric metric;
    if (this.caching.exists(type)) {
      return this.caching.fetch(type) as Metric;
    }

    var response = await httpGet(
        createUri('Account/$type'), authenticationService.getUserToken());

    if (response.statusCode == 200) {
      metric = Metric.fromJson(json.decode(response.body));
      caching.add(cacheKey, metric);
    } else {
      throw Exception("Failed to fetch metric $type.");
    }
    return metric;
  }

  Future<List<Breakdown>> getBreakdown() async {
    if (this.caching.exists('getBreakdown')) {
      return this.caching.fetch('getBreakdown') as List<Breakdown>;
    }

    var response = await httpGet(
        createUri('Account/breakdown'), authenticationService.getUserToken());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      var breakdown = data.map((e) => Breakdown.fromJson(e)).toList();
      caching.add(cacheKey, breakdown);
      return breakdown;
    } else {
      throw Exception("Failed to fetch breakdown.");
    }
  }
}
