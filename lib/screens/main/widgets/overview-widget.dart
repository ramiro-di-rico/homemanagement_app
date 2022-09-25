import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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

  @override
  void initState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return MainCard(
        child: Column(
      children: overall != null
          ? [
              ListTile(
                leading: Text('Total transactions'),
                trailing: Text(overall.totalTransactions.toString()),
              )
            ]
          : [
              SkeletonItem(
                  child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SkeletonLine(),
                    ),
                  ),
                ],
              )),
              SizedBox(
                height: 10,
              ),
              SkeletonItem(
                  child: Row(
                children: [
                  SizedBox(
                      width: 120,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SkeletonLine(),
                      )),
                  SizedBox(
                      width: 120,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SkeletonLine(),
                      )),
                ],
              ))
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
