class BudgetModel{
  int id;
  String name;
  double amount;
  int? accountId, categoryId, currencyId, budgetParentId;
  DateTime? startDate;
  DateTime? endDate;

  BudgetModel(this.id, this.name, this.amount, this.accountId, this.categoryId, this.currencyId, this.budgetParentId, this.startDate, this.endDate);

  factory BudgetModel.fromJson(Map<String, dynamic> json){
    var startDate = json['startDate'] != null ? DateTime.parse(json['startDate']) : null;
    var endDate = json['endDate'] != null ? DateTime.parse(json['endDate']) : null;

    return BudgetModel(
      json['id'],
      json['name'],
      double.parse(json['amount'].toString()),
      json['accountId'],
      json['categoryId'],
      json['currencyId'],
      json['budgetParentId'],
      startDate,
      endDate
    );
  }

  Map ToJson(){
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'accountId': accountId,
      'categoryId': categoryId,
      'currencyId': currencyId,
      'budgetParentId': budgetParentId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String()
    };
  }

  factory BudgetModel.empty(){
    return BudgetModel(0, '', 0, null, null, null, null, null, null);
  }

  factory BudgetModel.copy(BudgetModel budget){
    return BudgetModel(budget.id, budget.name, budget.amount, budget.accountId, budget.categoryId, budget.currencyId, budget.budgetParentId, budget.startDate, budget.endDate);
  }
}