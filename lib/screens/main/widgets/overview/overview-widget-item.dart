import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/converters/double-shorten-converter.dart';
import 'package:home_management_app/converters/shorten-big-number.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/models/overall.dart';
import 'package:home_management_app/screens/main/widgets/overview/overview-list-item.dart';
import 'package:home_management_app/services/metrics.service.dart';

import 'overview-skeleton-item.dart';

class OverviewWidget extends StatefulWidget {
  const OverviewWidget({Key key}) : super(key: key);

  @override
  State<OverviewWidget> createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  MetricService _metricService = GetIt.I<MetricService>();
  Overall overall;
  List<PieChartSectionData> pieData = List.empty(growable: true);
  ShortenBigNumber<double> shortenBigNumber = DoubleShortenConverter();

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainCard(
        child: Column(
      children: overall != null
          ? [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: OverviewListitem(
                      name: 'Total Transactions',
                      value: overall.totalTransactions.toString())),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: OverviewListitem(
                      name: 'Income',
                      value: overall.incomeTransactions.toString(),
                      total:
                          shortenBigNumber.shortNumber(overall.totalIncome))),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: OverviewListitem(
                    name: 'Outcome',
                    value: overall.outcomeTransactions.toString(),
                    total: shortenBigNumber.shortNumber(overall.totalOutcome),
                  )),
            ]
          : [
              Padding(
                padding: const EdgeInsets.all(10),
                child: OverviewSkeletonItem(),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: OverviewSkeletonItem(),
              ),
            ],
    ));
  }

  Future load() async {
    var fetchedOverall = await _metricService.getOverall();
    setState(() {
      overall = fetchedOverall;
    });
  }
}
