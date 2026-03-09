import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../extensions/datehelper.dart';
import '../../../models/http-models/balance_history_response.dart';
import '../../../services/repositories/account.repository.dart';
import '../../../services/repositories/currency.repository.dart';
import '../../../services/endpoints/metrics.service.dart';

class BalanceHistoricalChartWidget extends StatefulWidget {
  const BalanceHistoricalChartWidget({super.key});

  @override
  State<BalanceHistoricalChartWidget> createState() =>
      _BalanceHistoricalChartWidgetState();
}

class _BalanceHistoricalChartWidgetState
    extends State<BalanceHistoricalChartWidget> {
  MetricService metricService = GetIt.I.get<MetricService>();
  AccountRepository accountRepository = GetIt.I.get<AccountRepository>();
  CurrencyRepository currencyRepository = GetIt.I.get<CurrencyRepository>();
  List<BalanceHistoryResponse> data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
        ? const Card(child: Center(child: CircularProgressIndicator()))
        : Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Balance History'),
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
    // Group data by currency name and month
    Map<String, Map<int, double>> groupedData = {};
    var allAccounts = accountRepository.getAllAccounts();

    for (var item in data) {
      var account = allAccounts
          .where((element) => element.id == item.accountId)
          .firstOrNull;
      if (account == null) continue;

      var currency = currencyRepository.currencies
          .where((element) => element.id == account.currencyId)
          .firstOrNull;
      String currencyName = currency?.name ?? 'Unknown';

      groupedData.putIfAbsent(currencyName, () => {});

      var month = item.date.month;
      var previous = groupedData[currencyName]![month] ?? 0;
      var sum = previous + item.balance;
      var current = groupedData[currencyName]![month];
      current = sum;
      groupedData[currencyName]![month] = current;
    }

    List<Color> lineColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    int colorIndex = 0;

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 60,
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(formatValue(value),
                  style: const TextStyle(fontSize: 10));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text('Months'),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              var month = value.toInt();
              return Text(month.toMonthName(),
                  style: const TextStyle(fontSize: 10));
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: groupedData.entries.map((entry) {
        final currencyName = entry.key;
        final monthData = entry.value;

        // Sort months for the line
        final sortedMonths = monthData.keys.toList()..sort();

        final color = lineColors[colorIndex % lineColors.length];
        colorIndex++;

        return LineChartBarData(
          isCurved: true,
          color: color,
          dotData: const FlDotData(show: true),
          spots: sortedMonths.map((month) {
            return FlSpot(month.toDouble(), monthData[month]!);
          }).toList(),
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        );
      }).toList(),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final currencyName = groupedData.keys.elementAt(spot.barIndex);
              return LineTooltipItem(
                '$currencyName: ${formatValue(spot.y)}',
                TextStyle(color: spot.bar.color),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Future load() async {
    try {
      var result = await metricService.getBalanceHistory();
      setState(() {
        data = result;
      });
    } catch (e) {
      // Handle error
    }
  }

  String formatValue(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}
