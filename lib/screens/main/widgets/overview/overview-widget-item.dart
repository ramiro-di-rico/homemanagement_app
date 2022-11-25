import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/converters/shorten-big-number.dart';
import 'package:home_management_app/models/overall.dart';
import 'package:home_management_app/services/metrics.service.dart';
import 'package:skeletons/skeletons.dart';

import '../../../../converters/int-shorten-converter.dart';
import 'indicator.dart';

class OverviewWidget extends StatefulWidget {
  const OverviewWidget({Key key}) : super(key: key);

  @override
  State<OverviewWidget> createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  MetricService _metricService = GetIt.I<MetricService>();
  Overall overall;
  List<PieChartSectionData> pieData = List.empty(growable: true);
  ShortenBigNumber<int> shortenBigNumber = IntShortenConverter();

  @override
  void initState() {
    load();
    super.initState();
  }

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
                            value: overall?.incomeTransactions?.toDouble()),
                        PieChartSectionData(
                            color: Colors.teal[200],
                            radius: 30,
                            title: overall?.outcomeTransactions.toString(),
                            value: overall?.outcomeTransactions?.toDouble()),
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
                                    .shortNumber(overall?.totalIncome),
                                value: overall?.totalIncome?.toDouble()),
                            PieChartSectionData(
                                color: Colors.teal[200],
                                radius: 30,
                                title: shortenBigNumber
                                    .shortNumber(overall?.totalOutcome),
                                value: overall?.totalOutcome?.toDouble()),
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
              color: Colors.orange[200],
              text: 'Income',
              isSquare: true,
            ),
            SizedBox(
              width: 10,
            ),
            Indicator(
              color: Colors.teal[200],
              text: 'Outcome',
              isSquare: true,
            ),
          ],
        ),
        SizedBox(height: 10),
      ])),
    );
  }

  Future load() async {
    var fetchedOverall = await _metricService.getOverall();
    setState(() {
      overall = fetchedOverall;
    });
  }
}
