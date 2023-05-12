import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/account.dart';

import '../../models/overall.dart';
import '../../services/metrics.service.dart';
import '../main/widgets/overview/overview-widget.dart';
import 'widgets/account-app-bar.dart';
import 'widgets/account-most-expensive-categories.dart';

class AccountMetrics extends StatefulWidget {
  static const String id = 'account_metrics_screen';
  final AccountModel? account;
  AccountMetrics({this.account});
  @override
  _AccountMetricsState createState() => _AccountMetricsState();
}

class _AccountMetricsState extends State<AccountMetrics> {
  MetricService _metricService = GetIt.I<MetricService>();
  Overall? overall;

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AccountAppBar(
        account: widget.account,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child:
                        AccountMostExpensiveCategories(this.widget.account!)),
                flex: 5,
              ),
              Expanded(child: SizedBox()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: OverviewWidget(overall: overall),
                ),
                flex: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future load() async {
    var fetchedOverall =
        await _metricService.getOverallByAccountId(widget.account!.id);
    setState(() {
      overall = fetchedOverall;
    });
  }
}
