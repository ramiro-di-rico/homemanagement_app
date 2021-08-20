import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/metrics/categories.metric.dart';
import 'package:home_management_app/services/category.service.metric.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class AccountTransactionsWidget extends StatefulWidget {
  final AccountModel account;
  AccountTransactionsWidget({this.account});

  @override
  _AccountTransactionsWidgetState createState() =>
      _AccountTransactionsWidgetState();
}

class _AccountTransactionsWidgetState extends State<AccountTransactionsWidget> {
  CategoriesMetric metric;

  Future loadMetrics() async {
    var result = await GetIt.I<CategoryMetricService>()
        .getMostExpensiveCategories(DateTime.now().month);

    setState(() {
      metric = result;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
      child: metric != null && metric.categories.length > 0
          ? Column(
              children: [
                ListTile(
                  leading: Icon(OMIcons.barChart),
                  title: Text('Most expensive categories'),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: BarChart(buildChart()),
                  ),
                ),
              ],
            )
          : Center(child: Text('No Metrics to display.')),
    ));
  }

  List<CategoryMetric> getMetrics() {
    List<CategoryMetric> result = [];

    var med = metric.highestValue / 2;
    for (var item in metric.categories) {
      if (item.price > med) {
        result.add(item);
      }
    }
    return result;
  }

  BarChartData buildChart() {
    var categories = getMetrics();

    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: buildAxisTextStyle,
          getTitles: (value) {
            var metric = categories[value.toInt()];
            return metric.category.name.length > 10
                ? metric.category.name
                    .substring(0, metric.category.name.indexOf(" "))
                : metric.category.name;
          },
        ),
        leftTitles: SideTitles(
            showTitles: true,
            margin: 40,
            getTextStyles: buildAxisTextStyle,
            reservedSize: 20),
      ),
      barGroups: categories
          .map(
            (e) => BarChartGroupData(
              x: categories.indexOf(e),
              barRods: [
                BarChartRodData(
                    y: e.price.toDouble(), colors: [Colors.greenAccent])
              ],
            ),
          )
          .toList(),
    );
  }

  TextStyle buildAxisTextStyle(double value) {
    return TextStyle(
        color: ThemeData.fallback().colorScheme.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 14);
  }
}
