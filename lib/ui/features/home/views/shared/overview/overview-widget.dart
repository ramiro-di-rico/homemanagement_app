import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:home_management_app/ui/core/converters/shorten-big-number.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/domain/models/overall.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:home_management_app/ui/core/converters/int-shorten-converter.dart';
import 'indicator.dart';

class OverviewWidget extends StatelessWidget {
  OverviewWidget({Key? key, this.overall}) : super(key: key);

  final Overall? overall;
  final List<PieChartSectionData> pieData = List.empty(growable: true);
  final ShortenBigNumber<int> shortenBigNumber = IntShortenConverter();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
          child: Column(children: [
        ListTile(leading: Icon(Icons.donut_large), title: Text(AppLocalizations.of(context)!.overall)),
        overall != null && overall!.totalTransactions == 0
            ? Expanded(
                child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(AppLocalizations.of(context)!.noTransactionsRecorded),
                  ],
                ),
              ))
            : Expanded(
                child: Row(children: [
            Expanded(
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.count),
                  SizedBox(height: 10),
                  Expanded(
                      child: Skeletonizer(
                    enabled: overall == null,
                    child: PieChart(PieChartData(
                      sections: [
                        PieChartSectionData(
                            color: Colors.orange[200],
                            radius: 30,
                            titlePositionPercentageOffset: 2,
                            showTitle: true,
                            title: overall?.incomeTransactions.toString(),
                            value: overall?.incomeTransactions.toDouble()),
                        PieChartSectionData(
                            color: Colors.teal[200],
                            titlePositionPercentageOffset: 2,
                            showTitle: true,
                            radius: 30,
                            title: overall?.outcomeTransactions.toString(),
                            value: overall?.outcomeTransactions.toDouble()),
                      ],
                    )),
                  )),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(AppLocalizations.of(context)!.total),
                        SizedBox(height: 10),
                        Expanded(
                            child: Skeletonizer(
                          enabled : overall == null,
                          child: PieChart(PieChartData(sections: [
                            PieChartSectionData(
                                color: Colors.orange[200],
                                radius: 30,
                                titlePositionPercentageOffset: 2,
                                title: shortenBigNumber
                                    .shortNumber(overall?.totalIncome ?? 0),
                                value: overall?.totalIncome.toDouble()),
                            PieChartSectionData(
                                color: Colors.teal[200],
                                radius: 30,
                                titlePositionPercentageOffset: 2,
                                title: shortenBigNumber
                                    .shortNumber(overall?.totalOutcome ?? 0),
                                value: overall?.totalOutcome.toDouble()),
                          ])),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
        if (overall == null || overall!.totalTransactions > 0) ...[
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Indicator(
                color: Colors.orange[200]!,
                text: AppLocalizations.of(context)!.income,
                isSquare: true,
              ),
              SizedBox(
                width: 10,
              ),
              Indicator(
                color: Colors.teal[200]!,
                text: AppLocalizations.of(context)!.expense,
                isSquare: true,
              ),
            ],
          ),
        ],
        SizedBox(height: 10),
      ])),
    );
  }
}
