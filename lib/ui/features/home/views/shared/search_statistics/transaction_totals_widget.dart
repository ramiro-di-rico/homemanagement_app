import 'package:flutter/material.dart';
import 'package:home_management_app/ui/core/extensions/number_format_extension.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/domain/models/transaction.dart';

class TransactionTotalsWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionTotalsWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final incomeTotal = transactions
        .where((t) => t.transactionType == TransactionType.Income)
        .fold<double>(0, (sum, t) => sum + t.price);
    final outcomeTotal = transactions
        .where((t) => t.transactionType == TransactionType.Outcome)
        .fold<double>(0, (sum, t) => sum + t.price);
    final balance = incomeTotal - outcomeTotal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.summarize),
              title: Text(localizations.transactionTotals),
              contentPadding: EdgeInsets.zero,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _TotalTile(
                      label: localizations.totalIncome,
                      value: incomeTotal.formatWithDot(),
                      color: Colors.greenAccent,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _TotalTile(
                      label: localizations.totalOutcome,
                      value: outcomeTotal.formatWithDot(),
                      color: Colors.redAccent,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: (balance >= 0 ? Colors.greenAccent : Colors.redAccent)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: balance >= 0 ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.balance,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    balance.formatWithDot(),
                    style: TextStyle(
                      color: balance >= 0 ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _TotalTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
