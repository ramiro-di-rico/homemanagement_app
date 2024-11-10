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
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      child: SingleChildScrollView(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                children: _budgetRepository.budgetMetrics
                    .map((metric) => Row(
                          children: [
                            Text(metric.name),
                            Text(metric.totalBudgeted.toString()),
                            Slider(
                              allowedInteraction: SliderInteraction.tapOnly,
                              thumbColor: Colors.red,
                              label: metric.totalSpent.toString(),
                              min: 0,
                              max: metric.totalBudgeted.toDouble(),
                              value: metric.totalSpent.toDouble(),
                              onChanged: (value) {},
                            )
                          ],
                        ))
                    .toList()),
          ),
        ),
      ),
    );
  }
}
