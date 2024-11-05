import 'package:flutter/material.dart';

class BudgetDesktopView extends StatefulWidget {
  static const String fullPath = '/home_screen/budget';
  static const String path = '/budget';

  @override
  State<BudgetDesktopView> createState() => _BudgetDesktopViewState();
}

class _BudgetDesktopViewState extends State<BudgetDesktopView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget'),
      ),
      body: SafeArea(
        child: Placeholder(),
      ),
    );
  }
}
