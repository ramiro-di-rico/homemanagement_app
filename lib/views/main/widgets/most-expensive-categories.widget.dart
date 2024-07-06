import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/metrics/categories.metric.dart';
import 'package:home_management_app/services/endpoints/category.service.metric.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../services/repositories/account.repository.dart';
import 'chart-options-sheet.dart';

class MostExpensiveCategoriesChart extends StatefulWidget {
  MostExpensiveCategoriesChart({Key? key}) : super(key: key);

  @override
  _MostExpensiveCategoriesChartState createState() =>
      _MostExpensiveCategoriesChartState();
}

class _MostExpensiveCategoriesChartState
    extends State<MostExpensiveCategoriesChart> {
  AccountRepository accountRepository = GetIt.I<AccountRepository>();
  List<CategoryMetric> metrics = List.empty();
  bool loading = false;
  List<String> accounts = List.empty(growable: true);
  String selectedAccount = "All Accounts";
  String _allAccounts = "All Accounts";
  int selectedMonth = DateTime.now().month;
  int take = 3;

  Future loadMetrics() async {
    setState(() {
      loading = true;
    });
    loadAccounts();
    var account = !accountRepository.accounts
            .any((element) => element.name == selectedAccount)
        ? null
        : accountRepository.accounts
            .firstWhere((element) => element.name == selectedAccount);

    var result = account == null
        ? await GetIt.I<CategoryMetricService>()
            .getMostExpensiveCategories(selectedMonth, take)
        : await GetIt.I<CategoryMetricService>()
            .getMostExpensiveCategoriesByAccount(
                account.id, selectedMonth, take);

    setState(() {
      metrics = result;
      metrics.sort((a, b) => a.category.name.compareTo(b.category.name));
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    accountRepository.addListener(loadAccounts);
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
            title: Text('Categories'),
            trailing: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0))),
                    builder: (context) {
                      return SizedBox(
                        height: 150,
                        child: AnimatedPadding(
                            padding: MediaQuery.of(context).viewInsets,
                            duration: Duration(seconds: 1),
                            child: ChartOptionsSheet(
                              selectedAccount,
                              selectedMonth,
                              take,
                              (account, month, value) async {
                                selectedAccount = account;
                                selectedMonth = month;
                                take = value;
                                await loadMetrics();
                              },
                            )),
                      );
                    });
              },
            ),
          ),
          Expanded(
            child: Skeletonizer(
              enabled: loading,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 40, 10),
                child: BarChart(buildChart()),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  BarChartData buildChart() {
    if(metrics.isEmpty)
      return BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            )
          ),
          leftTitles: AxisTitles(
            drawBelowEverything: false,
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          show: false
        ),
        barGroups: [],
      );

    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameSize: 50,
          sideTitles: SideTitles(
            reservedSize: 30,
            showTitles: true,
            getTitlesWidget: (value, metadata) {
              var metric = metrics[value.toInt()];
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(metric.category.name),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 80,
            getTitlesWidget: (value, metadata) {
              return Padding(
                padding: const EdgeInsets.only(right: 1),
                child: Text(metadata.formattedValue),
              );
            }
          ),

        )
      ),
      barGroups: metrics
          .map(
            (e) => BarChartGroupData(
              x: metrics.indexOf(e),
              barRods: [
                BarChartRodData(
                    toY: e.price.toDouble(),
                    fromY: 0)
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

  void loadAccounts() {
    accounts.clear();
    accounts.add(_allAccounts);
    accounts.addAll(accountRepository.accounts.map((e) => e.name));
  }
}
