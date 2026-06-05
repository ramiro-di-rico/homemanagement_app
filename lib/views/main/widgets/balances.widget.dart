import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBreakdown();
  }

  @override
Widget build(BuildContext context) {
    return Card(
      child: Column( // Changed from ListView directly to Column for title + list structure
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Row( // Using a Row to align items and place the icon
                children: [
                  Icon(Icons.account_balance, color: Colors.blueGrey, size: 24), // Added Icon for balance
                  SizedBox(width: 10), // Spacing between icon and title text
                   Text(
                     'Balance',
                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Increased title font size
                   ),
                ],
              ),
            ),
          Expanded( // Wrap the list view in Expanded to fill remaining vertical space
            child: isLoading 
              ? Center(child: CircularProgressIndicator())
              : breakdown.isEmpty
                ? Center(child: Text("No balance information available"))
                : ListView.builder(
                  itemCount: breakdown.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(breakdown[index].name, style: TextStyle(fontSize: 16),), // Now wrapped with style in the next step
                  trailing: Text(convertToCurrency(breakdown[index].value), style: TextStyle(fontSize: 16)), // Now wrapped with style in the next step
                  dense: true,
                );
              },
                ),
          )
        ],
      ),
    );
}

  void fetchBreakdown() async {
    try {
      var result = await metricService.getBreakdown();
      setState(() {
        breakdown = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String convertToCurrency(double value) {
    final numberFormat = new NumberFormat("#,##0", "en_US");
    var currency = numberFormat.format(value);
    return currency;
  }
}
