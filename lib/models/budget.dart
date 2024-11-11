class BudgetModel{
  int id;
  String name;
  double amount;
  int? accountId, categoryId, currencyId, budgetParentId;
  DateTime? startDate;
  DateTime? endDate;
  BudgetState? state;

  BudgetModel(this.id, this.name, this.amount, this.accountId, this.categoryId, this.currencyId, this.budgetParentId, this.startDate, this.endDate, this.state);

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
      endDate,
      parseState(json['state'])
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
    return BudgetModel(0, '', 0, null, null, null, null, null, null, null);
  }

  factory BudgetModel.copy(BudgetModel budget){
    return BudgetModel(budget.id, budget.name, budget.amount, budget.accountId, budget.categoryId, budget.currencyId, budget.budgetParentId, budget.startDate, budget.endDate, budget.state);
  }

  static BudgetState parseState(int state){
    switch(state){
      case 0:
        return BudgetState.New;
      case 1:
        return BudgetState.Active;
      case 2:
        return BudgetState.Archived;
      default:
        return BudgetState.New;
    }
  }
}

enum BudgetState{
  New,
  Active,
  Archived
}