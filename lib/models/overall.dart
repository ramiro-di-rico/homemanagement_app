class Overall{
  final int totalTransactions;
  final int outcomeTransactions;
  final int incomeTransactions;

  Overall(this.totalTransactions, this.outcomeTransactions, this.incomeTransactions);

  factory Overall.fromJson(Map<String, dynamic> json){
    return Overall(json['totalTransactions'], 
      json['expenseTransactions'], 
      json['incomeTransactions']);
  }
}