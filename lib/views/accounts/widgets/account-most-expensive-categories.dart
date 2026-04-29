import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/metrics/categories.metric.dart';
import 'package:home_management_app/services/endpoints/category.service.metric.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:home_management_app/models/account.dart';

// ignore: must_be_immutable
class AccountMostExpensiveCategories extends StatefulWidget {
  AccountModel accountModel;
  AccountMostExpensiveCategories(this.accountModel, {Key? key})
      : super(key: key);

  @override
  State<AccountMostExpensiveCategories> createState() =>
      _AccountMostExpensiveCategoriesState();
}

class _AccountMostExpensiveCategoriesState
    extends State<AccountMostExpensiveCategories> {
  List<CategoryMetric> metrics = List.empty();
  bool loading = false;

  Future loadMetrics() async {
    setState(() {
      loading = true;
    });
    var result = await GetIt.I<CategoryMetricService>()
        .getMostExpensiveCategoriesByAccount(
            widget.accountModel.id, DateTime.now().month, 3);

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
  void didUpdateWidget(AccountMostExpensiveCategories oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountModel.id != widget.accountModel.id) {
      loadMetrics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        child: Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.bar_chart),
                title: Text('Most expensive categories'),
              ),
              Expanded(
                child: Skeletonizer(
                  enabled: loading,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                    child: BarChart(buildChart()),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  BarChartData buildChart() {
    if (metrics.isEmpty) {
      return BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        barGroups: [],
      );
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, metadata) {
              final index = value.toInt();
              if (index < 0 || index >= metrics.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(metrics[index].category.name),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, metadata) => Text(metadata.formattedValue),
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: metrics
          .map(
            (e) => BarChartGroupData(
              x: metrics.indexOf(e),
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: e.price.toDouble(),
                )
              ],
            ),
          )
          .toList(),
    );
  }
}
