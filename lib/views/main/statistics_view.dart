import 'package:flutter/material.dart';

import 'widgets/category_historical/category_historical_chart_widget.dart';
import 'widgets/most-expensive-categories.widget.dart';

class StatisticsView extends StatelessWidget {
  static const String fullPath = '/home_screen/statistics';
  static const String path = '/statistics';

  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1100;

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 420,
                        child: MostExpensiveCategoriesChart(),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 420,
                        child: CategoryHistoricalChartWidget(),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 420,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: MostExpensiveCategoriesChart(),
                    ),
                  ),
                  SizedBox(
                    height: 420,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CategoryHistoricalChartWidget(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
