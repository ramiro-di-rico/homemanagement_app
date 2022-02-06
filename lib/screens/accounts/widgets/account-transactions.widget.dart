import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/metrics/categories.metric.dart';
import 'package:home_management_app/services/category.service.metric.dart';

class AccountTransactionsWidget extends StatefulWidget {
  final AccountModel account;
  AccountTransactionsWidget({this.account});

  @override
  _AccountTransactionsWidgetState createState() =>
      _AccountTransactionsWidgetState();
}

class _AccountTransactionsWidgetState extends State<AccountTransactionsWidget> {
  List<CategoryMetric> metrics;

  Future loadMetrics() async {
    var result = await GetIt.I<CategoryMetricService>()
        .getMostExpensiveCategoriesByAccount(
            widget.account.id, DateTime.now().month);

    setState(() {
      metrics = result;
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
      child: metrics != null && metrics.length > 0
          ? Column(
              children: [
                ListTile(
                  leading: Icon(Icons.bar_chart),
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

  BarChartData buildChart() {
    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: SideTitles(
            showTitles: true,
            getTitles: (value) {
              var metricValue = metrics.elementAt(value.floor());
              return metricValue.price.floor().toString();
            },
            getTextStyles: buildAxisTextStyle),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: buildAxisTextStyle,
          getTitles: (value) {
            var metric = metrics[value.toInt()];
            return metric.category.name.length > 10
                ? metric.category.name
                    .substring(0, metric.category.name.indexOf(" "))
                : metric.category.name;
          },
        ),
        leftTitles: SideTitles(showTitles: false),
      ),
      barGroups: metrics
          .map(
            (e) => BarChartGroupData(
              x: metrics.indexOf(e),
              barRods: [
                BarChartRodData(
                    y: e.price.toDouble(), colors: [Colors.greenAccent])
              ],
            ),
          )
          .toList(),
    );
  }

  TextStyle buildAxisTextStyle(BuildContext context, double value) {
    return TextStyle(
        color: ThemeData.fallback().colorScheme.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 14);
  }
}
