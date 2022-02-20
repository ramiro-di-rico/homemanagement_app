import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/metrics/account-metrics.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class AccountsMetricSeriesWidget extends StatefulWidget {
  AccountsMetricSeriesWidget({Key key}) : super(key: key);

  @override
  _AccountsMetricSeriesWidgetState createState() =>
      _AccountsMetricSeriesWidgetState();
}

class _AccountsMetricSeriesWidgetState
    extends State<AccountsMetricSeriesWidget> {
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  List<AccountSeries> series = [];
  List<MonthSerie> collection;
  List<Color> lineColors = [
    Colors.lime[900],
    Colors.pink[600],
    Colors.orange[600],
    Colors.green[600]
  ];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    setState(() {
      loading = true;
    });
    var result = await accountRepository.getSeries();
    setState(() {
      series.addAll(result);
      collection = getMonthSeries();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(child: buildChartContainer()),
    );
  }

  Widget buildChartContainer() {
    return Column(children: [
      ListTile(
        leading: Icon(Icons.show_chart),
        title: Text('Accounts series'),
      ),
      Expanded(
        child: Skeleton(
          isLoading: loading,
          skeleton: SkeletonAvatar(),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: LineChart(buildChart()),
          ),
        ),
      ),
    ]);
  }

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  LineChartData buildChart() {
    return LineChartData(
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: false,
        ),
        borderData: FlBorderData(
          show: false,
        ),
        lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                var labels = touchedSpots.map((e) {
                  var serie = series[e.barIndex];
                  var account = accountRepository.accounts
                      .firstWhere((element) => element.id == serie.accountId);

                  var toolTip = LineTooltipItem(
                    '${account.name} ${serie.monthSeries[e.spotIndex].average}',
                    TextStyle(color: lineColors[e.barIndex]),
                  );
                  return toolTip;
                }).toList();

                return labels;
              },
            )),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 20,
            getTextStyles: buildAxisTextStyle,
            getTitles: (value) {
              var now = DateTime.now();
              var date = DateTime(now.year, value.toInt(), now.day);
              var monthName = DateFormat.MMM().format(date);
              return monthName;
            },
          ),
          leftTitles: SideTitles(
            showTitles: true,
            margin: 20,
            reservedSize: 40,
            getTextStyles: buildAxisTextStyle,
            getTitles: (value) {
              return calculateYAxisLabel(value);
            },
          ),
          rightTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(showTitles: false),
        ),
        minY: 0,
        maxY: maxY(),
        lineBarsData: series
            .map(
              (e) => LineChartBarData(
                isCurved: true,
                colors: [lineColors[series.indexOf(e)]],
                spots: e.monthSeries
                    .map(
                      (m) =>
                          FlSpot(m.index.toDouble(), double.parse(m.average)),
                    )
                    .toList(),
              ),
            )
            .toList());
  }

  TextStyle buildAxisTextStyle(BuildContext context, double value) {
    return TextStyle(
        color: ThemeData.fallback().colorScheme.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 14);
  }

  String calculateYAxisLabel(double value) {
    return value % 1000.0 == 0 ? (value / 1000).toStringAsFixed(0) + " k" : "";
  }

  List<MonthSerie> getMonthSeries() {
    List<MonthSerie> monthSeries = [];

    for (var s in this.series) {
      for (var m in s.monthSeries) {
        monthSeries.add(m);
      }
    }
    return monthSeries;
  }

  double maxY() {
    if (collection == null) return 0;

    double value = 0;
    for (var item in collection) {
      value += num.parse(item.average);
    }
    return value;
  }
}
