class BudgetModel{
  int id;
  String name;
  double amount;
  int? accountId, categoryId, currencyId, budgetParentId;
  DateTime? startDate;
  DateTime? endDate;

  BudgetModel(this.id, this.name, this.amount, this.accountId, this.categoryId, this.currencyId, this.budgetParentId, this.startDate, this.endDate);

  factory BudgetModel.fromJson(Map<String, dynamic> json){
    return BudgetModel(
      json['id'],
      json['name'],
      json['amount'],
      json['accountId'],
      json['categoryId'],
      json['currencyId'],
      json['budgetParentId'],
      DateTime.parse(json['startDate']),
      DateTime.parse(json['endDate'])
    );
  }

  Map ToJson(BudgetModel budget){
    return {
      'id': budget.id,
      'name': budget.name,
      'amount': budget.amount,
      'accountId': budget.accountId,
      'categoryId': budget.categoryId,
      'currencyId': budget.currencyId,
      'budgetParentId': budget.budgetParentId,
      'startDate': budget.startDate?.toIso8601String(),
      'endDate': budget.endDate?.toIso8601String()
    };
  }

  factory BudgetModel.empty(){
    return BudgetModel(0, '', 0, 0, 0, 0, 0, null, null);
  }

  factory BudgetModel.copy(BudgetModel budget){
    return BudgetModel(budget.id, budget.name, budget.amount, budget.accountId, budget.categoryId, budget.currencyId, budget.budgetParentId, budget.startDate, budget.endDate);
  }
}