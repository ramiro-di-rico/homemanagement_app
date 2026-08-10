double _asDouble(dynamic value) {
  if (value is int) return value.toDouble();
  return (value as double?) ?? 0.0;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is int) return value.toDouble();
  return value as double?;
}

class MonthlySavingsRate {
  final int year;
  final int month;
  final String monthName;
  final double income;
  final double expense;
  final double savings;

  /// Null when the month has no income at all, so the rate can't be computed.
  /// Those months are rendered as a gap instead of a zero.
  final double? rate;

  MonthlySavingsRate({
    required this.year,
    required this.month,
    required this.monthName,
    required this.income,
    required this.expense,
    required this.savings,
    this.rate,
  });

  factory MonthlySavingsRate.fromJson(Map<String, dynamic> json) {
    return MonthlySavingsRate(
      year: json['year'] as int? ?? 0,
      month: json['month'] as int? ?? 0,
      monthName: json['monthName'] as String? ?? '',
      income: _asDouble(json['income']),
      expense: _asDouble(json['expense']),
      savings: _asDouble(json['savings']),
      rate: _asNullableDouble(json['rate']),
    );
  }
}

class SavingsRateResponse {
  final List<MonthlySavingsRate> monthlyRates;
  final double? currentMonthRate;
  final double? averageRate;
  final double totalIncome;
  final double totalExpense;

  SavingsRateResponse({
    required this.monthlyRates,
    this.currentMonthRate,
    this.averageRate,
    required this.totalIncome,
    required this.totalExpense,
  });

  double get totalSavings => totalIncome - totalExpense;

  factory SavingsRateResponse.fromJson(Map<String, dynamic> json) {
    var monthlyRates = json['monthlyRates'] as List? ?? [];
    return SavingsRateResponse(
      monthlyRates: monthlyRates
          .map((e) => MonthlySavingsRate.fromJson(e))
          .toList(),
      currentMonthRate: _asNullableDouble(json['currentMonthRate']),
      averageRate: _asNullableDouble(json['averageRate']),
      totalIncome: _asDouble(json['totalIncome']),
      totalExpense: _asDouble(json['totalExpense']),
    );
  }
}
