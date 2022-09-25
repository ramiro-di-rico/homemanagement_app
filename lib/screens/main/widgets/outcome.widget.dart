import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/services/metrics.service.dart';
import 'package:skeletons/skeletons.dart';

//deprecated
class OutcomeWidget extends StatefulWidget {
  @override
  _OutcomeWidgetState createState() => _OutcomeWidgetState();
}

class _OutcomeWidgetState extends State<OutcomeWidget> {
  MetricService metricService = GetIt.instance<MetricService>();
  double outcome = 0;
  Color trendColor = Colors.white;
  IconData icon = Icons.trending_flat;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchOutcome();
  }

  @override
  Widget build(BuildContext context) {
    var value = outcome > 1000 ? outcome / 1000 : outcome;
    var label =
        outcome > 1000 ? value.toStringAsFixed(0) + " K" : value.toString();
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
                Text('Outcome'),
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

  void fetchOutcome() async {
    setState(() {
      loading = true;
    });
    var result = await this.metricService.getOutcomesMetrics();
    setState(() {
      this.outcome = result.total;
      this.icon = this.outcome > 0 ? Icons.trending_up : Icons.trending_down;
      this.trendColor = this.outcome > 0 ? Colors.green[400] : Colors.red[400];
      loading = false;
    });
  }
}
