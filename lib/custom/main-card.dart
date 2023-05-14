import 'package:flutter/material.dart';

class MainCard extends StatelessWidget {
  MainCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: this.child,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
