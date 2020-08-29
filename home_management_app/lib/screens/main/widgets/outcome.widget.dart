import 'package:flutter/material.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/services/metrics.service.dart';
import 'package:injector/injector.dart';

class OutcomeWidget extends StatefulWidget {
  @override
  _OutcomeWidgetState createState() => _OutcomeWidgetState();
}

class _OutcomeWidgetState extends State<OutcomeWidget> {
  Injector injector = Injector.appInstance;
  MetricService metricService;
  int outcome;
  Color trendColor = Colors.white;
  IconData icon = Icons.trending_flat;

  @override
  void initState() {
    super.initState();
    fetchOutcome();
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
                Text('Outcome'),
                Text(outcome.toString()),
                Icon(this.icon,
                  color: trendColor,
                )
              ],
            )
          ]),
        ),
    );
  }

  void fetchOutcome() async {
    this.metricService = injector.getDependency<MetricService>();
    var result = await this.metricService.getOverall();
    setState(() {
      this.outcome = result.outcomeTransactions;
      this.icon = this.outcome > 0 ? Icons.trending_up : Icons.trending_down;
      this.trendColor = this.outcome > 0 ? Colors.green[400] : Colors.red[400];
    });
  }
}
