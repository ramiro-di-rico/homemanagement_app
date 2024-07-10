import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/models/metrics/breakdown.dart';
import 'package:intl/intl.dart';

import '../../../services/endpoints/metrics.service.dart';

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
    return Card(
      child: ListView.builder(
        itemCount: breakdown.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text(breakdown[index].name),
            trailing: Text(convertToCurrency(breakdown[index].value)),
            leadingAndTrailingTextStyle: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          );
        },
      ),
    );
  }

  void fetchBreakdown() async {
    var result = await metricService.getBreakdown();
    setState(() {
      breakdown = result;
    });
  }

  String convertToCurrency(double value) {
    final numberFormat = new NumberFormat("#,##0", "en_US");
    var currency = numberFormat.format(value);
    return currency;
  }
}
