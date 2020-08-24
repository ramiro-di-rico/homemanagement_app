import 'package:flutter/material.dart';
import 'package:home_management_app/services/metrics.service.dart';
import 'package:injector/injector.dart';

class TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  Injector injector = Injector.appInstance;
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
    this.metricService = injector.getDependency<MetricService>();
    var result = await this.metricService.getOverall();
    print(result.outcomeTransactions);
  }
}
