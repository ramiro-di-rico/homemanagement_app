import 'package:flutter/material.dart';
import 'package:home_management_app/screens/main/widgets/overview/overview-widget-item.dart';
import 'widgets/accounts-series-metrics..dart';
import 'widgets/most-expensive-categories.widget.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 1000,
        child: Column(
          children: [
            Expanded(
              child: OverviewWidget(),
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
                padding: const EdgeInsets.all(10),
                child: AccountsMetricSeriesWidget(),
              ),
              flex: 6,
            ),
          ],
        ),
      ),
    );
  }
}
