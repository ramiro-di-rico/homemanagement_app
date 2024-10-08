import 'transaction.dart';

class RecurringTransaction{
  final int id;
  int accountId, categoryId;
  String name;
  TransactionType transactionType;
  Recurrence recurrence;
  DateTime date;
  DateTime dueDate;

  RecurringTransaction(this.id, this.accountId, this.categoryId, this.name,
      this.transactionType, this.recurrence, this.date, this.dueDate);

  factory RecurringTransaction.empty(int accountId, int categoryId) =>
      RecurringTransaction(0, accountId, categoryId, "", TransactionType.Outcome, Recurrence.Monthly, DateTime.now(), DateTime.now());

  factory RecurringTransaction.fromJson(dynamic json) {
    return RecurringTransaction(
        json['id'],
        json['accountId'],
        json['categoryId'],
        json['name'],
        TransactionModel.parse(json['transactionType'], categoryName: null),
        parseRecurrence(json['recurrence']),
        DateTime.parse(json['date']),
        DateTime.parse(json['dueDate']));
  }

  Map toJson() => {
        'id': this.id,
        'accountId': this.accountId,
        'categoryId': this.categoryId,
        'name': this.name,
        'transactionType':
            this.transactionType == TransactionType.Income ? 0 : 1,
        'recurrence': this.recurrence == Recurrence.Monthly ? 0 : 1,
        'date': this.date.toIso8601String(),
        'dueDate': this.dueDate.toIso8601String()
      };

  static Recurrence parseRecurrence(int value) =>
      value == 0 ? Recurrence.Monthly : Recurrence.Annually;
}

enum Recurrence {
  Monthly,
  Annually
}