class TransactionModel {
  final int id, accountId, categoryId;
  String name;
  double price;
  DateTime date;
  TransactionType transactionType;

  TransactionModel(this.id, this.accountId, this.categoryId, this.name, this.price, this.date, this.transactionType);

  factory TransactionModel.fromJson(dynamic json){
    return TransactionModel(
      json['id'], 
      json['accountId'], 
      json['categoryId'], 
      json['name'], 
      double.parse(json['price'].toString()), 
      DateTime.parse(json['date']),
      parse(json['transactionType']));
  }  

  static TransactionType parse(int value) => value == 0 ? TransactionType.Income : TransactionType.Outcome;

  static TransactionType parseByName(String value) => value == 'Income' ? TransactionType.Income : TransactionType.Outcome;

  static List<String> getTransactionTypes() => ['Income', 'Outcome'];
}

enum TransactionType{
  Income, 
  Outcome
}