import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import 'package:home_management_app/ui/features/home/views/shared/category_comparison/category_comparison_chart_widget.dart';
import 'package:home_management_app/ui/features/home/views/shared/category_historical/category_historical_chart_widget.dart';
import 'package:home_management_app/ui/features/home/views/shared/most-expensive-categories.widget.dart';

class StatisticsView extends StatelessWidget {
  static const String fullPath = '/home_screen/statistics';
  static const String path = '/statistics';

  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.statistics),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1100;

            if (isWide) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 420,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MostExpensiveCategoriesChart(),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: CategoryHistoricalChartWidget(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 420,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: CategoryComparisonChartWidget(),
                        ),
                      ),
                    ],
                  ),
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
                  SizedBox(
                    height: 420,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CategoryComparisonChartWidget(),
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
