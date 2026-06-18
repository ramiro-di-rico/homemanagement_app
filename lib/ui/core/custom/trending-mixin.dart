import 'package:flutter/material.dart';

mixin TrendingMixin {
  Color getColor(double value) {
    if (value > 0) return Colors.green[400] ?? Colors.greenAccent;

    if (value < 0) return Colors.red[400] ?? Colors.redAccent;

    return Colors.grey;
  }

  IconData getIcon(double value) {
    if (value > 0) return Icons.trending_up;

    if (value < 0) return Icons.trending_down;

    return Icons.trending_flat;
  }
}
