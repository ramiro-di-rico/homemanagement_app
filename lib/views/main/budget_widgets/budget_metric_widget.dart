import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../services/repositories/budget_repository.dart';

class BudgetMetricWidget extends StatefulWidget {
  @override
  State<BudgetMetricWidget> createState() => _BudgetMetricWidgetState();
}

class _BudgetMetricWidgetState extends State<BudgetMetricWidget> {
  BudgetRepository _budgetRepository = GetIt.I.get<BudgetRepository>();

  @override
  void initState() {
    super.initState();
    _budgetRepository.addListener(refreshState);
  }

  @override
  void dispose() {
    _budgetRepository.removeListener(refreshState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              children: drawMetrics(),
          ),
        ),
      ),
    );
  }

  List<Widget> drawMetrics() {
    List<Widget> rows = [];
    rows.add(Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Row(
          children: [
            SizedBox(
                width: 150,
                child: Text('Name')),
            SizedBox(width: 20),
            SizedBox(
              width: 200,
              child: Text('Spent'),
            ),
            SizedBox(width: 20),
            SizedBox(
                width: 120,
                child: Text('Budgeted')),
            SizedBox(width: 20),
            SizedBox(
                width: 120,
                child: Text('Remaining')
            )
          ],
        ),
      ),
    ));
    rows.addAll(_budgetRepository.budgetMetrics
        .map((metric) => Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
                  children: [
                    SizedBox(
                        width: 150,
                        child: Text(metric.name)),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        allowedInteraction: SliderInteraction.tapOnly,
                        thumbColor: calculateColor(metric.totalSpent, metric.totalBudgeted),
                        label: metric.totalSpent.toString(),
                        min: 0,
                        max: metric.totalBudgeted.toDouble(),
                        value: metric.totalSpent.toDouble(),
                        onChanged: (value) {},
                      ),
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                        width: 120,
                        child: Text(metric.totalBudgeted.toStringAsFixed(0).toString())),
                    SizedBox(width: 20),
                    SizedBox(
                        width: 120,
                        child: Text((metric.totalBudgeted - metric.totalSpent).toStringAsFixed(0).toString())
                    )
                  ],
                ),
          ),
        ))
        .toList());

    return rows;
  }

  void refreshState() {
    setState(() {});
  }

  int calculatePercentage(double totalSpent, double totalBudgeted) {
    return ((totalSpent / totalBudgeted) * 100).toInt();
  }

  Color calculateColor(double totalSpent, double totalBudgeted) {
    var percentage = calculatePercentage(totalSpent, totalBudgeted);
    if (percentage < 50) {
      return Colors.greenAccent;
    } else if (percentage < 75) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }
}
