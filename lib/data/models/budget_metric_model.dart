class BudgetMetricModel{
  final int budgetId;
  final int? parentBudgetId;
  final String name;
  final double totalBudgeted, totalSpent, totalRemaining;

  BudgetMetricModel(this.budgetId, this.name, this.totalBudgeted, this.totalSpent,
      this.totalRemaining, this.parentBudgetId);

  factory BudgetMetricModel.fromJson(Map<String, dynamic> json){

    var totalBudgeted = json['totalBudgeted'];
    var totalSpent = json['totalSpent'];
    var totalRemaining = json['totalRemaining'];
    return BudgetMetricModel(
      json['budgetId'],
      json['name'],
      totalBudgeted is int ? totalBudgeted.toDouble() : totalBudgeted,
      totalSpent is int ? totalSpent.toDouble() : totalSpent,
      totalRemaining is int ? totalRemaining.toDouble() : totalRemaining,
      json['parentBudgetId']
    );
  }

  bool spentMoreThanBudgeted(){
    return totalSpent > totalBudgeted;
  }
}