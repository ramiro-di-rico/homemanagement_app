class CategoryComparisonResponse {
  final int id;
  final String name;
  final String icon;
  final String color;
  final double currentMonthTotal;
  final double lastMonthTotal;
  final double difference;
  final double percentageChange;
  final int currentYear;
  final int currentMonth;
  final int lastYear;
  final int lastMonth;

  CategoryComparisonResponse({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.currentMonthTotal,
    required this.lastMonthTotal,
    required this.difference,
    required this.percentageChange,
    required this.currentYear,
    required this.currentMonth,
    required this.lastYear,
    required this.lastMonth,
  });

  factory CategoryComparisonResponse.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) =>
        value is int ? value.toDouble() : value as double;

    return CategoryComparisonResponse(
      id: json['id'],
      name: json['name'].toString(),
      icon: json['icon'].toString(),
      color: json['color'].toString(),
      currentMonthTotal: parseDouble(json['currentMonthTotal']),
      lastMonthTotal: parseDouble(json['lastMonthTotal']),
      difference: parseDouble(json['difference']),
      percentageChange: parseDouble(json['percentageChange']),
      currentYear: json['currentYear'],
      currentMonth: json['currentMonth'],
      lastYear: json['lastYear'],
      lastMonth: json['lastMonth'],
    );
  }
}
