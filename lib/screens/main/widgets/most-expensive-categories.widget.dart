import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/metrics/categories.metric.dart';
import 'package:home_management_app/services/category.service.metric.dart';
import 'package:skeletons/skeletons.dart';

class MostExpensiveCategoriesChart extends StatefulWidget {
  MostExpensiveCategoriesChart({Key key}) : super(key: key);

  @override
  _MostExpensiveCategoriesChartState createState() =>
      _MostExpensiveCategoriesChartState();
}

class _MostExpensiveCategoriesChartState
    extends State<MostExpensiveCategoriesChart> {
  List<CategoryMetric> metrics = List.empty();
  bool loading = false;

  Future loadMetrics() async {
    setState(() {
      loading = true;
    });
    var result = await GetIt.I<CategoryMetricService>()
        .getMostExpensiveCategories(DateTime.now().month);

    setState(() {
      metrics = result;
      loading = false;
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
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Most expensive categories'),
          ),
          Expanded(
            child: Skeleton(
              isLoading: loading,
              skeleton: SkeletonAvatar(),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: BarChart(buildChart()),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  BarChartData buildChart() {
    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
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
        leftTitles: SideTitles(
            showTitles: true,
            margin: 40,
            getTextStyles: buildAxisTextStyle,
            reservedSize: 30),
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
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
