import 'recurring_transaction.dart';

class TransactionModel {
  final int id;
  int accountId, categoryId;
  String name, categoryName;
  double price;
  DateTime date;
  TransactionType transactionType;

  TransactionModel duplicate() {
    return TransactionModel(0, this.accountId, this.categoryId, this.name,
        this.price, this.date, this.transactionType);
  }

  TransactionModel clone() {
    return TransactionModel(id, this.accountId, this.categoryId, this.name,
        this.price, this.date, this.transactionType);
  }

  TransactionModel(this.id, this.accountId, this.categoryId, this.name,
      this.price, this.date, this.transactionType, {this.categoryName = ""});

  factory TransactionModel.empty(int accountId, int categoryId) =>
      TransactionModel(0, accountId, categoryId, "", 0, DateTime.now(),
          TransactionType.Outcome);

  factory TransactionModel.fromJson(dynamic json) {
    var categoryName = json['categoryName'];
    var model = TransactionModel(
        json['id'],
        json['accountId'],
        json['categoryId'],
        json['name'],
        double.parse(json['price'].toString()),
        DateTime.parse(json['date']),
        parse(json['transactionType'],
        categoryName: categoryName));
    model.categoryName = categoryName;
    return model;
  }

  factory TransactionModel.fromRecurring(RecurringTransaction recurringTransaction) {
    return TransactionModel(0,
        recurringTransaction.accountId!,
        recurringTransaction.categoryId!,
        recurringTransaction.name,
        recurringTransaction.price ?? 0,
        recurringTransaction.date!,
        recurringTransaction.transactionType);
  }

  Map toJson() => {
        'id': this.id,
        'accountId': this.accountId,
        'categoryId': this.categoryId,
        'name': this.name,
        'price': this.price,
        'date': this.date.toIso8601String(),
        'transactionType':
            this.transactionType == TransactionType.Income ? 0 : 1,
      };

  static TransactionType parse(int value, {required categoryName}) =>
      value == 0 ? TransactionType.Income : TransactionType.Outcome;

  static TransactionType parseByName(String value) =>
      value == 'Income' ? TransactionType.Income : TransactionType.Outcome;

  static List<String> getTransactionTypes() => ['Income', 'Outcome'];

  String parseTransactionByType() =>
      transactionType == TransactionType.Income ? 'Income' : 'Outcome';

  bool isValid() => name.length > 3 && categoryId > 0 && accountId > 0;

  bool isIncome() => transactionType == TransactionType.Income;
}

enum TransactionType { Income, Outcome }
