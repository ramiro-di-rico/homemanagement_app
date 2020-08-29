import 'package:flutter/material.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/services/metrics.service.dart';
import 'package:injector/injector.dart';

class IncomeWidget extends StatefulWidget {
  @override
  _IncomeWidgetState createState() => _IncomeWidgetState();
}

class _IncomeWidgetState extends State<IncomeWidget> {
  Injector injector = Injector.appInstance;
  MetricService metricService;
  int income;
  IconData icon = Icons.trending_flat;
  Color trendColor = Colors.white;

  @override
  void initState() {
    super.initState();
    fetchIncome();
  }

  @override
  Widget build(BuildContext context) {
    return MainCard(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Income'),
              Text(income.toString()),
              Icon(
                this.icon,
                color: trendColor,
              )
            ],
          )
        ]),
      ),
    );
  }

  void fetchIncome() async {
    this.metricService = injector.getDependency<MetricService>();
    var result = await this.metricService.getOverall();
    setState(() {
      this.income = result.incomeTransactions;
      this.icon = this.income > 0 ? Icons.trending_up : Icons.trending_down;
      this.trendColor = this.income > 0 ? Colors.green[400] : Colors.red[400];
    });
  }
}
