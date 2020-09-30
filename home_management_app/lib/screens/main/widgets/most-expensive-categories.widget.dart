import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/metrics/categories.metric.dart';
import 'package:home_management_app/services/category.service.metric.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MostExpensiveCategoriesChart extends StatefulWidget {
  MostExpensiveCategoriesChart({Key key}) : super(key: key);

  @override
  _MostExpensiveCategoriesChartState createState() =>
      _MostExpensiveCategoriesChartState();
}

class _MostExpensiveCategoriesChartState
    extends State<MostExpensiveCategoriesChart> {
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
    List<CategoryMetric> result = List<CategoryMetric>();

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
          textStyle: buildAxisTextStyle(),
          getTitles: (value) {
            var metric = categories[value.toInt()];
            return metric.category.name;
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          margin: 40,
          textStyle: buildAxisTextStyle(),
          reservedSize: 20,
          getTitles: (value) {
            if (value == 0) {
              return '1K';
            } else if (value == 10000) {
              return '10K';
            } else if (value == 20000) {
              return '20K';
            } else {
              return '';
            }
          },
        ),
      ),
      barGroups: categories
          .map(
            (e) => BarChartGroupData(
              x: categories.indexOf(e),
              barRods: [
                BarChartRodData(
                    y: e.price.toDouble(), color: Colors.greenAccent)
              ],
            ),
          )
          .toList(),
    );
  }

  TextStyle buildAxisTextStyle() {
    return TextStyle(
        color: ThemeData.fallback().colorScheme.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 14);
  }
}
