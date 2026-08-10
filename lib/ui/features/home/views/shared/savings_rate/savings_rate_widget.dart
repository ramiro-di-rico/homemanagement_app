import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import 'package:home_management_app/data/models/savings_rate_response.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/services/savings_rate.service.dart';
import 'package:home_management_app/ui/core/extensions/number_format_extension.dart';
import 'package:home_management_app/ui/features/home/views/shared/transaction_projection/transaction_projection_options_sheet.dart';

/// Shows how much of the income is actually kept, month by month.
///
/// When [accountId] is set the widget is locked to that account and the
/// account picker is hidden, so it can be embedded in the account screens.
class SavingsRateWidget extends StatefulWidget {
  final int? accountId;

  const SavingsRateWidget({super.key, this.accountId});

  @override
  State<SavingsRateWidget> createState() => _SavingsRateWidgetState();
}

class _SavingsRateWidgetState extends State<SavingsRateWidget> {
  final SavingsRateService _savingsRateService = GetIt.I
      .get<SavingsRateService>();
  final AccountRepository _accountRepository = GetIt.I.get<AccountRepository>();
  SavingsRateResponse? _data;
  bool loading = true;
  int lookbackMonths = 6;
  int? selectedAccountId;

  bool get isAccountLocked => widget.accountId != null;

  @override
  void initState() {
    super.initState();
    selectedAccountId = widget.accountId;
    load();
  }

  Future load() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await _savingsRateService.getSavingsRate(
        accountId: selectedAccountId,
        lookbackMonths: lookbackMonths,
      );
      setState(() {
        _data = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        _data = null;
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
    if (data == null || data.monthlyRates.isEmpty) {
      return Card(
        child: Column(
          children: [
            _header(localizations),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.savings, size: 48, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(localizations.noSavingsRateDataAvailable),
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
          _header(localizations),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: _CurrentRateTile(
                    label: localizations.savingsRateThisMonth,
                    rate: data.currentMonthRate,
                    averageRate: data.averageRate,
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    label: localizations.savingsRateTotalIncome,
                    value: data.totalIncome,
                    color: _incomeColor,
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    label: localizations.savingsRateTotalExpense,
                    value: data.totalExpense,
                    color: _expenseColor,
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    label: localizations.savingsRateTotalSaved,
                    value: data.totalSavings,
                    color: rateColor(data.averageRate),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 24, 10),
              child: BarChart(_buildChartData(data.monthlyRates)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Row(
              children: [
                _LegendDot(
                  color: _incomeColor,
                  label: localizations.savingsRateTotalIncome,
                ),
                SizedBox(width: 16),
                _LegendDot(
                  color: _expenseColor,
                  label: localizations.savingsRateTotalExpense,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(AppLocalizations localizations) {
    return ListTile(
      leading: Icon(Icons.savings),
      title: Text(localizations.savingsRate),
      subtitle: Text(_subtitleText(localizations)),
      trailing: IconButton(icon: Icon(Icons.menu), onPressed: showFilterDialog),
    );
  }

  String _subtitleText(AppLocalizations localizations) {
    var subtitle = localizations.basedOnLastMonths(lookbackMonths);
    var accountId = selectedAccountId;
    if (accountId == null || isAccountLocked) return subtitle;

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
          // With a locked account there is nothing to pick from, so the sheet
          // falls back to showing only the lookback selector.
          accounts: isAccountLocked ? [] : _accountRepository.accounts,
          onApply: (newLookbackMonths, newAccountId) {
            setState(() {
              lookbackMonths = newLookbackMonths;
              if (!isAccountLocked) {
                selectedAccountId = newAccountId;
              }
            });
            load();
          },
        );
      },
    );
  }

  BarChartData _buildChartData(List<MonthlySavingsRate> months) {
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
            // Two stacked lines (month + rate) plus the top padding, so the
            // reserved strip has to be tall enough for both or fl_chart
            // clips them and the layout overflows.
            reservedSize: 52,
            getTitlesWidget: (value, meta) {
              var month = months[value.toInt()];
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(month.monthName, style: const TextStyle(fontSize: 12)),
                    Text(
                      formatRate(month.rate),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: rateColor(month.rate),
                      ),
                    ),
                  ],
                ),
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
              '${month.monthName}\n'
              '${month.income.formatWithDot()} - ${month.expense.formatWithDot()}\n'
              '${month.savings.formatWithDot()} (${formatRate(month.rate)})',
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
                  toY: entry.value.income,
                  color: _incomeColor,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: entry.value.expense,
                  color: _expenseColor,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

const Color _incomeColor = Colors.lightBlue;
const Color _expenseColor = Colors.deepOrange;

/// The API sends rates as percentages (20 means 20%) and null when the month
/// had no income, in which case there is no rate to show.
String formatRate(double? rate) =>
    rate == null ? '—' : '${rate.toStringAsFixed(1)}%';

Color rateColor(double? rate) {
  if (rate == null) return Colors.grey;
  if (rate < 0) return Colors.red;
  if (rate < 20) return Colors.orange;
  return Colors.green;
}

class _CurrentRateTile extends StatelessWidget {
  final String label;
  final double? rate;
  final double? averageRate;

  const _CurrentRateTile({
    required this.label,
    required this.rate,
    required this.averageRate,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          formatRate(rate),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: rateColor(rate),
          ),
        ),
        Text(
          '${localizations.savingsRateAverage}: ${formatRate(averageRate)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value.formatWithDot(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
