import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/extensions/datehelper.dart';
import 'package:home_management_app/extensions/number_format_extension.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/models/http-models/category_comparison_response.dart';
import 'package:home_management_app/services/endpoints/category.service.metric.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'category_comparison_filter_sheet.dart';

class CategoryComparisonChartWidget extends StatefulWidget {
  const CategoryComparisonChartWidget({super.key});

  @override
  State<CategoryComparisonChartWidget> createState() =>
      _CategoryComparisonChartWidgetState();
}

class _CategoryComparisonChartWidgetState
    extends State<CategoryComparisonChartWidget> {
  static const Color currentMonthColor = Color(0xFF42A5F5);
  static const Color lastMonthColor = Color(0xFFB0BEC5);

  CategoryMetricService categoryMetricService =
      GetIt.I.get<CategoryMetricService>();
  List<CategoryComparisonResponse> data = [];
  DateTime referenceDate = DateTime.now();
  int take = 5;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.compare_arrows),
            title: Text(localizations.categoryComparisonChart),
            subtitle: Text(_buildSubtitle()),
            trailing: IconButton(
              icon: Icon(Icons.menu),
              onPressed: _showFilterDialog,
            ),
          ),
          Expanded(
            child: Skeletonizer(
              enabled: loading,
              child: _buildBody(context, localizations),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle() {
    if (data.isEmpty) return '';
    final first = data.first;
    final currentMonthName = first.currentMonth.toMonthName();
    final lastMonthName = first.lastMonth.toMonthName();
    return '$currentMonthName vs $lastMonthName';
  }

  Widget _buildBody(BuildContext context, AppLocalizations localizations) {
    if (loading) {
      return Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 40, 10),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, size: 48, color: Colors.grey),
            SizedBox(height: 10),
            Text(localizations.noCategoryComparisonDataAvailable),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 40, 10),
      child: Column(
        children: [
          Expanded(child: BarChart(buildChartData())),
          SizedBox(height: 8),
          _buildLegend(localizations),
        ],
      ),
    );
  }

  Widget _buildLegend(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(
          color: currentMonthColor,
          text: localizations.currentMonth,
        ),
        SizedBox(width: 16),
        _LegendDot(
          color: lastMonthColor,
          text: localizations.lastMonth,
        ),
      ],
    );
  }

  BarChartData buildChartData() {
    final maxValue = data.fold<double>(
      0,
      (acc, item) {
        final highest = item.currentMonthTotal > item.lastMonthTotal
            ? item.currentMonthTotal
            : item.lastMonthTotal;
        return highest > acc ? highest : acc;
      },
    );

    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameSize: 16,
          sideTitles: SideTitles(
            reservedSize: 30,
            showTitles: true,
            getTitlesWidget: (value, metadata) {
              final index = value.toInt();
              if (index < 0 || index >= data.length) {
                return SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  data[index].name,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
        rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
      maxY: maxValue * 1.2,
      barGroups: data
          .asMap()
          .entries
          .map(
            (entry) => BarChartGroupData(
              x: entry.key,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  color: currentMonthColor,
                  toY: entry.value.currentMonthTotal,
                  width: 8,
                ),
                BarChartRodData(
                  color: lastMonthColor,
                  toY: entry.value.lastMonthTotal,
                  width: 8,
                ),
              ],
            ),
          )
          .toList(),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final category = data[group.x];
            final isCurrentMonth = rodIndex == 0;
            final value = rod.toY.formatWithDot();
            final periodLabel = isCurrentMonth
                ? AppLocalizations.of(context)!.currentMonth
                : AppLocalizations.of(context)!.lastMonth;
            final changeText = category.percentageChange.isFinite
                ? ' (${category.percentageChange.toStringAsFixed(1)}%)'
                : '';
            return BarTooltipItem(
              '${category.name}\n$periodLabel: $value$changeText',
              TextStyle(color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  Future load() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await categoryMetricService.getCategoryComparison(
          referenceDate, take);
      setState(() {
        data = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return CategoryComparisonFilterSheet(
          initialReferenceDate: referenceDate,
          initialTake: take,
          onApply: (newReferenceDate, newTake) {
            setState(() {
              referenceDate = newReferenceDate;
              take = newTake;
            });
            load();
          },
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
