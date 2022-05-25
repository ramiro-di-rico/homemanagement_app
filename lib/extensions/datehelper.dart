extension DatetimeExtensions on DateTime {
  DateTime toMidnight() {
    return DateTime(this.year, this.month, this.day, 0, 0, 0);
  }
}
