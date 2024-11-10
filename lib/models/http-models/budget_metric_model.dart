class BudgetMetricModel{
  final int budgetId;
  final int? parentBudgetId;
  final String name;
  final int totalBudgeted, totalSpent, totalRemaining;

  BudgetMetricModel(this.budgetId, this.name, this.totalBudgeted, this.totalSpent,
      this.totalRemaining, this.parentBudgetId);

  factory BudgetMetricModel.fromJson(Map<String, dynamic> json){
    return BudgetMetricModel(
      json['budgetId'],
      json['name'],
      json['totalBudgeted'],
      json['totalSpent'],
      json['totalRemaining'],
      json['parentBudgetId']
    );
  }
}