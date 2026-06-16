import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:home_management_app/extensions/number_format_extension.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/models/transaction.dart';

class TransactionsByAccountChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Map<int, String> accountNamesById;

  const TransactionsByAccountChart({
    super.key,
    required this.transactions,
    required this.accountNamesById,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final grouped = <int, double>{};
    for (final t in transactions) {
      grouped[t.accountId] = (grouped[t.accountId] ?? 0) + t.price;
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text(localizations.transactionsByAccount),
              contentPadding: EdgeInsets.zero,
            ),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(localizations.noAccountsDataAvailable),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: BarChart(_buildChartData(entries, localizations)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData(
      List<MapEntry<int, double>> entries, AppLocalizations localizations) {
    final maxY = entries.first.value * 1.2;

    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      maxY: maxY,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameSize: 16,
          sideTitles: SideTitles(
            reservedSize: 60,
            showTitles: true,
            getTitlesWidget: (value, metadata) {
              final index = value.toInt();
              if (index < 0 || index >= entries.length) {
                return SizedBox.shrink();
              }
              final name = accountNamesById[entries[index].key] ??
                  localizations.unknownAccount;
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 70,
            getTitlesWidget: (value, metadata) {
              return Padding(
                padding: const EdgeInsets.only(right: 1),
                child: Text(metadata.formattedValue),
              );
            },
          ),
        ),
      ),
      barGroups: entries
          .asMap()
          .entries
          .map(
            (entry) => BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  color: Colors.deepPurpleAccent,
                  toY: entry.value.value,
                  width: 16,
                ),
              ],
            ),
          )
          .toList(),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final accountId = entries[group.x].key;
            final name =
                accountNamesById[accountId] ?? localizations.unknownAccount;
            return BarTooltipItem(
              '$name\n${entries[group.x].value.formatWithDot()}',
              TextStyle(color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}
