double _asDouble(dynamic value) {
  if (value is int) return value.toDouble();
  return (value as double?) ?? 0.0;
}

class MonthlyProjection {
  final int monthOffset;
  final String monthName;
  final double projectedExpense;

  MonthlyProjection({
    required this.monthOffset,
    required this.monthName,
    required this.projectedExpense,
  });

  factory MonthlyProjection.fromJson(Map<String, dynamic> json) {
    return MonthlyProjection(
      monthOffset: json['monthOffset'] as int,
      monthName: json['monthName'] as String? ?? '',
      projectedExpense: _asDouble(json['projectedExpense']),
    );
  }
}

class CategoryProjection {
  final int categoryId;
  final String categoryName;
  final String? icon;
  final String? color;
  final double monthlyAverageExpense;
  final List<MonthlyProjection> threeMonthMonthlyBreakdown;

  CategoryProjection({
    required this.categoryId,
    required this.categoryName,
    this.icon,
    this.color,
    required this.monthlyAverageExpense,
    required this.threeMonthMonthlyBreakdown,
  });

  factory CategoryProjection.fromJson(Map<String, dynamic> json) {
    var breakdown = json['threeMonthMonthlyBreakdown'] as List? ?? [];
    return CategoryProjection(
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      monthlyAverageExpense: _asDouble(json['monthlyAverageExpense']),
      threeMonthMonthlyBreakdown:
          breakdown.map((e) => MonthlyProjection.fromJson(e)).toList(),
    );
  }
}

class TransactionProjectionResponse {
  final double projectedOneMonthTotal;
  final double projectedThreeMonthTotal;
  final List<MonthlyProjection> threeMonthMonthlyBreakdown;
  final List<CategoryProjection> categoryBreakdown;

  TransactionProjectionResponse({
    required this.projectedOneMonthTotal,
    required this.projectedThreeMonthTotal,
    required this.threeMonthMonthlyBreakdown,
    required this.categoryBreakdown,
  });

  factory TransactionProjectionResponse.fromJson(Map<String, dynamic> json) {
    var monthlyBreakdown = json['threeMonthMonthlyBreakdown'] as List? ?? [];
    var categoryBreakdown = json['categoryBreakdown'] as List? ?? [];
    return TransactionProjectionResponse(
      projectedOneMonthTotal: _asDouble(json['projectedOneMonthTotal']),
      projectedThreeMonthTotal: _asDouble(json['projectedThreeMonthTotal']),
      threeMonthMonthlyBreakdown:
          monthlyBreakdown.map((e) => MonthlyProjection.fromJson(e)).toList(),
      categoryBreakdown:
          categoryBreakdown.map((e) => CategoryProjection.fromJson(e)).toList(),
    );
  }
}
