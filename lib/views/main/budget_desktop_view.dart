import 'package:flutter/material.dart';

import 'budget_widgets/budget_list_view.dart';
import 'budget_widgets/budget_metric_widget.dart';

class BudgetDesktopView extends StatefulWidget {
  static const String fullPath = '/home_screen/budget';
  static const String path = '/budget';

  @override
  State<BudgetDesktopView> createState() => _BudgetDesktopViewState();
}

class _BudgetDesktopViewState extends State<BudgetDesktopView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: 750,
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Column(
                        children: [
                          BudgetMetricWidget(),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BudgetListView(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
