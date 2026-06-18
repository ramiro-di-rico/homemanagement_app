import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:home_management_app/ui/core/extensions/number_format_extension.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/domain/models/transaction.dart';

class TransactionsByCategoryChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionsByCategoryChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final grouped = <String, double>{};
    for (final t in transactions) {
      final key = t.categoryName.isEmpty
          ? localizations.categoryNotSet
          : t.categoryName;
      grouped[key] = (grouped[key] ?? 0) + t.price;
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
              leading: Icon(Icons.category),
              title: Text(localizations.transactionsByCategory),
              contentPadding: EdgeInsets.zero,
            ),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(localizations.noCategoriesDataAvailable),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: BarChart(_buildChartData(entries)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData(List<MapEntry<String, double>> entries) {
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
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  entries[index].key,
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
                  color: Colors.lightBlue,
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
            final category = entries[group.x];
            return BarTooltipItem(
              '${category.key}\n${category.value.formatWithDot()}',
              TextStyle(color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}
