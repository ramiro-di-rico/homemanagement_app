import 'package:flutter/material.dart';
import 'package:home_management_app/models/overall.dart';
import 'package:home_management_app/services/metrics.service.dart';
import 'package:injector/injector.dart';

class OutcomeWidget extends StatefulWidget {
  @override
  _OutcomeWidgetState createState() => _OutcomeWidgetState();
}

class _OutcomeWidgetState extends State<OutcomeWidget> {
  Injector injector = Injector.appInstance;
  MetricService metricService;
  Overall overall;
  IconData icon = Icons.trending_flat;

  @override
  void initState() {
    super.initState();
    fetchOutcome();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: ThemeData.dark().backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Outcome'),
                Text(overall.outcomeTransactions.toString()),
                Icon(this.icon)
              ],
            )
          ]),
        ));
  }

  void fetchOutcome() async {
    this.metricService = injector.getDependency<MetricService>();
    var result = await this.metricService.getOverall();
    setState(() {
      this.overall = result;
      this.icon = this.overall.outcomeTransactions > 0 ? Icons.trending_up : Icons.trending_down;
    });
  }
}
