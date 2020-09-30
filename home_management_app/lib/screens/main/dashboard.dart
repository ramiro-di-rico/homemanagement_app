import 'package:flutter/material.dart';
import 'package:home_management_app/screens/main/widgets/income.widget.dart';
import 'package:home_management_app/screens/main/widgets/outcome.widget.dart';
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
              children:[
                Expanded(
                    child: IncomeWidget()),
                Expanded(
                    child: OutcomeWidget()),
              ]
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: MostExpensiveCategoriesChart(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AccountsMetricSeriesWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
