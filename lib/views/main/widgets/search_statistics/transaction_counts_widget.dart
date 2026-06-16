import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/models/transaction.dart';

class TransactionCountsWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionCountsWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final incomeCount = transactions
        .where((t) => t.transactionType == TransactionType.Income)
        .length;
    final outcomeCount = transactions
        .where((t) => t.transactionType == TransactionType.Outcome)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.numbers),
              title: Text(localizations.transactionCounts),
              contentPadding: EdgeInsets.zero,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _CountTile(
                      label: localizations.income,
                      count: incomeCount,
                      color: Colors.greenAccent,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _CountTile(
                      label: localizations.outcome,
                      count: outcomeCount,
                      color: Colors.redAccent,
                      icon: Icons.arrow_downward,
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

class _CountTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _CountTile({
    required this.label,
    required this.count,
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
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
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
