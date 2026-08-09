import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import 'package:home_management_app/data/models/transaction_projection_response.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/services/transaction_projection.service.dart';
import 'package:home_management_app/ui/core/extensions/hex_color_extension.dart';
import 'package:home_management_app/ui/core/extensions/icons_list.dart';
import 'package:home_management_app/ui/core/extensions/number_format_extension.dart';
import 'transaction_projection_options_sheet.dart';

class TransactionProjectionChartWidget extends StatefulWidget {
  const TransactionProjectionChartWidget({super.key});

  @override
  State<TransactionProjectionChartWidget> createState() =>
      _TransactionProjectionChartWidgetState();
}

class _TransactionProjectionChartWidgetState
    extends State<TransactionProjectionChartWidget> {
  final TransactionProjectionService _transactionProjectionService =
      GetIt.I.get<TransactionProjectionService>();
  final AccountRepository _accountRepository = GetIt.I.get<AccountRepository>();
  TransactionProjectionResponse? _data;
  bool loading = true;
  int lookbackMonths = 6;
  int? selectedAccountId;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await _transactionProjectionService.getTransactionProjections(
          accountId: selectedAccountId, lookbackMonths: lookbackMonths);
      setState(() {
        _data = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (loading) {
      return const Card(child: Center(child: CircularProgressIndicator()));
    }

    final data = _data;
    if (data == null || data.threeMonthMonthlyBreakdown.isEmpty) {
      return Card(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.trending_up),
              title: Text(localizations.transactionProjections),
              subtitle: Text(_subtitleText(localizations)),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: showFilterDialog,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up, size: 48, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(localizations.noProjectionDataAvailable),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.trending_up),
            title: Text(localizations.transactionProjections),
            subtitle: Text(_subtitleText(localizations)),
            trailing: IconButton(
              icon: Icon(Icons.menu),
              onPressed: showFilterDialog,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: localizations.projectedNextMonth,
                    value: data.projectedOneMonthTotal,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    label: localizations.projectedNext3Months,
                    value: data.projectedThreeMonthTotal,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 24, 10),
              child: BarChart(_buildOverallChartData(data.threeMonthMonthlyBreakdown)),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: data.categoryBreakdown.length,
              itemBuilder: (context, index) =>
                  _CategoryProjectionRow(category: data.categoryBreakdown[index]),
            ),
          ),
        ],
      ),
    );
  }

  String _subtitleText(AppLocalizations localizations) {
    var subtitle = localizations.basedOnLastMonths(lookbackMonths);
    var accountId = selectedAccountId;
    if (accountId == null) return subtitle;

    var account = _accountRepository.accounts
        .where((account) => account.id == accountId)
        .firstOrNull;
    return account == null ? subtitle : '$subtitle • ${account.name}';
  }

  void showFilterDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return TransactionProjectionOptionsSheet(
          initialLookbackMonths: lookbackMonths,
          initialAccountId: selectedAccountId,
          accounts: _accountRepository.accounts,
          onApply: (newLookbackMonths, newAccountId) {
            setState(() {
              lookbackMonths = newLookbackMonths;
              selectedAccountId = newAccountId;
            });
            load();
          },
        );
      },
    );
  }

  BarChartData _buildOverallChartData(List<MonthlyProjection> months) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              var month = months[value.toInt()];
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(month.monthName),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            var month = months[group.x];
            return BarTooltipItem(
              '${month.monthName}\n${month.projectedExpense.formatWithDot()}',
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      barGroups: months
          .asMap()
          .entries
          .map(
            (entry) => BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.projectedExpense,
                  color: Colors.lightBlue,
                  width: 28,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final double value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value.formatWithDot(),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _CategoryProjectionRow extends StatelessWidget {
  final CategoryProjection category;

  const _CategoryProjectionRow({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = (category.color == null || category.color!.isEmpty)
        ? Colors.lightBlue
        : category.color!.fromHex();
    final icon = IconsList.allIconsMap[category.icon] ?? Icons.category;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              category.categoryName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...category.threeMonthMonthlyBreakdown.map(
            (month) => Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(month.monthName, style: Theme.of(context).textTheme.bodySmall),
                  Text(month.projectedExpense.formatWithDot()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
