import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/models/metrics/breakdown.dart';

import '../../../services/metrics.service.dart';

class BalanceWidget extends StatefulWidget {
  @override
  State<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget> {
  MetricService metricService = GetIt.instance<MetricService>();
  List<Breakdown> breakdown = List.empty();

  @override
  void initState() {
    super.initState();
    fetchBreakdown();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MainCard(
        child: Column(
          children: breakdown
              .map((element) => Container(
                    child: Text(element.name),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void fetchBreakdown() async {
    var result = await metricService.getBreakdown();
    setState(() {
      breakdown = result;
    });
  }
}
