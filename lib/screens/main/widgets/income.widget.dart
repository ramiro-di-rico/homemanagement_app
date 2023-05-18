import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/custom/trending-mixin.dart';
import 'package:home_management_app/services/metrics.service.dart';
import 'package:skeletons/skeletons.dart';

//deprecated
class IncomeWidget extends StatefulWidget {
  @override
  _IncomeWidgetState createState() => _IncomeWidgetState();
}

class _IncomeWidgetState extends State<IncomeWidget> with TrendingMixin {
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
    var value = income > 1000 ? income / 1000 : income;
    var label =
        income > 1000 ? value.toStringAsFixed(0) + " K" : value.toString();
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
                Text(label),
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
      this.icon = getIcon(this.income);
      this.trendColor = getColor(this.income);
      loading = false;
    });
  }
}
