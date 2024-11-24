import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/views/main/widgets/overview/overview-widget.dart';
import '../../models/overall.dart';
import '../../services/endpoints/metrics.service.dart';
import 'widgets/accounts-series-metrics..dart';
import 'widgets/balances.widget.dart';
import 'widgets/category_historical/category_historical_chart_widget.dart';
import 'widgets/most-expensive-categories.widget.dart';

class DashboardDesktop extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashboardDesktop> {
  MetricService _metricService = GetIt.I<MetricService>();
  Overall? overall;

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 850,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: BalanceWidget(),
                    ),
                    flex: 4,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: OverviewWidget(overall: overall),
                    ),
                    flex: 5,
                  ),
                ],
              ),
              flex: 4,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: MostExpensiveCategoriesChart(),
              ),
              flex: 6,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: CategoryHistoricalChartWidget(),
              ),
              flex: 6,
            )
          ],
        ),
      ),
    );
  }

  Future load() async {
    var fetchedOverall = await _metricService.getOverall();
    setState(() {
      overall = fetchedOverall;
    });
  }
}
