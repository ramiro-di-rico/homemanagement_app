import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/services/metrics.service.dart';
import 'package:skeletons/skeletons.dart';

class IncomeWidget extends StatefulWidget {
  @override
  _IncomeWidgetState createState() => _IncomeWidgetState();
}

class _IncomeWidgetState extends State<IncomeWidget> {
  MetricService metricService = GetIt.instance<MetricService>();
  double income = 0;
  IconData icon = Icons.trending_flat;
  Color trendColor = Colors.white;
  bool loading = false;

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
        child: Skeleton(
          isLoading: loading,
          skeleton: SkeletonLine(),
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
      ),
    );
  }

  void fetchIncome() async {
    setState(() {
      loading = true;
    });
    var result = await this.metricService.getIncomeMetrics();
    setState(() {
      this.income = result.total;
      this.icon = this.income > 0 ? Icons.trending_up : Icons.trending_down;
      this.trendColor = this.income > 0 ? Colors.green[400] : Colors.red[400];
      loading = false;
    });
  }
}
