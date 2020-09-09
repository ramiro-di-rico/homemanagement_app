import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/services/metrics.service.dart';

class TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  MetricService metricService;

  void initState() {
    super.initState();
    this.getValues().then((value) => null);
  }

  @override
  Widget build(BuildContext context) {    
    return Container();
  }

  Future getValues() async {
    this.metricService = GetIt.I<MetricService>();
    var result = await this.metricService.getOverall();
    print(result.outcomeTransactions);
  }
}
