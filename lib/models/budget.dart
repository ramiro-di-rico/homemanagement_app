class Budget{
  int id;
  String name;
  double amount;
  int? accountId, categoryId, currencyId, budgetParentId;
  DateTime? startDate;
  DateTime? endDate;

  Budget(this.id, this.name, this.amount, this.accountId, this.categoryId, this.currencyId, this.budgetParentId, this.startDate, this.endDate);

  factory Budget.fromJson(Map<String, dynamic> json){
    return Budget(
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

  Map ToJson(Budget budget){
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
}