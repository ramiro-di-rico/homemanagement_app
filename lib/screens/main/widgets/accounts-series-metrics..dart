import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/dropdown.component.dart';
import 'package:home_management_app/models/account-historical.dart';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/repositories/account.repository.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

import '../../../services/dashboard.service.dart';

class AccountsMetricSeriesWidget extends StatefulWidget {
  AccountsMetricSeriesWidget({Key key}) : super(key: key);

  @override
  _AccountsMetricSeriesWidgetState createState() =>
      _AccountsMetricSeriesWidgetState();
}

class _AccountsMetricSeriesWidgetState
    extends State<AccountsMetricSeriesWidget> {
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  DashboardService dashboardService = GetIt.I<DashboardService>();

  List<AccountHistorical> accountsHistoricalChart = [];
  List<String> months = List.empty(growable: true);
  List<Color> lineColors = [
    Colors.lime[900],
    Colors.pink[600],
    Colors.orange[600],
    Colors.green[600]
  ];
  bool loading = false;
  List<String> accounts = List.empty(growable: true);
  String selectedAccount = "All Accounts";
  String _allAccounts = "All Accounts";

  @override
  void initState() {
    super.initState();
    accountRepository.addListener(loadAccounts);
    load();
  }

  Future load() async {
    setState(() {
      loading = true;
    });
    loadAccounts();
    var result = selectedAccount == _allAccounts
        ? await dashboardService.fetchAccountsHistoricalChart()
        : await dashboardService.fetchAccountHistoricalChart(accountRepository
            .accounts
            .firstWhere((element) => element.name == selectedAccount)
            .id);
    setState(() {
      accountsHistoricalChart = result;
      mapMonths();
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
        trailing: DropdownComponent(
            items: accounts,
            onChanged: (accountName) async {
              selectedAccount = accountName;
              await load();
            },
            currentValue: selectedAccount),
      ),
      Expanded(
        child: Skeleton(
          isLoading: loading,
          skeleton: SkeletonAvatar(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(40, 0, 20, 20),
            child: LineChart(loading ? null : buildChart()),
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
                  var serie = accountsHistoricalChart[e.barIndex];
                  var account = accountRepository.accounts
                      .firstWhere((element) => element.name == serie.account);

                  var toolTip = LineTooltipItem(
                    '${account.name} ${serie.evolution[e.spotIndex].balance}',
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
            reservedSize: 10,
            getTextStyles: buildAxisTextStyle,
            getTitles: (value) {
              var isInt = value % 1 == 0;
              if (!isInt) return '';
              return months[value.toInt()];
            },
          ),
          leftTitles: SideTitles(
              showTitles: true,
              margin: 10,
              reservedSize: 60,
              getTextStyles: buildAxisTextStyle,
              interval: calculateInterval()),
          rightTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(showTitles: false),
        ),
        minY: minY(),
        maxY: maxY(),
        lineBarsData: accountsHistoricalChart
            .map(
              (e) => LineChartBarData(
                isCurved: true,
                colors: [lineColors[accountsHistoricalChart.indexOf(e)]],
                spots: e.evolution
                    .map(
                      (m) => FlSpot(m.index.toDouble(), m.balance),
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

  double maxY() {
    if (accountsHistoricalChart == null) return 0;

    double value = 0;
    for (var h in accountsHistoricalChart) {
      for (var item in h.evolution) {
        if (item.balance < 0) continue;
        value += item.balance;
      }
    }
    return value;
  }

  double minY() {
    if (accountsHistoricalChart == null) return 0;

    double value = 0;
    for (var h in accountsHistoricalChart) {
      for (var item in h.evolution) {
        if (item.balance > 0) continue;
        value += item.balance;
      }
    }
    return value;
  }

  double calculateInterval() {
    var max = maxY();
    var min = minY();
    var result = (max.abs() + min.abs()).roundToDouble();
    return result.abs();
  }

  void mapMonths() {
    months.clear();
    var account =
        accountsHistoricalChart.any((element) => element.evolution.length == 3)
            ? accountsHistoricalChart
                .firstWhere((element) => element.evolution.length == 3)
            : accountsHistoricalChart
                .firstWhere((element) => element.evolution.length == 2);

    for (var monthValues in account.evolution) {
      months.add(monthValues.month);
    }
  }

  void loadAccounts() {
    accounts.clear();
    accounts.add(_allAccounts);
    accounts.addAll(accountRepository.accounts.map((e) => e.name));
  }
}
