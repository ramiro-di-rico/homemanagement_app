import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/metrics/account-metrics.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:intl/intl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:queries/collections.dart';
import 'package:queries/queries.dart';

class AccountsMetricSeriesWidget extends StatefulWidget {
  AccountsMetricSeriesWidget({Key key}) : super(key: key);

  @override
  _AccountsMetricSeriesWidgetState createState() =>
      _AccountsMetricSeriesWidgetState();
}

class _AccountsMetricSeriesWidgetState
    extends State<AccountsMetricSeriesWidget> {
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  List<AccountSeries> series = List<AccountSeries>();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    var result = await accountRepository.getSeries();
    setState(() {
      series.addAll(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: series.length > 0
            ? buildChartContainer()
            : Center(
                child: Text('No Metrics to display.'),
              ),
      ),
    );
  }

  Widget buildChartContainer() {
    return Column(children: [
      ListTile(
        leading: Icon(Icons.show_chart),
        title: Text('Accounts series'),
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: LineChart(buildChart()),
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
          show: false,,
        ),
        borderData: FlBorderData(
            show: false,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 20,
            textStyle: buildAxisTextStyle(),
            getTitles: (value) {
              var now = DateTime.now();
              var date = DateTime(now.year, value.toInt(), now.day);
              var monthName = DateFormat.MMM().format(date);
              return monthName;
            },
          ),
          leftTitles: SideTitles(
            showTitles: false,
            textStyle: buildAxisTextStyle(),
            getTitles: (value) {
              return calculateYAxisLabel(value);
            },
          ),
        ),
        lineBarsData: series
            .map(
              (e) => LineChartBarData(
                isCurved: true,
                colors: [Colors.greenAccent],
                spots: e.monthSeries
                    .map(
                      (m) =>
                          FlSpot(m.month.toDouble(), double.parse(m.average)),
                    )
                    .toList(),
              ),
            )
            .toList());
  }

  TextStyle buildAxisTextStyle() {
    return TextStyle(
        color: ThemeData.fallback().colorScheme.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 14);
  }

  String calculateYAxisLabel(double value) {
    var collection = Collection(getMonthSeries());

    var max = collection.max$1((e) => num.parse(e.average));
    var min = collection.min$1((element) => num.parse(element.average));
    var avg = collection.average((element) => num.parse(element.average));

    if (value == min.toDouble()) {
      return value.toString();
    } else if (value == avg) {
      return value.toString();
    } else if (value == max.toDouble()) {
      return value.toString();
    } else {
      return '';
    }
  }

  List<MonthSerie> getMonthSeries() {
    List<MonthSerie> monthSeries = List<MonthSerie>();

    for (var s in this.series) {
      for (var m in s.monthSeries) {
        monthSeries.add(m);
      }
    }
    return monthSeries;
  }
}
