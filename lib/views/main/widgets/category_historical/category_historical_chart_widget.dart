import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/extensions/datehelper.dart';

import '../../../../models/http-models/category_historical_response.dart';
import '../../../../services/endpoints/category.service.metric.dart';
import '../../../../services/repositories/category.repository.dart';
import 'filtering_options_sheet.dart';


class CategoryHistoricalChartWidget extends StatefulWidget {
  const CategoryHistoricalChartWidget({super.key});

  @override
  State<CategoryHistoricalChartWidget> createState() =>
      _CategoryHistoricalChartWidgetState();
}

class _CategoryHistoricalChartWidgetState
    extends State<CategoryHistoricalChartWidget> {
  CategoryMetricService categoryMetricService =
      GetIt.I.get<CategoryMetricService>();
  CategoryRepository categoryRepository = GetIt.I.get<CategoryRepository>();
  final List<CategoryHistoricalResponse> data = [];
  DateTime dateFrom = DateTime.now().subtract(Duration(days: 60));
  DateTime dateTo = DateTime.now();
  int take = 5;
  List<Color> lineColors = [
    Colors.lime[600] ?? Colors.lime,
    Colors.pink[200] ?? Colors.pink,
    Colors.orange[600] ?? Colors.orange,
    Colors.green[600] ?? Colors.green,
    Colors.purple[200] ?? Colors.purple,
    Colors.blueAccent[600] ?? Colors.blueAccent,
    Colors.amberAccent[600] ?? Colors.amberAccent,
    Colors.deepOrange[600] ?? Colors.deepOrange,
    Colors.red[600] ?? Colors.red,
    Colors.teal[600] ?? Colors.teal,
    Colors.brown[300] ?? Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
        ? Card(child: Center(child: Text('No data available')))
        : Card(
            child: Column(
              children: [
                ListTile(
                    leading : Icon(Icons.show_chart),
                    title: Text('Category Historical Chart'),
                    subtitle: Text('Last ${calculateMonthDifference()} months'),
                    trailing: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        showFilterDialog();
                      },
                    )
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 20, 40, 20),
                    child: LineChart(buildChartData()),
                  ),
                ),
              ],
            ),
          );
  }

  LineChartData buildChartData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(reservedSize: 50, showTitles: true),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: Text('Months'),
          sideTitles: SideTitles(
              interval: 1,
              getTitlesWidget: (value, titleMeta) {
                var month = value.toInt();
                var monthName = month.toMonthName();
                return Text(monthName);
              },
              showTitles: true),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: data.map((category) {
        return LineChartBarData(
          isCurved: true,
          dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 6,
              color: lineColors[data.indexOf(category)],
              strokeWidth: 0,
              strokeColor: Colors.transparent,
            );
          }),
          spots: category.historical.map((monthData) {
            return FlSpot(monthData.month.toDouble(), monthData.total);
          }).toList(),
          barWidth: 4,
          belowBarData: BarAreaData(show: false),
        );
      }).toList(),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              var month = touchedSpot.x.toInt();

              for (var dataIndex = 0; dataIndex < data.length; dataIndex++) {
                var category = data[dataIndex];

                for (var historicalIndex = 0; historicalIndex < category.historical.length; historicalIndex++) {
                  var monthData = category.historical[historicalIndex];
                  if (monthData.month == month && touchedSpot.y == monthData.total) {
                    var total = formatValue(monthData.total);
                    return LineTooltipItem(
                      '${category.name} ${total}',
                      TextStyle(color: lineColors[dataIndex]),
                    );
                  }
                }
              }

              return LineTooltipItem(
                '${touchedSpot.y}',
                TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Future load() async {
    var result = await categoryMetricService.getCategoryHistoricalResponses(
        dateFrom, dateTo, take);
    setState(() {
      data.addAll(result);
    });
  }

  String formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 100000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toString();
  }

  void showFilterDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return FilterOptionsSheet(
          initialDateFrom: dateFrom,
          initialDateTo: dateTo,
          initialTake: take,
          onApply: (newDateFrom, newDateTo, newTake) {
            setState(() {
              dateFrom = newDateFrom;
              dateTo = newDateTo;
              take = newTake;
              setState(() {
                data.clear();
              });
              load();
            });
          },
        );
      },
    );
  }

  int calculateMonthDifference() {
    int monthDifference = dateTo.month - dateFrom.month;
    return monthDifference + 1;
  }
}
