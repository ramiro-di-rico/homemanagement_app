import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/currency.dart';
import 'package:home_management_app/domain/models/transaction.dart';

import 'local_database.dart';

extension LocalCurrencyMapping on LocalCurrency {
  CurrencyModel toModel() => CurrencyModel(id, name, value);
}

extension LocalAccountMapping on LocalAccount {
  /// Local accounts have no owner, so `userId` is 0.
  AccountModel toModel(double balance) => AccountModel(
      id,
      name,
      balance,
      measurable,
      accountType == 1 ? AccountType.BankAccount : AccountType.Cash,
      currencyId,
      0,
      archive,
      isHidden);
}

extension LocalCategoryMapping on LocalCategory {
  CategoryModel toModel() =>
      CategoryModel(id, 0, name, icon, measurable, isActive, color);
}

extension LocalTransactionMapping on LocalTransaction {
  TransactionModel toModel(String categoryName) => TransactionModel(
      id,
      accountId,
      categoryId,
      name,
      amount,
      fromStoredDate(date),
      transactionType == 0 ? TransactionType.Income : TransactionType.Outcome,
      categoryName: categoryName);
}

/// Dates are stored as UTC midnight of the chosen day, like the server does.
/// Only the calendar day of [date] matters, whatever zone it is in.
DateTime toStoredDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

/// Hands the day back as local midnight, so views show the day that was chosen.
DateTime fromStoredDate(DateTime stored) {
  final utc = stored.toUtc();
  return DateTime(utc.year, utc.month, utc.day);
}
