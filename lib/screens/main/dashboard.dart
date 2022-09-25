import 'package:flutter/material.dart';
import 'package:home_management_app/screens/main/widgets/overview-widget.dart';
import 'widgets/accounts-series-metrics..dart';
import 'widgets/most-expensive-categories.widget.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: OverviewWidget(),
            flex: 1,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: MostExpensiveCategoriesChart(),
            ),
            flex: 3,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AccountsMetricSeriesWidget(),
            ),
            flex: 3,
          ),
        ],
      ),
    );
  }
}
