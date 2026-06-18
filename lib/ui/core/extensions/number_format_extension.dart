import 'package:intl/intl.dart';

extension DoubleNumberFormatExtension on double {
  String formatWithDot() {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(this).replaceAll(',', '.');
  }
}

extension IntNumberFormatExtension on int {
  String formatWithDot() {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(this).replaceAll(',', '.');
  }
}