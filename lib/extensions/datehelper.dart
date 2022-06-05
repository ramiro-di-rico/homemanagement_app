import 'package:intl/intl.dart';

extension DatetimeExtensions on DateTime {
  DateTime toMidnight() {
    return DateTime(this.year, this.month, this.day, 0, 0, 0);
  }
}

extension DateTimeExtensions on int {
  String toMonthName() {
    if (this > 12) throw Exception("Value cannot be greater than 12");

    var date = DateTime(DateTime.now().year, this);
    return DateFormat("MMMM").format(date);
  }
}
