import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:home_management_app/converters/shorten-big-number.dart';
import 'package:home_management_app/models/overall.dart';
import 'package:skeletons/skeletons.dart';
import '../../../../converters/int-shorten-converter.dart';
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
        ListTile(leading: Icon(Icons.donut_large), title: Text('Overall')),
        Expanded(
          child: Row(children: [
            Expanded(
              child: Column(
                children: [
                  Text('Count'),
                  SizedBox(height: 10),
                  Expanded(
                      child: Skeleton(
                    isLoading: overall == null,
                    skeleton: SkeletonAvatar(),
                    child: PieChart(PieChartData(
                      sections: [
                        PieChartSectionData(
                            color: Colors.orange[200],
                            radius: 30,
                            title: overall?.incomeTransactions.toString(),
                            value: overall?.incomeTransactions.toDouble()),
                        PieChartSectionData(
                            color: Colors.teal[200],
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
                        Text('Total'),
                        SizedBox(height: 10),
                        Expanded(
                            child: Skeleton(
                          isLoading: overall == null,
                          skeleton: SkeletonAvatar(),
                          child: PieChart(PieChartData(sections: [
                            PieChartSectionData(
                                color: Colors.orange[200],
                                radius: 30,
                                title: shortenBigNumber
                                    .shortNumber(overall?.totalIncome ?? 0),
                                value: overall?.totalIncome.toDouble()),
                            PieChartSectionData(
                                color: Colors.teal[200],
                                radius: 30,
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
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Indicator(
              color: Colors.orange[200]!,
              text: 'Income',
              isSquare: true,
            ),
            SizedBox(
              width: 10,
            ),
            Indicator(
              color: Colors.teal[200]!,
              text: 'Expense',
              isSquare: true,
            ),
          ],
        ),
        SizedBox(height: 10),
      ])),
    );
  }
}
