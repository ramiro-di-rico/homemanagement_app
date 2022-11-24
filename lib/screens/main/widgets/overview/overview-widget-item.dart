import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/converters/double-shorten-converter.dart';
import 'package:home_management_app/converters/shorten-big-number.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/models/overall.dart';
import 'package:home_management_app/services/metrics.service.dart';
import 'package:skeletons/skeletons.dart';

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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(children: [
          ListTile(leading: Icon(Icons.donut_large), title: Text('Overall')),
          Expanded(
            child: Row(children: [
              Expanded(
                child: Column(
                  children: [
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
          )
        ]),
      )),
    );
  }

  Future load() async {
    var fetchedOverall = await _metricService.getOverall();
    setState(() {
      overall = fetchedOverall;
    });
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    this.color,
    this.text,
    this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
