import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/services/endpoints/metrics.service.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../custom/trending-mixin.dart';

//deprecated
class OutcomeWidget extends StatefulWidget {
  @override
  _OutcomeWidgetState createState() => _OutcomeWidgetState();
}

class _OutcomeWidgetState extends State<OutcomeWidget> with TrendingMixin {
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
        child: Skeletonizer(
          enabled: loading,
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
      this.icon = getIcon(this.outcome);
      this.trendColor = getColor(this.outcome);
      loading = false;
    });
  }
}
