class Overall {
  final int totalTransactions;
  final int outcomeTransactions;
  final int incomeTransactions;
  final int totalOutcome;
  final int totalIncome;

  Overall(this.totalTransactions, this.outcomeTransactions,
      this.incomeTransactions, this.totalOutcome, this.totalIncome);

  factory Overall.fromJson(Map<String, dynamic> json) {
    return Overall(
      (json['totalTransactions'] as num).toInt(),
      (json['expenseTransactions'] as num).toInt(),
      (json['incomeTransactions'] as num).toInt(),
      (json['totalExpense'] as num).toInt(),
      (json['totalIncome'] as num).toInt(),
    );
  }
}
