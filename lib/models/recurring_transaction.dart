import 'transaction.dart';

class RecurringTransaction{
  final int id;
  int accountId, categoryId;
  String name;
  double? price;
  TransactionType transactionType;
  Recurrence recurrence;
  DateTime? date;
  DateTime? dueDate;

  RecurringTransaction(this.id, this.accountId, this.categoryId, this.name, this.price,
      this.transactionType, this.recurrence, this.date, this.dueDate);

  factory RecurringTransaction.empty(int accountId, int categoryId) =>
      RecurringTransaction(0, accountId, categoryId, "", 0, TransactionType.Outcome, Recurrence.Monthly, DateTime.now(), DateTime.now());

  factory RecurringTransaction.fromJson(dynamic json) {
    var date = json['date'] == null ? null : DateTime.parse(json['date']);
    var dueDate = json['dueDate'] == null ? null : DateTime.parse(json['dueDate']);
    var price = json['price'] == null ? null : json['price'].toDouble();
    return RecurringTransaction(
        json['id'],
        json['accountId'],
        json['categoryId'],
        json['name'],
        price,
        TransactionModel.parse(json['transactionType'], categoryName: null),
        parseRecurrence(json['recurrence']),
        date,
        dueDate);
  }

  Map toJson() => {
        'id': this.id,
        'accountId': this.accountId,
        'categoryId': this.categoryId,
        'name': this.name,
        'price': this.price,
        'transactionType':
            this.transactionType == TransactionType.Income ? 0 : 1,
        'recurrence': this.recurrence == Recurrence.Monthly ? 0 : 1,
        'date': this.date?.toIso8601String(),
        'dueDate': this.dueDate?.toIso8601String()
      };

  static Recurrence parseRecurrence(int value) =>
      value == 0 ? Recurrence.Monthly : Recurrence.Annually;
}

enum Recurrence {
  Monthly,
  Annually
}